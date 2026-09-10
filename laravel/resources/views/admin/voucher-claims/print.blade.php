<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Voucher {{ $voucher->code }}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            color: #0F1B3D;
            background: #f5f6fa;
            padding: 24px;
        }
        .toolbar { max-width: 720px; margin: 0 auto 16px; text-align: right; }
        .toolbar button {
            background: #00C9A7; color: #fff; border: none; border-radius: 8px;
            padding: 10px 20px; font-size: 14px; font-weight: 600; cursor: pointer;
        }
        .toolbar button:hover { background: #00b093; }
        .receipt {
            max-width: 720px; margin: 0 auto; background: #fff;
            border-radius: 12px; padding: 32px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        }
        .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
        .header h1 { font-size: 20px; }
        .header .brand { color: #64748b; font-size: 13px; margin-top: 4px; }
        .badge {
            display: inline-block; padding: 4px 12px; border-radius: 999px;
            font-size: 12px; font-weight: 600; text-transform: capitalize;
        }
        .badge.active { background: #ecfdf5; color: #047857; }
        .badge.used { background: #f1f5f9; color: #475569; }
        .badge.expired { background: #fef2f2; color: #dc2626; }
        .code-box {
            text-align: center; border: 2px dashed #cbd5e1; border-radius: 10px;
            padding: 16px; margin-bottom: 24px;
        }
        .code-box .code { font-family: monospace; font-size: 22px; letter-spacing: 4px; font-weight: 700; }
        .code-box .label { font-size: 12px; color: #64748b; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 6px; }
        table { width: 100%; border-collapse: collapse; font-size: 14px; }
        table td { padding: 10px 0; border-bottom: 1px solid #f1f5f9; vertical-align: top; }
        table td:first-child { color: #64748b; width: 180px; }
        table tr:last-child td { border-bottom: none; }
        .footer {
            margin-top: 24px; padding-top: 16px; border-top: 1px solid #e2e8f0;
            font-size: 12px; color: #94a3b8; text-align: center;
        }
        @media print {
            body { background: #fff; padding: 0; }
            .toolbar { display: none; }
            .receipt { box-shadow: none; border-radius: 0; max-width: 100%; }
        }
    </style>
</head>
<body>
    <div class="toolbar">
        <button onclick="window.print()">Print</button>
    </div>

    <div class="receipt">
        <div class="header">
            <div>
                <h1>Voucher Redemption Record</h1>
                <p class="brand">He Clinic Admin Panel</p>
            </div>
            <span class="badge {{ $voucher->status }}">{{ $voucher->status }}</span>
        </div>

        <div class="code-box">
            <div class="label">Voucher Code</div>
            <div class="code">{{ $voucher->code }}</div>
        </div>

        <table>
            <tr>
                <td>Patient</td>
                <td>{{ $voucher->patient?->name ?: '—' }}</td>
            </tr>
            <tr>
                <td>NRIC</td>
                <td>{{ $voucher->patient?->nric ?: '—' }}</td>
            </tr>
            <tr>
                <td>Phone</td>
                <td>{{ $voucher->patient?->telephone ?: '—' }}</td>
            </tr>
            <tr>
                <td>Promotion</td>
                <td>{{ $voucher->promotion?->title ?: '—' }}</td>
            </tr>
            <tr>
                <td>Discount</td>
                <td>{{ $voucher->promotion?->cta_text ?? $voucher->promotion?->promo_code ?? '—' }}</td>
            </tr>
            <tr>
                <td>Claimed At</td>
                <td>{{ $voucher->created_at?->format('d M Y, g:i A') ?: '—' }}</td>
            </tr>
            <tr>
                <td>Expires At</td>
                <td>{{ $voucher->expires_at?->format('d M Y') ?: '—' }}</td>
            </tr>
            @if ($voucher->used_at)
                <tr>
                    <td>Used At</td>
                    <td>{{ $voucher->used_at->format('d M Y, g:i A') }}</td>
                </tr>
            @endif
        </table>

        <div class="footer">
            Generated on {{ now()->format('d M Y, g:i A') }} &middot; For internal record / audit purposes only.
        </div>
    </div>
</body>
</html>
