@php
    $brandName = $info['contact_company_name'] ?: 'He Medical Clinic';
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Contact Us | {{ $brandName }}</title>
    <style>
        :root {
            --primary: #0F1B3D;
            --accent: #00C9A7;
            --text: #24304d;
            --muted: #6b7590;
            --border: #e6e9f2;
            --bg: #f6f8fc;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            color: var(--text);
            background: var(--bg);
            line-height: 1.7;
            -webkit-font-smoothing: antialiased;
        }
        .header {
            background: linear-gradient(135deg, var(--primary) 0%, #1d2b5f 100%);
            color: #fff;
            padding: 48px 20px 40px;
            text-align: center;
        }
        .header h1 { font-size: 30px; font-weight: 700; margin-bottom: 8px; }
        .header .meta { font-size: 14px; opacity: 0.8; }
        .brand-badge {
            display: inline-block;
            margin-bottom: 16px;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: var(--accent);
        }
        .container { max-width: 780px; margin: 0 auto; padding: 32px 20px 64px; }
        .card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 32px 28px;
            box-shadow: 0 1px 3px rgba(15, 27, 61, 0.06);
        }
        .section { margin-bottom: 28px; }
        .section:last-child { margin-bottom: 0; }
        h2 {
            font-size: 18px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 12px;
        }
        .info-row {
            display: flex;
            gap: 14px;
            align-items: flex-start;
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
        }
        .info-row:last-child { border-bottom: none; }
        .info-icon {
            width: 38px;
            height: 38px;
            flex-shrink: 0;
            border-radius: 10px;
            background: rgba(0, 201, 167, 0.12);
            color: var(--accent);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .info-label { font-size: 12px; color: var(--muted); text-transform: uppercase; letter-spacing: 0.5px; }
        .info-value { font-size: 15px; color: var(--text); font-weight: 500; word-break: break-word; }
        .info-value a { color: var(--accent); text-decoration: none; }
        .info-value a:hover { text-decoration: underline; }
        .hours-list { margin: 0; padding: 0; list-style: none; }
        .hours-list li {
            font-size: 14px;
            color: var(--text);
            padding: 6px 0;
        }
        .hours-list li::before { content: "•"; color: var(--accent); margin-right: 10px; }
        .footer {
            text-align: center;
            color: var(--muted);
            font-size: 13px;
            padding: 0 20px 40px;
        }
        .footer a { color: var(--accent); text-decoration: none; }
    </style>
</head>
<body>
    <div class="header">
        <span class="brand-badge">{{ $brandName }}</span>
        <h1>Contact Us</h1>
        <div class="meta">We'd love to hear from you</div>
    </div>

    <div class="container">
        <div class="card">
            <div class="section">
                <h2>Get in Touch</h2>
                <div class="info-row">
                    <div class="info-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M3 21h18M6 18v-6m4 6v-6m4 6v-6m4 6v-6M5 10l7-7 7 7"/>
                        </svg>
                    </div>
                    <div>
                        <div class="info-label">Company</div>
                        <div class="info-value">{{ $info['contact_company_name'] }}</div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                        </svg>
                    </div>
                    <div>
                        <div class="info-label">Email</div>
                        <div class="info-value">
                            <a href="mailto:{{ $info['contact_support_email'] }}">{{ $info['contact_support_email'] }}</a>
                        </div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/>
                        </svg>
                    </div>
                    <div>
                        <div class="info-label">Phone</div>
                        <div class="info-value">
                            <a href="tel:{{ preg_replace('/[^0-9+]/', '', $info['contact_phone']) }}">{{ $info['contact_phone'] }}</a>
                        </div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/>
                            <path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/>
                        </svg>
                    </div>
                    <div>
                        <div class="info-label">Website</div>
                        <div class="info-value">
                            <a href="{{ $info['contact_website'] }}" target="_blank" rel="noopener">{{ $info['contact_website'] }}</a>
                        </div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                            <path d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                        </svg>
                    </div>
                    <div>
                        <div class="info-label">Address</div>
                        <div class="info-value">{{ $info['contact_address'] }}</div>
                    </div>
                </div>
            </div>

            @if (! empty($info['operating_hours']))
                <div class="section">
                    <h2>Operating Hours</h2>
                    <ul class="hours-list">
                        @foreach ($info['operating_hours'] as $hour)
                            <li>{{ $hour }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif
        </div>
    </div>

    <div class="footer">
        &copy; {{ date('Y') }} {{ $brandName }}. All rights reserved.
    </div>
</body>
</html>
