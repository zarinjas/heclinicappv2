<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PatientNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * The patient-facing notification inbox.
 *
 * Every action is scoped to the authenticated patient's Plato id, so one
 * patient can never read or mutate another's notifications.
 */
final class NotificationInboxController extends Controller
{
    /** GET /api/v2/notifications */
    public function index(Request $request): JsonResponse
    {
        $platoId = $this->platoId($request);

        if ($platoId === null) {
            return response()->json(['notifications' => [], 'unread_count' => 0]);
        }

        $perPage = min(max((int) $request->input('per_page', 30), 1), 100);

        $paginator = PatientNotification::forPatient($platoId)
            ->orderByDesc('created_at')
            ->paginate($perPage);

        return response()->json([
            'notifications' => collect($paginator->items())
                ->map(fn (PatientNotification $n) => $n->toApiArray())
                ->all(),
            'unread_count' => PatientNotification::forPatient($platoId)->unread()->count(),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'total' => $paginator->total(),
            ],
        ]);
    }

    /** GET /api/v2/notifications/unread-count */
    public function unreadCount(Request $request): JsonResponse
    {
        $platoId = $this->platoId($request);

        return response()->json([
            'unread_count' => $platoId === null
                ? 0
                : PatientNotification::forPatient($platoId)->unread()->count(),
        ]);
    }

    /** POST /api/v2/notifications/{id}/read */
    public function markRead(Request $request, int $id): JsonResponse
    {
        $platoId = $this->platoId($request);

        $notification = PatientNotification::forPatient((string) $platoId)
            ->whereKey($id)
            ->first();

        if ($notification === null) {
            return response()->json([
                'error' => true,
                'message' => 'Notification not found.',
            ], 404);
        }

        if (! $notification->isRead()) {
            $notification->update(['read_at' => now()]);
        }

        return response()->json([
            'status' => true,
            'unread_count' => PatientNotification::forPatient((string) $platoId)->unread()->count(),
        ]);
    }

    /** POST /api/v2/notifications/read-all */
    public function markAllRead(Request $request): JsonResponse
    {
        $platoId = $this->platoId($request);

        if ($platoId !== null) {
            PatientNotification::forPatient($platoId)->unread()->update(['read_at' => now()]);
        }

        return response()->json(['status' => true, 'unread_count' => 0]);
    }

    private function platoId(Request $request): ?string
    {
        $id = (string) ($request->user()->idplato ?? '');

        return $id === '' ? null : $id;
    }
}
