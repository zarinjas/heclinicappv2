<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\NotificationLog;
use App\Models\Branch;
use App\Models\Doctor;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(Request $request): View
    {
        $user = auth()->user();

        $appointmentQuery = Appointment::query();
        $branchQuery = Branch::query();
        $doctorQuery = Doctor::query();
        $userQuery = User::query();

        if ($user->isBranchAdmin() && $user->branch_id) {
            $appointmentQuery->where('branch_id', $user->branch_id);
        }

        $totalAppointmentsThisMonth = (clone $appointmentQuery)
            ->whereMonth('appointment_date', now()->month)
            ->whereYear('appointment_date', now()->year)
            ->count();

        $totalPatients = (clone $appointmentQuery)
            ->distinct('patient_plato_id')
            ->whereNotNull('patient_plato_id')
            ->count('patient_plato_id');

        $totalNotifications = NotificationLog::count();

        $totalDelivered = NotificationLog::where('status', 'delivered')->count();
        $deliveryRate = $totalNotifications > 0
            ? round(($totalDelivered / $totalNotifications) * 100)
            : 0;

        $thirtyDaysAgo = now()->subDays(30)->startOfDay();
        $appointmentsByDay = (clone $appointmentQuery)
            ->where('appointment_date', '>=', $thirtyDaysAgo)
            ->where('appointment_date', '<=', now()->endOfDay())
            ->select(DB::raw('DATE(appointment_date) as date'), DB::raw('count(*) as count'))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $chartLabels = [];
        $chartData = [];
        $dateCursor = $thirtyDaysAgo->copy();
        $apptMap = $appointmentsByDay->keyBy('date');

        for ($i = 0; $i <= 30; $i++) {
            $dateStr = $dateCursor->format('Y-m-d');
            $chartLabels[] = $dateCursor->format('M j');
            $chartData[] = isset($apptMap[$dateStr]) ? (int) $apptMap[$dateStr]->count : 0;
            $dateCursor->addDay();
        }

        return view('admin.dashboard', [
            'user' => $user,
            'totalPatients' => $totalPatients,
            'totalAppointmentsThisMonth' => $totalAppointmentsThisMonth,
            'totalNotifications' => $totalNotifications,
            'deliveryRate' => $deliveryRate,
            'chartLabels' => $chartLabels,
            'chartData' => $chartData,
        ]);
    }
}
