@extends('layouts.admin')

@section('title', 'Claude / MCP')
@section('subtitle', 'Sambungkan Claude ke admin panel supaya admin boleh suruh Claude buat kerja — semak pendaftaran campaign, hantar push, dan buat promo — guna bahasa biasa.')

@section('content')
@php
    $tokenForCopy = $token !== '' ? $token : 'PASTE_TOKEN_DISINI';
    $desktopConfig = json_encode([
        'mcpServers' => [
            'he-clinic-admin' => [
                'command' => 'npx',
                'args' => ['-y', 'mcp-remote', $endpoint, '--header', 'Authorization: Bearer '.$tokenForCopy],
            ],
        ],
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    $nativeConfig = json_encode([
        'mcpServers' => [
            'he-clinic-admin' => [
                'url' => $endpoint,
                'headers' => ['Authorization' => 'Bearer '.$tokenForCopy],
            ],
        ],
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    $claudeCodeCommand = 'claude mcp add --transport http he-clinic-admin '.$endpoint.' --header "Authorization: Bearer '.$tokenForCopy.'"';
@endphp

<div class="max-w-5xl mx-auto space-y-6">

    {{-- Status + controls --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex flex-wrap items-start justify-between gap-4">
            <div class="max-w-xl">
                <div class="flex items-center gap-3 mb-2">
                    <h2 class="text-lg font-semibold text-[#0F1B3D]">Status sambungan</h2>
                    @if ($enabled && $token !== '')
                        <span class="text-xs font-medium px-2.5 py-1 rounded-full bg-green-100 text-green-700">Sedia digunakan</span>
                    @elseif ($enabled && $token === '')
                        <span class="text-xs font-medium px-2.5 py-1 rounded-full bg-amber-100 text-amber-700">Token belum dijana</span>
                    @else
                        <span class="text-xs font-medium px-2.5 py-1 rounded-full bg-gray-200 text-gray-600">Dimatikan</span>
                    @endif
                </div>
                <p class="text-sm text-gray-500">
                    Apabila diaktifkan, Claude boleh membaca data admin dan melakukan tindakan (hantar push, buat promo)
                    menggunakan token di bawah. Setiap tindakan direkodkan di bahagian <strong>Sejarah aktiviti</strong>.
                </p>
            </div>

            <div class="flex flex-wrap gap-2">
                <form method="POST" action="{{ route('admin.mcp.toggle') }}">
                    @csrf
                    <input type="hidden" name="enable" value="{{ $enabled ? 0 : 1 }}">
                    <button type="submit"
                            class="px-4 py-2 rounded-lg text-sm font-medium {{ $enabled
                                ? 'bg-white border border-gray-300 text-gray-700 hover:bg-gray-50'
                                : 'bg-[#00C9A7] text-white hover:bg-[#00b596]' }}">
                        {{ $enabled ? 'Matikan MCP' : 'Aktifkan MCP' }}
                    </button>
                </form>

                <form method="POST" action="{{ route('admin.mcp.regenerate') }}"
                      onsubmit="return confirm('Jana token baharu? Token lama akan terus tidak berfungsi dan Claude perlu dikemas kini.');">
                    @csrf
                    <button type="submit"
                            class="px-4 py-2 rounded-lg text-sm font-medium bg-white border border-gray-300 text-gray-700 hover:bg-gray-50">
                        Jana token baharu
                    </button>
                </form>
            </div>
        </div>
    </div>

    {{-- Connection details --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Maklumat sambungan</h2>
        <p class="text-sm text-gray-500 mb-5">Dua nilai ini yang akan dimasukkan ke dalam aplikasi Claude.</p>

        <div class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Server URL (endpoint)</label>
                <div class="flex gap-2">
                    <input id="mcp-endpoint" type="text" readonly value="{{ $endpoint }}"
                           class="flex-1 px-4 py-2 text-sm border border-gray-200 rounded-lg bg-gray-50 font-mono">
                    <button type="button" onclick="copyField('mcp-endpoint', this)"
                            class="px-4 py-2 rounded-lg text-sm font-medium bg-[#0F1B3D] text-white hover:bg-[#1e2d52]">
                        Copy
                    </button>
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-[#0F1B3D] mb-1">Token akses</label>
                @if ($token !== '')
                    <div class="flex gap-2">
                        <input id="mcp-token" type="text" readonly value="{{ $token }}"
                               class="flex-1 px-4 py-2 text-sm border border-gray-200 rounded-lg bg-gray-50 font-mono">
                        <button type="button" onclick="copyField('mcp-token', this)"
                                class="px-4 py-2 rounded-lg text-sm font-medium bg-[#0F1B3D] text-white hover:bg-[#1e2d52]">
                            Copy
                        </button>
                    </div>
                    <p class="mt-1 text-xs text-gray-400">Rahsia. Jangan kongsi. Kalau bocor, tekan “Jana token baharu”.</p>
                @else
                    <div class="flex items-center gap-3">
                        <span class="text-sm text-gray-500">Belum ada token. Tekan “Aktifkan MCP” atau “Jana token baharu”.</span>
                    </div>
                @endif
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2 text-xs text-gray-500">
                <p>Token dijana: <span class="font-medium text-gray-700">{{ $generatedAt ?: '—' }}</span></p>
                <p>Kali terakhir digunakan: <span class="font-medium text-gray-700">{{ $lastUsedAt ?: 'Belum pernah' }}</span></p>
            </div>
        </div>
    </div>

    {{-- Setup steps --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Cara sambung ke Claude</h2>
        <p class="text-sm text-gray-500 mb-6">Pilih salah satu cara di bawah. Cara A paling mudah dan sesuai untuk kebanyakan orang.</p>

        @if ($token === '')
            <div class="bg-amber-50 border border-amber-200 text-amber-800 rounded-lg px-4 py-3 mb-6 text-sm">
                Jana token dahulu (butang di atas) sebelum ikut langkah di bawah.
            </div>
        @endif

        {{-- Option A --}}
        <div class="border border-gray-200 rounded-xl overflow-hidden mb-5">
            <div class="bg-gray-50 px-4 py-3 border-b border-gray-200">
                <h3 class="text-sm font-semibold text-[#0F1B3D]">Cara A — Claude Desktop (guna mcp-remote) · disyorkan</h3>
            </div>
            <div class="p-4 space-y-4">
                <ol class="list-decimal ml-5 space-y-2 text-sm text-gray-600">
                    <li>Pasang <strong>Node.js</strong> (versi 18 ke atas) dari <span class="font-mono text-xs">nodejs.org</span>. Ini diperlukan untuk <span class="font-mono text-xs">npx</span>.</li>
                    <li>Buka fail konfigurasi Claude Desktop:
                        <div class="mt-1 font-mono text-xs text-gray-700 space-y-1">
                            <div>macOS: <span class="select-all">~/Library/Application Support/Claude/claude_desktop_config.json</span></div>
                            <div>Windows: <span class="select-all">%APPDATA%\Claude\claude_desktop_config.json</span></div>
                        </div>
                    </li>
                    <li>Buka fail itu dan tambah blok di bawah ke dalam <span class="font-mono text-xs">mcpServers</span>. Kalau fail masih kosong, tampal keseluruhan blok.</li>
                    <li>Simpan fail, kemudian <strong>tutup dan buka semula</strong> Claude Desktop.</li>
                    <li>Dalam Claude, tekan ikon tools/connector untuk pastikan <span class="font-mono text-xs">he-clinic-admin</span> muncul.</li>
                </ol>

                <div>
                    <div class="flex items-center justify-between mb-1">
                        <span class="text-xs font-medium text-gray-500">claude_desktop_config.json</span>
                        <button type="button" onclick="copyField('desktop-config', this)" class="text-xs font-medium text-[#00C9A7] hover:underline">Copy</button>
                    </div>
                    <pre id="desktop-config" class="bg-[#0F1B3D] text-gray-100 text-xs rounded-lg p-4 overflow-x-auto">{{ $desktopConfig }}</pre>
                </div>
            </div>
        </div>

        {{-- Option B --}}
        <div class="border border-gray-200 rounded-xl overflow-hidden mb-5">
            <div class="bg-gray-50 px-4 py-3 border-b border-gray-200">
                <h3 class="text-sm font-semibold text-[#0F1B3D]">Cara B — Claude Desktop versi baharu (remote URL terus)</h3>
            </div>
            <div class="p-4 space-y-3">
                <p class="text-sm text-gray-600">Jika versi Claude Desktop anda menyokong “remote MCP server”, guna blok ini dalam fail konfigurasi yang sama (tidak perlu Node.js):</p>
                <div>
                    <div class="flex items-center justify-between mb-1">
                        <span class="text-xs font-medium text-gray-500">claude_desktop_config.json</span>
                        <button type="button" onclick="copyField('native-config', this)" class="text-xs font-medium text-[#00C9A7] hover:underline">Copy</button>
                    </div>
                    <pre id="native-config" class="bg-[#0F1B3D] text-gray-100 text-xs rounded-lg p-4 overflow-x-auto">{{ $nativeConfig }}</pre>
                </div>
            </div>
        </div>

        {{-- Option C --}}
        <div class="border border-gray-200 rounded-xl overflow-hidden">
            <div class="bg-gray-50 px-4 py-3 border-b border-gray-200">
                <h3 class="text-sm font-semibold text-[#0F1B3D]">Cara C — Claude Code (terminal)</h3>
            </div>
            <div class="p-4 space-y-3">
                <p class="text-sm text-gray-600">Jika anda guna Claude Code, jalankan arahan ini sekali sahaja:</p>
                <div>
                    <div class="flex items-center justify-between mb-1">
                        <span class="text-xs font-medium text-gray-500">Terminal</span>
                        <button type="button" onclick="copyField('claude-code-cmd', this)" class="text-xs font-medium text-[#00C9A7] hover:underline">Copy</button>
                    </div>
                    <pre id="claude-code-cmd" class="bg-[#0F1B3D] text-gray-100 text-xs rounded-lg p-4 overflow-x-auto whitespace-pre-wrap">{{ $claudeCodeCommand }}</pre>
                </div>
            </div>
        </div>
    </div>

    {{-- Test / example prompts --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Cuba uji</h2>
        <p class="text-sm text-gray-500 mb-4">Selepas Claude disambungkan, taip arahan seperti ini. Claude akan panggil tool yang betul secara automatik.</p>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
            @foreach ([
                'Tunjuk ringkasan klinik minggu ini (get_dashboard_stats).',
                'Siapa yang daftar dari campaign instagram_july bulan ni?',
                'Buat laporan campaign untuk bulan lepas — campaign mana paling ramai daftar?',
                'Senaraikan semua promo yang masih aktif.',
                'Buat promo "Diskaun 20%" sah hingga 31 Disember untuk semua patient.',
                'Hantar push kepada semua: "Promosi 20% hari ini! Tapai sekarang."',
                'Hantar notifikasi kepada semua yang daftar dari campaign instagram_july.',
            ] as $example)
                <div class="flex gap-2 bg-gray-50 border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-700">
                    <span class="text-[#00C9A7] font-bold">›</span>
                    <span>{{ $example }}</span>
                </div>
            @endforeach
        </div>

        <div class="mt-4 bg-blue-50 border border-blue-200 text-blue-800 rounded-lg px-4 py-3 text-sm">
            <strong>Penting:</strong> Untuk tindakan yang menghantar mesej kepada patient (push / promo), Claude akan tunjuk draf dahulu dan tunggu pengesahan anda.
            Semak betul-betul sebelum tekan “ya”.
        </div>
    </div>

    {{-- Tools --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Tool yang tersedia untuk Claude</h2>
        <p class="text-sm text-gray-500 mb-4">Ini yang Claude boleh lakukan melalui sambungan ini.</p>

        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="text-left text-xs uppercase tracking-wide text-gray-500 border-b border-gray-200">
                        <th class="py-2 pr-4">Tool</th>
                        <th class="py-2 pr-4">Keterangan</th>
                        <th class="py-2">Jenis</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @foreach ($tools as $tool)
                        @php $isWrite = in_array($tool['name'], $writeTools, true); @endphp
                        <tr class="align-top">
                            <td class="py-3 pr-4 font-mono text-xs text-[#0F1B3D] whitespace-nowrap">{{ $tool['name'] }}</td>
                            <td class="py-3 pr-4 text-gray-600">{{ $tool['description'] }}</td>
                            <td class="py-3">
                                @if ($isWrite)
                                    <span class="text-xs font-medium px-2 py-0.5 rounded-full bg-amber-100 text-amber-700 whitespace-nowrap">Tulis</span>
                                @else
                                    <span class="text-xs font-medium px-2 py-0.5 rounded-full bg-green-100 text-green-700 whitespace-nowrap">Baca</span>
                                @endif
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    {{-- Campaign attribution note --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Macam mana “campaign” dikenal pasti</h2>
        <p class="text-sm text-gray-600">
            Sistem belum ada jadual campaign yang berasingan. Buat masa ini, tool campaign memadankan
            <span class="font-mono text-xs">patients.referred_by</span> (medan rujukan yang diisi semasa pendaftaran di app)
            atau <strong>tag / nota</strong> pada patient di admin panel.
        </p>
        <p class="text-sm text-gray-600 mt-2">
            Jadi pastikan nilai campaign konsisten — contohnya <span class="font-mono text-xs">instagram_july</span>,
            <span class="font-mono text-xs">tiktok_raya</span>. Kalau app menghantar nilai lain setiap kali, laporan akan berpecah.
        </p>
    </div>

    {{-- Activity --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-[#0F1B3D] mb-1">Sejarah aktiviti</h2>
        <p class="text-sm text-gray-500 mb-4">20 tindakan terakhir yang dibuat melalui Claude / MCP.</p>

        @if ($logs->isEmpty())
            <p class="text-sm text-gray-400">Belum ada aktiviti.</p>
        @else
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="text-left text-xs uppercase tracking-wide text-gray-500 border-b border-gray-200">
                            <th class="py-2 pr-4">Masa</th>
                            <th class="py-2 pr-4">Tool</th>
                            <th class="py-2 pr-4">Status</th>
                            <th class="py-2">Ringkasan</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        @foreach ($logs as $log)
                            <tr class="align-top">
                                <td class="py-3 pr-4 text-gray-500 whitespace-nowrap">{{ optional($log->created_at)->format('d M Y, H:i') }}</td>
                                <td class="py-3 pr-4 font-mono text-xs text-[#0F1B3D] whitespace-nowrap">{{ $log->tool }}</td>
                                <td class="py-3 pr-4">
                                    <span class="text-xs font-medium px-2 py-0.5 rounded-full {{ $log->status === 'success' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700' }}">
                                        {{ $log->status }}
                                    </span>
                                </td>
                                <td class="py-3 text-gray-600 max-w-md">
                                    <span class="line-clamp-3 break-words">{{ \Illuminate\Support\Str::limit($log->summary, 220) }}</span>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>

    {{-- Security --}}
    <div class="bg-amber-50 border border-amber-200 rounded-xl p-6">
        <h2 class="text-base font-semibold text-amber-900 mb-2">Nota keselamatan</h2>
        <ul class="list-disc ml-5 space-y-1 text-sm text-amber-800">
            <li>Token memberi akses peringkat admin. Jaga seperti kata laluan.</li>
            <li>Jika token bocor atau staf berhenti, tekan <strong>Jana token baharu</strong> — token lama terus mati.</li>
            <li>Matikan MCP (<strong>Matikan MCP</strong>) apabila tidak digunakan.</li>
            <li>Semua tindakan tulis direkodkan di <strong>Sejarah aktiviti</strong> untuk semakan.</li>
            <li>Nombor telefon & emel dipaparkan bertopeng kepada Claude; buka admin panel untuk maklumat penuh.</li>
        </ul>
    </div>
</div>
@endsection

@push('scripts')
<script>
    function copyField(id, button) {
        const el = document.getElementById(id);
        if (!el) return;

        const text = (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') ? el.value : el.textContent;
        const done = () => {
            const original = button.textContent;
            button.textContent = 'Copied!';
            setTimeout(() => { button.textContent = original; }, 1500);
        };

        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(text).then(done).catch(fallback);
        } else {
            fallback();
        }

        function fallback() {
            const ta = document.createElement('textarea');
            ta.value = text;
            ta.style.position = 'fixed';
            ta.style.opacity = '0';
            document.body.appendChild(ta);
            ta.select();
            try { document.execCommand('copy'); done(); } catch (e) { alert('Copy failed — sila salin secara manual.'); }
            document.body.removeChild(ta);
        }
    }
</script>
@endpush
