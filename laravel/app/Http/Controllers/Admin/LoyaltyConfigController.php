<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\LoyaltyConfig;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class LoyaltyConfigController extends Controller
{
    private const EDITABLE_KEYS = [
        'earn_rate',
        'redemption_rate',
        'min_redemption',
        'max_per_txn',
        'expiry_months',
        'redemption_expiry_days',
    ];

    public function index(): View
    {
        $values = LoyaltyConfig::allValues();

        $config = [];
        foreach (self::EDITABLE_KEYS as $key) {
            $config[$key] = $values[$key] ?? $this->defaultFor($key);
        }

        return view('admin.loyalty.config', ['config' => $config]);
    }

    public function update(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'earn_rate'              => ['required', 'numeric', 'min:0'],
            'redemption_rate'        => ['required', 'numeric', 'min:0'],
            'min_redemption'         => ['required', 'integer', 'min:1'],
            'max_per_txn'            => ['required', 'integer', 'min:1'],
            'expiry_months'          => ['required', 'integer', 'min:1'],
            'redemption_expiry_days' => ['required', 'integer', 'min:1'],
        ]);

        foreach (self::EDITABLE_KEYS as $key) {
            LoyaltyConfig::updateOrCreate(
                ['key_name' => $key],
                ['value' => (string) $data[$key], 'updated_by' => $request->user()?->id],
            );
        }

        LoyaltyConfig::flushCache();

        return redirect()
            ->route('admin.loyalty.config')
            ->with('success', 'Loyalty settings updated successfully.');
    }

    private function defaultFor(string $key): string
    {
        return match ($key) {
            'earn_rate'              => '1',
            'redemption_rate'        => '0.05',
            'min_redemption'         => '100',
            'max_per_txn'            => '1000',
            'expiry_months'          => '12',
            'redemption_expiry_days' => '30',
            default                  => '',
        };
    }
}
