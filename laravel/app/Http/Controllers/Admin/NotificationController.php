<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\Doctor;
use App\Models\NotificationLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class NotificationController extends Controller
{
    public function compose(): View
    {
        $user = auth()->user();
        $branches = Branch::where('is_active', true)->orderBy('name')->get();

        $doctorsQuery = Doctor::where('is_active', true)->orderBy('name');

        if ($user->branch_id) {
            $doctorsQuery->where('branch_id', $user->branch_id);
        }

        $doctors = $doctorsQuery->get();

        return view('admin.notifications.compose', compact('branches', 'doctors'));
    }

    public function send(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string|max:2000',
            'image_url' => 'nullable|url|max:500',
            'target_type' => 'required|string|in:all,branch,doctor,appointment_date_range,specific_patient',
            'target_ids' => 'nullable|array',
            'target_ids.*' => 'integer',
            'target_date_from' => 'nullable|date',
            'target_date_to' => 'nullable|date|after_or_equal:target_date_from',
            'target_patient' => 'nullable|string|max:255',
            'channels' => 'required|array|min:1',
            'channels.*' => 'in:push,email,in_app',
        ], [
            'channels.required' => 'Please select at least one delivery channel.',
            'channels.min' => 'Please select at least one delivery channel.',
        ]);

        $targetIds = null;
        if ($validated['target_type'] === 'specific_patient' && !empty($validated['target_patient'])) {
            $targetIds = [$validated['target_patient']];
        } elseif ($validated['target_type'] === 'all') {
            $targetIds = null;
        } else {
            $targetIds = $validated['target_ids'] ?? null;
        }

        NotificationLog::create([
            'type' => 'manual',
            'title' => $validated['title'],
            'body' => $validated['body'],
            'image_url' => $validated['image_url'] ?? null,
            'target_type' => $validated['target_type'],
            'target_ids' => $targetIds,
            'target_date_from' => $validated['target_date_from'] ?? null,
            'target_date_to' => $validated['target_date_to'] ?? null,
            'channels' => $validated['channels'],
            'status' => 'draft',
        ]);

        return redirect()
            ->route('admin.notifications.compose')
            ->with('success', 'Notification draft saved.');
    }

    public function index(Request $request): View
    {
        $query = NotificationLog::query();

        if ($request->filled('search')) {
            $search = $request->string('search')->trim();
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('body', 'like', "%{$search}%");
            });
        }

        if ($request->filled('type')) {
            $query->where('type', $request->string('type'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->string('date_from'));
        }

        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->string('date_to'));
        }

        if ($request->filled('sort') && $request->filled('direction')) {
            $query->orderBy($request->string('sort'), $request->string('direction'));
        } else {
            $query->orderBy('created_at', 'desc');
        }

        $notifications = $query->paginate(20)->withQueryString();

        return view('admin.notifications.index', compact('notifications'));
    }

    public function show(NotificationLog $notification): View|JsonResponse
    {
        if (request()->wantsJson()) {
            return response()->json($notification);
        }

        return view('admin.notifications.show', compact('notification'));
    }
}
