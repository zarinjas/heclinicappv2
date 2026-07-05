<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Services\PlatoProxyService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class WhatsAppController extends Controller
{
    public function index(): View
    {
        $branches = Branch::where('is_active', true)
            ->whereNotNull('whatsapp_number')
            ->where('whatsapp_number', '!=', '')
            ->orderBy('name')
            ->get();

        return view('admin.whatsapp.index', compact('branches'));
    }

    public function fetchPatients(Request $request): \Illuminate\Http\JsonResponse
    {
        $branch = Branch::findOrFail($request->integer('branch_id'));

        $proxy = app(PlatoProxyService::class);
        $result = $proxy->proxy('GET', 'patient', [
            'current_page' => 1,
        ]);

        $patients = [];
        if (isset($result['data']['data']) && is_array($result['data']['data'])) {
            foreach ($result['data']['data'] as $patient) {
                if (!empty($patient['phone']) && !empty($patient['name'])) {
                    $patients[] = [
                        'phone' => $patient['phone'],
                        'name' => $patient['name'],
                    ];
                }
            }
        }

        return response()->json([
            'patients' => $patients,
            'branch_whatsapp' => $branch->whatsapp_number,
        ]);
    }

    public function send(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'branch_id' => 'required|integer|exists:branches,id',
            'message' => 'required|string|max:4096',
            'send_mode' => 'required|string|in:single,bulk',
            'recipient_phone' => 'required_if:send_mode,single|string|max:20',
            'recipient_name' => 'nullable|string|max:255',
            'patients' => 'required_if:send_mode,bulk|array',
            'patients.*.phone' => 'required_with:patients|string|max:20',
            'patients.*.name' => 'nullable|string|max:255',
        ]);

        $branch = Branch::findOrFail($validated['branch_id']);

        if (empty($branch->whatsapp_number)) {
            return redirect()
                ->route('admin.whatsapp.index')
                ->with('error', 'Selected branch does not have a WhatsApp number configured.');
        }

        $proxy = app(PlatoProxyService::class);
        $results = [];
        $successCount = 0;
        $failCount = 0;

        if ($validated['send_mode'] === 'single') {
            $phone = $validated['recipient_phone'];
            $name = $validated['recipient_name'] ?? $phone;

            $result = $proxy->proxy('POST', 'whatsapp/send', [], [
                'phone' => $phone,
                'message' => $validated['message'],
            ]);

            if (isset($result['error']) && $result['error'] === true) {
                $failCount++;
                $results[] = ['phone' => $phone, 'name' => $name, 'status' => 'failed', 'error' => $result['message'] ?? 'Unknown error'];
            } else {
                $successCount++;
                $results[] = ['phone' => $phone, 'name' => $name, 'status' => 'sent'];
            }
        } else {
            $patients = $validated['patients'] ?? [];

            foreach ($patients as $patient) {
                $phone = $patient['phone'];
                $name = $patient['name'] ?? $phone;

                $result = $proxy->proxy('POST', 'whatsapp/send', [], [
                    'phone' => $phone,
                    'message' => $validated['message'],
                ]);

                if (isset($result['error']) && $result['error'] === true) {
                    $failCount++;
                    $results[] = ['phone' => $phone, 'name' => $name, 'status' => 'failed', 'error' => $result['message'] ?? 'Unknown error'];
                } else {
                    $successCount++;
                    $results[] = ['phone' => $phone, 'name' => $name, 'status' => 'sent'];
                }
            }
        }

        return redirect()
            ->route('admin.whatsapp.index')
            ->with('send_results', [
                'total' => count($results),
                'success' => $successCount,
                'failed' => $failCount,
                'results' => $results,
                'branch_name' => $branch->name,
            ])
            ->with('success', "WhatsApp messages: {$successCount} sent, {$failCount} failed.");
    }
}
