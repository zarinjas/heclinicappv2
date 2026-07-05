<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login — He Clinic</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="bg-[#F8F9FC] min-h-screen flex items-center justify-center">
    <div class="w-full max-w-md bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
        <div class="text-center mb-8">
            <h1 class="text-2xl font-bold text-[#0F1B3D]">He Clinic Admin</h1>
            <p class="text-gray-500 mt-2 text-sm">Sign in to your account</p>
        </div>

        @if ($errors->any())
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 mb-6 text-sm">
                {{ $errors->first() }}
            </div>
        @endif

        <form method="POST" action="{{ route('admin.login.submit') }}">
            @csrf
            <div class="mb-4">
                <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input
                    type="email"
                    id="email"
                    name="email"
                    value="{{ old('email') }}"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm focus:border-[#00C9A7] focus:ring-1 focus:ring-[#00C9A7]"
                    placeholder="admin@heclinic.com"
                    required
                    autofocus
                >
            </div>
            <div class="mb-6">
                <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <input
                    type="password"
                    id="password"
                    name="password"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm focus:border-[#00C9A7] focus:ring-1 focus:ring-[#00C9A7]"
                    placeholder="••••••••"
                    required
                >
            </div>
            <button
                type="submit"
                class="w-full bg-[#00C9A7] hover:bg-[#00B094] text-white font-semibold py-2.5 px-4 rounded-lg text-sm transition-colors"
            >
                Sign In
            </button>
        </form>
    </div>
</body>
</html>
