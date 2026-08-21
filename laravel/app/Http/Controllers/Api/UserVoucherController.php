<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsPromotion;
use App\Models\UserVoucher;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

final class UserVoucherController extends Controller
{
    /**
     * GET /api/v2/vouchers
     * Protected. Returns the current patient's claimed vouchers.
     */
    public function index(Request $request): JsonResponse
    {
        $vouchers = UserVoucher::query()
            ->where('patient_id', $request->user()->id)
            ->with('promotion')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn (UserVoucher $voucher) => $this->payload($voucher));

        return response()->json($vouchers);
    }

    /**
     * POST /api/v2/vouchers/claim  { promotion_id: int }
     * Protected. Claims a promotion once per patient and returns a unique code.
     */
    public function claim(Request $request): JsonResponse
    {
        $request->validate([
            'promotion_id' => ['required', 'integer'],
        ]);

        $promotion = CmsPromotion::find($request->input('promotion_id'));

        if ($promotion === null) {
            return response()->json([
                'status' => false,
                'message' => 'Promotion not found.',
            ], 404);
        }

        if (! $promotion->is_active) {
            return response()->json([
                'status' => false,
                'message' => 'This promotion is not currently available.',
            ], 422);
        }

        $today = now()->format('Y-m-d');

        if (
            ($promotion->valid_from !== null && $promotion->valid_from->format('Y-m-d') > $today)
            || ($promotion->valid_until !== null && $promotion->valid_until->format('Y-m-d') < $today)
        ) {
            return response()->json([
                'status' => false,
                'message' => 'This promotion is outside its validity period.',
            ], 422);
        }

        $patientId = $request->user()->id;

        if (UserVoucher::where('patient_id', $patientId)
            ->where('promotion_id', $promotion->id)
            ->exists()) {
            return response()->json([
                'status' => false,
                'message' => 'You have already claimed this voucher.',
            ], 422);
        }

        if ($promotion->usage_limit !== null) {
            $claimedCount = UserVoucher::where('promotion_id', $promotion->id)->count();

            if ($claimedCount >= $promotion->usage_limit) {
                return response()->json([
                    'status' => false,
                    'message' => 'This promotion has reached its usage limit.',
                ], 422);
            }
        }

        try {
            $voucher = DB::transaction(function () use ($patientId, $promotion) {
                return UserVoucher::create([
                    'patient_id' => $patientId,
                    'promotion_id' => $promotion->id,
                    'code' => $this->generateCode(),
                    'expires_at' => $promotion->valid_until,
                ]);
            });
        } catch (\Throwable $e) {
            if (str_contains($e->getMessage(), 'Duplicate entry')) {
                return response()->json([
                    'status' => false,
                    'message' => 'You have already claimed this voucher.',
                ], 422);
            }

            throw $e;
        }

        return response()->json([
            'status' => true,
            'message' => 'Voucher claimed successfully.',
            'voucher' => $this->payload($voucher),
        ], 201);
    }

    private function payload(UserVoucher $voucher): array
    {
        return [
            'id' => $voucher->id,
            'code' => $voucher->code,
            'status' => $voucher->status,
            'claimed_at' => $voucher->created_at?->toIso8601String(),
            'used_at' => $voucher->used_at?->toIso8601String(),
            'expires_at' => $voucher->expires_at?->toDateString(),
            'promotion' => $voucher->promotion ? [
                'id' => $voucher->promotion->id,
                'title' => $voucher->promotion->title,
                'description' => $voucher->promotion->description,
                'cta_text' => $voucher->promotion->cta_text,
            ] : null,
        ];
    }

    private function generateCode(): string
    {
        do {
            $code = 'HEC-'.strtoupper(Str::random(4)).'-'.now()->year;
        } while (UserVoucher::where('code', $code)->exists());

        return $code;
    }
}
