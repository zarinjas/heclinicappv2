<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Voucher Claims Report</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            color: #0F1B3D;
            background: #f5f6fa;
            padding: 24px;
        }
        .toolbar { max-width: 960px; margin: 0 auto 16px; text-align: right; }
        .toolbar button {
            background: #00C9A7; color: #fff; border: none; border-radius: 8px;
            padding: 10px 20px; font-size: 14px; font-weight: 600; cursor: pointer;
        }
        .toolbar button:hover { background: #00b093; }
        .report {
            max-width: 960px; margin: 0 auto; background: #fff;
            border-radius: 12px; padding: 32px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        }
        .header { margin-bottom: 20px; }
        .header h1 { font-size: 20px; }
        .header .meta { color: #64748b; font-size: 13px; margin-top: 4px; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        thead th {
            text-align: left; padding: 10px 12px; background: #f8fafc;
            color: #64748b; font-weight: 600; text-transform: uppercase; font-size: 11px;
            letter-spacing: 0.5px; border-bottom: 1px solid #e2e8f0;
        }
        tbody td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; vertical-align: top; }
        tbody tr:last-child td { border-bottom: none; }
        .code { font-family: monospace; font-weight: 600; }
        .status { font-weight: 600; text-transform: capitalize; }
        .status.active { color: #047857; }
        .status.used { color: #475569; }
        .status.expired { color: #dc2626; }
        .footer {
            margin-top: 20px; padding-top: 14px; border-top: 1px solid #e2e8f0;
            font-size: 12px; color: #94a3b8; text-align: center;
        }
        @media print {
            body { background: #fff; padding: 0; }
            .toolbar { display: none; }
            .report { box-shadow: none; border-radius: 0; max-width: 100%; }
        }
    </style>
</head>
<body>
    <div class="toolbar">
        <button onclick="window.print()">Print</button>
    </div>

    <div class="report">
        <div class="header">
            <h1>Voucher Claims Report</h1>
            <p class="meta">
                {{ $vouchers->count() }} voucher{{ $vouchers->count() !== 1 ? 's' : '' }}
                @if (request('status')) &middot; Status: {{ ucfirst(request('status')) }} @endif
                @if (request('q')) &middot; Search: "{{ request('q') }}" @endif
                &middot; Generated {{ now()->format('d M Y, g:i A') }}
            </p>
        </div>

        @if ($vouchers->isEmpty())
            <p style="color:#94a3b8; text-align:center; padding:32px 0;">No voucher claims found.</p>
        @else
            <table>
                <thead>
                    <tr>
                        <th>Claimed</th>
                        <th>Patient</th>
                        <th>Promotion</th>
                        <th>Code</th>
                        <th>Discount</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($vouchers as $voucher)
                        <tr>
                            <td>{{ $voucher->created_at?->format('d M Y, g:i A') ?: '—' }}</td>
                            <td>
                                <div>{{ $voucher->patient?->name ?: '—' }}</div>
                                <div style="color:#94a3b8; font-size:12px;">{{ $voucher->patient?->nric ?: '' }}</div>
                            </td>
                            <td>{{ $voucher->promotion?->title ?: '—' }}</td>
                            <td class="code">{{ $voucher->code }}</td>
                            <td>{{ $voucher->promotion?->cta_text ?? $voucher->promotion?->promo_code ?? '—' }}</td>
                            <td><span class="status {{ $voucher->status }}">{{ $voucher->status }}</span></td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @endif

        <div class="footer">
            For internal record / audit purposes only.
        </div>
    </div>
</body>
</html>
