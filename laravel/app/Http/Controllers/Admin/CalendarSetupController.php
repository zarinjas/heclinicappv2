<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePlatoCalendarRequest;
use App\Http\Requests\UpdatePlatoCalendarRequest;
use App\Models\Doctor;
use App\Models\PlatoCalendar;
use App\Models\Setting;
use App\Services\PlatoSystemSetupService;
use App\Traits\BranchScoped;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class CalendarSetupController extends Controller
{
    use BranchScoped;

    private PlatoSystemSetupService $systemSetup;

    public function __construct(PlatoSystemSetupService $systemSetup)
    {
        $this->systemSetup = $systemSetup;
    }

    public function index(Request $request): View
    {
        $query = PlatoCalendar::query()->with('doctor.branch');
        $query = $this->scopeCalendarToUserBranch($query);

        if ($request->filled('search')) {
            $search = $request->string('search')->trim();
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('plato_calendar_color_id', 'like', "%{$search}%")
                  ->orWhereHas('doctor', function ($dq) use ($search) {
                      $dq->where('name', 'like', "%{$search}%");
                  });
            });
        }

        if ($request->filled('doctor_id')) {
            $query->where('doctor_id', $request->integer('doctor_id'));
        }

        if ($request->has('is_active') && $request->string('is_active')->value() !== '') {
            $query->where('is_active', $request->boolean('is_active'));
        }

        if ($request->filled('sort') && $request->filled('direction')) {
            $allowedSorts = ['name', 'plato_calendar_color_id', 'is_active', 'created_at'];
            if (in_array($request->string('sort')->value(), $allowedSorts)) {
                $query->orderBy($request->string('sort'), $request->string('direction'));
            } else {
                $query->orderBy('created_at', 'desc');
            }
        } else {
            $query->orderBy('created_at', 'desc');
        }

        $calendars = $query->paginate(10)->withQueryString();
        $doctors = Doctor::where('is_active', true)->orderBy('name')->get();
        $lastSync = Setting::where('key', 'calendar_last_sync')->value('value');

        $unmappedDoctors = Doctor::where('is_active', true)
            ->whereDoesntHave('platoCalendars')
            ->count();

        return view('admin.calendars.index', compact('calendars', 'doctors', 'lastSync', 'unmappedDoctors'));
    }

    public function create(): View
    {
        $doctors = Doctor::where('is_active', true)->orderBy('name')->get();
        $syncedCalendars = PlatoCalendar::whereNull('doctor_id')
            ->where('is_active', true)
            ->orderBy('name')
            ->get();

        return view('admin.calendars.create', compact('doctors', 'syncedCalendars'));
    }

    public function store(StorePlatoCalendarRequest $request): RedirectResponse
    {
        $data = $request->validated();
        $data['is_active'] = $request->boolean('is_active');

        PlatoCalendar::create($data);

        return redirect()
            ->route('admin.calendars.index')
            ->with('success', 'Calendar mapping created successfully.');
    }

    public function show(PlatoCalendar $calendar): View
    {
        $calendar->load('doctor.branch');

        return view('admin.calendars.show', compact('calendar'));
    }

    public function edit(PlatoCalendar $calendar): View
    {
        $doctors = Doctor::where('is_active', true)->orderBy('name')->get();
        $calendar->load('doctor');

        return view('admin.calendars.edit', compact('calendar', 'doctors'));
    }

    public function update(UpdatePlatoCalendarRequest $request, PlatoCalendar $calendar): RedirectResponse
    {
        $data = $request->validated();
        $data['is_active'] = $request->boolean('is_active');

        $calendar->update($data);

        return redirect()
            ->route('admin.calendars.index')
            ->with('success', 'Calendar mapping updated successfully.');
    }

    public function destroy(PlatoCalendar $calendar): RedirectResponse
    {
        $calendar->delete();

        return redirect()
            ->route('admin.calendars.index')
            ->with('success', 'Calendar mapping removed successfully.');
    }

    public function sync(Request $request): RedirectResponse
    {
        $result = $this->systemSetup->syncCalendars();

        if (!$result['success']) {
            return redirect()
                ->route('admin.calendars.index')
                ->with('error', $result['message']);
        }

        $calendars = $result['calendars'];

        if (empty($calendars)) {
            Setting::updateOrCreate(
                ['key' => 'calendar_last_sync'],
                [
                    'value' => now()->toIso8601String(),
                    'description' => 'Last Plato calendar sync timestamp',
                ]
            );

            return redirect()
                ->route('admin.calendars.index')
                ->with('success', $result['message']);
        }

        DB::transaction(function () use ($calendars) {
            $syncedIds = [];

            foreach ($calendars as $calendar) {
                $existing = PlatoCalendar::where('plato_calendar_color_id', $calendar['plato_calendar_color_id'])
                    ->whereNull('doctor_id')
                    ->first();

                if ($existing) {
                    $existing->update(['name' => $calendar['name'], 'is_active' => true]);
                } else {
                    PlatoCalendar::create([
                        'plato_calendar_color_id' => $calendar['plato_calendar_color_id'],
                        'name' => $calendar['name'],
                        'is_active' => true,
                    ]);
                }

                $syncedIds[] = $calendar['plato_calendar_color_id'];
            }

            PlatoCalendar::whereNull('doctor_id')
                ->whereNotIn('plato_calendar_color_id', $syncedIds)
                ->update(['is_active' => false]);
        });

        Setting::updateOrCreate(
            ['key' => 'calendar_last_sync'],
            [
                'value' => now()->toIso8601String(),
                'description' => 'Last Plato calendar sync timestamp',
            ]
        );

        return redirect()
            ->route('admin.calendars.index')
            ->with('success', $result['message'])
            ->with('sync_calendars', $calendars);
    }
}
