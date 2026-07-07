<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Dashboard') — He Clinic Admin</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="bg-[#F8F9FC] min-h-screen flex">
    <aside class="w-64 bg-[#0F1B3D] text-white min-h-screen flex-shrink-0">
        <div class="p-6 border-b border-[#1e2d52]">
            <h1 class="text-lg font-bold">He Clinic</h1>
            <p class="text-xs text-gray-400 mt-1">Admin Panel</p>
        </div>

        <nav class="p-4 space-y-1">
            <a href="{{ route('admin.dashboard') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.dashboard') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
                </svg>
                Dashboard
            </a>

            <a href="{{ route('admin.branches.index') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.branches.*') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                </svg>
                Branches
            </a>

            <a href="{{ route('admin.doctors.index') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.doctors.*') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0zm6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Doctors
            </a>

            <a href="{{ route('admin.patients.index') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.patients.*') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
                </svg>
                Patients
            </a>

            <a href="{{ route('admin.appointments.index') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.appointments.*') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                </svg>
                Appointments
            </a>

            <a href="{{ route('admin.calendars.index') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.calendars.*') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                </svg>
                Calendar Setup
            </a>

            <a href="{{ route('admin.whatsapp.index') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.whatsapp.*') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                </svg>
                WhatsApp
            </a>

            <a href="{{ route('admin.notifications.compose') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.notifications.*') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}"
               onclick="event.preventDefault(); toggleNotificationsSubmenu()">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                </svg>
                Notifications
                <svg id="notifications-chevron" class="w-4 h-4 ml-auto transition-transform {{ request()->routeIs('admin.notifications.*') ? 'rotate-90' : '' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                </svg>
            </a>
            <div id="notifications-submenu" class="ml-4 space-y-1 {{ request()->routeIs('admin.notifications.*') ? '' : 'hidden' }}">
                <a href="{{ route('admin.notifications.compose') }}"
                   class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm
                          {{ request()->routeIs('admin.notifications.compose') || request()->routeIs('admin.notifications.send') ? 'text-[#00C9A7] font-medium' : 'text-gray-400 hover:text-white' }}">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                    </svg>
                    Compose
                </a>
                <a href="{{ route('admin.notifications.index') }}"
                   class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm
                          {{ request()->routeIs('admin.notifications.index') || request()->routeIs('admin.notifications.show') ? 'text-[#00C9A7] font-medium' : 'text-gray-400 hover:text-white' }}">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    History
                </a>
            </div>

            <a href="{{ route('admin.cms.sliders.index') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.cms.*') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}"
               onclick="event.preventDefault(); toggleCmsSubmenu()">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"/>
                </svg>
                CMS
                <svg id="cms-chevron" class="w-4 h-4 ml-auto transition-transform {{ request()->routeIs('admin.cms.*') ? 'rotate-90' : '' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                </svg>
            </a>
            <div id="cms-submenu" class="ml-4 space-y-1 {{ request()->routeIs('admin.cms.*') ? '' : 'hidden' }}">
                <a href="{{ route('admin.cms.sliders.index') }}"
                   class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm
                          {{ request()->routeIs('admin.cms.sliders.*') ? 'text-[#00C9A7] font-medium' : 'text-gray-400 hover:text-white' }}">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                    </svg>
                    Sliders
                </a>
            </div>

            <a href="{{ route('admin.branding') }}"
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium
                      {{ request()->routeIs('admin.branding') ? 'bg-[#00C9A7] text-white' : 'text-gray-300 hover:bg-[#1e2d52] hover:text-white' }}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"/>
                </svg>
                Branding
            </a>
        </nav>

        <div class="absolute bottom-0 w-64 p-4 border-t border-[#1e2d52]">
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-gray-400 hover:bg-[#1e2d52] hover:text-white w-full">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                    </svg>
                    Sign Out
                </button>
            </form>
        </div>
    </aside>

    <main class="flex-1 p-8">
        <header class="mb-8">
            <h2 class="text-2xl font-bold text-[#0F1B3D]">@yield('title', 'Dashboard')</h2>
            @hasSection('subtitle')
                <p class="text-sm text-gray-500 mt-1">@yield('subtitle')</p>
            @endif
        </header>

        @if (session('success'))
            <div class="bg-green-50 border border-green-200 text-green-700 rounded-lg px-4 py-3 mb-6 text-sm">
                {{ session('success') }}
            </div>
        @endif

        @if (session('error'))
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 mb-6 text-sm">
                {{ session('error') }}
            </div>
        @endif

        @yield('content')
    </main>

    @stack('scripts')
    <script>
        function toggleNotificationsSubmenu() {
            const submenu = document.getElementById('notifications-submenu');
            const chevron = document.getElementById('notifications-chevron');
            submenu.classList.toggle('hidden');
            chevron.classList.toggle('rotate-90');
        }
        function toggleCmsSubmenu() {
            const submenu = document.getElementById('cms-submenu');
            const chevron = document.getElementById('cms-chevron');
            submenu.classList.toggle('hidden');
            chevron.classList.toggle('rotate-90');
        }
    </script>
</body>
</html>
