<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\Doctor;
use App\Services\PlatoProxyService;
use Illuminate\Contracts\View\View;
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
}
