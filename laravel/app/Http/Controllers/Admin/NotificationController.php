<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\NotificationLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class NotificationController extends Controller
{
    public function compose(): View
    {
        return view('admin.notifications.compose');
    }

    public function send(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string|max:2000',
            'image_url' => 'nullable|url|max:500',
        ]);

        NotificationLog::create([
            'type' => 'manual',
            'title' => $validated['title'],
            'body' => $validated['body'],
            'image_url' => $validated['image_url'] ?? null,
            'target_type' => 'all',
            'target_ids' => null,
            'channels' => ['push', 'email', 'in_app'],
            'status' => 'draft',
        ]);

        return redirect()
            ->route('admin.notifications.compose')
            ->with('success', 'Notification draft saved.');
    }
}
