<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreAppointmentRequest;
use App\Models\Appointment;
use App\Models\Branch;
use App\Models\Doctor;
use App\Services\AppointmentService;
use App\Services\PlatoProxyService;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;

class AdminAppointmentController extends Controller
{
    public function index(Request $request): View
    {
        $query = [
            'current_page' => $request->get('page', 1),
        ];

        if ($request->filled('date_from')) {
            $query['date_from'] = $request->get('date_from');
        }
        if ($request->filled('date_to')) {
            $query['date_to'] = $request->get('date_to');
        }
        if ($request->filled('doctor_id')) {
            $query['doctor_id'] = $request->get('doctor_id');
        }
        if ($request->filled('facility_id')) {
            $query['facility_id'] = $request->get('facility_id');
        }
        if ($request->filled('status')) {
            $query['status'] = $request->get('status');
        }

        $plato = app(PlatoProxyService::class);
        $response = $plato->proxy('GET', 'appointment', $query);

        $appointmentsData = [];

        if (!isset($response['error']) && isset($response['data'])) {
            $appointmentsData = $response['data'];
            if (!is_array($appointmentsData)) {
                $appointmentsData = [];
            }
        }

        $currentPage = (int) $request->get('page', 1);
        $perPage = 20;
        $count = count($appointmentsData);
        $total = $count >= $perPage
            ? ($currentPage * $perPage) + $perPage
            : (($currentPage - 1) * $perPage) + $count;

        $appointments = new LengthAwarePaginator(
            $appointmentsData,
            $total,
            $perPage,
            $currentPage,
            ['path' => $request->url(), 'query' => $request->query()]
        );

        $branches = Branch::where('is_active', true)->orderBy('name')->get();
        $doctors = Doctor::where('is_active', true)->orderBy('name')->get();

        return view('admin.appointments.index', compact('appointments', 'branches', 'doctors'));
    }

    public function create(): View
    {
        $branches = Branch::where('is_active', true)->orderBy('name')->get();
        $doctors = Doctor::with('branch')->where('is_active', true)->orderBy('name')->get();

        return view('admin.appointments.create', compact('branches', 'doctors'));
    }

    public function show($id): View
    {
        $appointment = Appointment::with(['branch', 'doctor'])->find($id);

        if (! $appointment) {
            $appointment = Appointment::with(['branch', 'doctor'])
                ->where('plato_appointment_id', $id)
                ->first();
        }

        if (! $appointment) {
            $plato = app(PlatoProxyService::class);
            $response = $plato->proxy('GET', 'appointment', ['id' => $id]);

            $data = $response['data'][0] ?? $response['data'] ?? null;

            if (! $data) {
                abort(404, 'Appointment not found.');
            }

            $appointment = (object) $data;
            $appointment->from_plato = true;
        } else {
            $appointment->from_plato = false;
        }

        return view('admin.appointments.show', compact('appointment'));
    }

    public function store(StoreAppointmentRequest $request): RedirectResponse
    {
        try {
            $service = app(AppointmentService::class);
            $result = $service->createAppointment($request->validated());

            if ($result['success'] ?? false) {
                return redirect()
                    ->route('admin.appointments.index')
                    ->with('success', 'Walk-in appointment created successfully.');
            }

            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Failed to create appointment. Plato API returned an error.');
        } catch (\RuntimeException $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', $e->getMessage());
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'An unexpected error occurred while creating the appointment.');
        }
    }
}
