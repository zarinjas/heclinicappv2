@php
    $brandName = optional(\App\Models\Setting::where('key', 'branding_app_name')->first())->value ?: 'He Medical Clinic';
    $deleted = session('success');
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Delete Account | {{ $brandName }}</title>
    <style>
        :root {
            --primary: #0F1B3D;
            --accent: #00C9A7;
            --danger: #E5484D;
            --danger-soft: #FEEBEC;
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
        .container { max-width: 640px; margin: 0 auto; padding: 32px 20px 64px; }
        .card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 32px 28px;
            box-shadow: 0 1px 3px rgba(15, 27, 61, 0.06);
        }
        .card h2 { font-size: 18px; font-weight: 700; color: var(--primary); margin-bottom: 8px; }
        .card .lead { font-size: 14px; color: var(--muted); margin-bottom: 24px; }
        .banner {
            border-radius: 10px;
            padding: 14px 16px;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 20px;
        }
        .banner.success { background: #E6F7F0; color: #0E7A4D; border: 1px solid #B5EBD6; }
        .banner.error { background: var(--danger-soft); color: var(--danger); border: 1px solid #F5C6C9; }
        .field { margin-bottom: 18px; }
        .field label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 6px;
        }
        .field input {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 15px;
            color: var(--text);
            outline: none;
            background: #fff;
        }
        .field input:focus { border-color: var(--accent); box-shadow: 0 0 0 3px rgba(0, 201, 167, 0.15); }
        .field .hint { font-size: 12px; color: var(--muted); margin-top: 5px; }
        .field .error { font-size: 13px; color: var(--danger); margin-top: 5px; }
        .btn {
            width: 100%;
            padding: 14px 16px;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            background: var(--danger);
            color: #fff;
            margin-top: 8px;
        }
        .btn:hover { filter: brightness(0.95); }
        .note {
            font-size: 12px;
            color: var(--muted);
            margin-top: 18px;
            border-top: 1px solid var(--border);
            padding-top: 16px;
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
        <span class="brand-badge">{{ $brandName }}</span>
        <h1>Delete Account</h1>
        <div class="meta">Request permanent deletion of your account</div>
    </div>

    <div class="container">
        <div class="card">
            @if ($deleted)
                <div class="banner success">✓ {{ $deleted }}</div>
                <h2>What happens next?</h2>
                <p class="lead">
                    Your account has been deactivated. Your data will no longer be
                    accessible and you will not be able to sign in to the app with
                    this account again. If you change your mind, please contact us
                    for assistance.
                </p>
            @else
                <h2>Delete your account</h2>
                <p class="lead">
                    This action is permanent and cannot be undone. Your account
                    will be deactivated immediately and you will lose access to
                    your appointments and records in the app.
                </p>

                @if ($errors->any())
                    <div class="banner error">
                        {{ $errors->first() }}
                    </div>
                @endif

                <form method="POST" action="{{ route('account-deletion.submit') }}">
                    @csrf
                    <div class="field">
                        <label for="identifier">IC / Passport, phone number or email</label>
                        <input type="text" id="identifier" name="identifier"
                               value="{{ old('identifier') }}" required
                               autocomplete="username">
                    </div>
                    <div class="field">
                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" required
                               autocomplete="current-password">
                    </div>
                    <button type="submit" class="btn">Delete Account</button>
                </form>

                <p class="note">
                    For security, you must enter the password for the account you
                    are deleting. If you no longer have access to your password,
                    please contact us and we will assist you.
                </p>
            @endif
        </div>
    </div>

    <div class="footer">
        &copy; {{ date('Y') }} {{ $brandName }}. All rights reserved.
    </div>
</body>
</html>
