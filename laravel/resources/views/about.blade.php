@php
    $brandName = $info['branding_app_name'] ?: 'He Medical Clinic';
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>About {{ $brandName }} | {{ $brandName }}</title>
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
            margin-bottom: 8px;
        }
        p { font-size: 15px; color: var(--text); white-space: pre-line; }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 14px;
        }
        @media (min-width: 560px) {
            .info-grid { grid-template-columns: 1fr 1fr; }
        }
        .info-box {
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 16px;
        }
        .info-label { font-size: 12px; color: var(--muted); text-transform: uppercase; letter-spacing: 0.5px; }
        .info-value { font-size: 15px; color: var(--text); font-weight: 600; word-break: break-word; margin-top: 2px; }
        .info-value a { color: var(--accent); text-decoration: none; }
        .info-value a:hover { text-decoration: underline; }
        .version-pill {
            display: inline-block;
            background: rgba(0, 201, 167, 0.12);
            color: var(--accent);
            font-size: 13px;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 999px;
            margin-top: 12px;
        }
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
        <span class="brand-badge">About</span>
        <h1>{{ $brandName }}</h1>
        <div class="meta">Your Health, Simplified</div>
    </div>

    <div class="container">
        <div class="card">
            @if (! empty($info['about_app_description']))
                <div class="section">
                    <h2>About the App</h2>
                    <p>{{ $info['about_app_description'] }}</p>
                </div>
            @endif

            <div class="section">
                <h2>Company Information</h2>
                <div class="info-grid">
                    <div class="info-box">
                        <div class="info-label">App Name</div>
                        <div class="info-value">{{ $brandName }}</div>
                    </div>
                    <div class="info-box">
                        <div class="info-label">Company</div>
                        <div class="info-value">{{ $info['contact_company_name'] }}</div>
                    </div>
                    <div class="info-box">
                        <div class="info-label">Website</div>
                        <div class="info-value">
                            <a href="{{ $info['contact_website'] }}" target="_blank" rel="noopener">{{ $info['contact_website'] }}</a>
                        </div>
                    </div>
                    <div class="info-box">
                        <div class="info-label">Support Email</div>
                        <div class="info-value">
                            <a href="mailto:{{ $info['contact_support_email'] }}">{{ $info['contact_support_email'] }}</a>
                        </div>
                    </div>
                </div>
                @if (! empty($info['about_app_version']))
                    <span class="version-pill">Version {{ $info['about_app_version'] }}</span>
                @endif
            </div>
        </div>
    </div>

    <div class="footer">
        &copy; {{ date('Y') }} {{ $info['contact_company_name'] ?: $brandName }}. All rights reserved.
    </div>
</body>
</html>
