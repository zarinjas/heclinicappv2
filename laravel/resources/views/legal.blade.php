@php
    $brandName = optional(\App\Models\Setting::where('key', 'branding_app_name')->first())->value ?: 'He Medical Clinic';
    $sections = $page->sections ?? [];
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $page->title }} | {{ $brandName }}</title>
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
        section { margin-bottom: 28px; }
        section:last-child { margin-bottom: 0; }
        h2 {
            font-size: 18px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 8px;
        }
        p { font-size: 15px; color: var(--text); white-space: pre-line; }
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
        <h1>{{ $page->title }}</h1>
        @if ($page->last_updated)
            <div class="meta">Last updated: {{ $page->last_updated->format('F Y') }}</div>
        @endif
    </div>

    <div class="container">
        <div class="card">
            @forelse ($sections as $section)
                <section>
                    @if (! empty($section['heading']))
                        <h2>{{ $section['heading'] }}</h2>
                    @endif
                    @if (! empty($section['body']))
                        <p>{{ $section['body'] }}</p>
                    @endif
                </section>
            @empty
                <p>This page has no content yet.</p>
            @endforelse
        </div>
    </div>

    <div class="footer">
        &copy; {{ date('Y') }} {{ $brandName }}. All rights reserved.
    </div>
</body>
</html>
