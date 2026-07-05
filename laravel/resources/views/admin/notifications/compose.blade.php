@extends('layouts.admin')

@section('title', 'Compose Notification')

@section('subtitle', 'Create a new push notification')

@section('content')
    <form method="POST" action="{{ route('admin.notifications.send') }}" class="max-w-2xl">
        @csrf

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div>
                    <label for="title" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Title <span class="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        name="title"
                        id="title"
                        value="{{ old('title') }}"
                        required
                        maxlength="255"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('title') border-red-300 @enderror"
                        placeholder="e.g. New Health Article Available"
                    >
                    <p class="mt-1 text-xs text-gray-400"><span id="title-chars">0</span>/255 characters</p>
                    @error('title')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="body" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                        Body <span class="text-red-500">*</span>
                    </label>
                    <textarea
                        name="body"
                        id="body"
                        rows="6"
                        required
                        maxlength="2000"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('body') border-red-300 @enderror"
                        placeholder="Write your notification message..."
                    >{{ old('body') }}</textarea>
                    <p class="mt-1 text-xs text-gray-400"><span id="body-chars">0</span>/2000 characters</p>
                    @error('body')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="image_url" class="block text-sm font-medium text-[#0F1B3D] mb-1">Image URL</label>
                    <input
                        type="url"
                        name="image_url"
                        id="image_url"
                        value="{{ old('image_url') }}"
                        maxlength="500"
                        class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('image_url') border-red-300 @enderror"
                        placeholder="https://example.com/image.jpg"
                    >
                    <p class="mt-1 text-xs text-gray-400">Optional. Provide a valid HTTPS URL for the notification image.</p>
                    @error('image_url')
                        <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    Save Draft
                </button>
                <a href="{{ route('admin.dashboard') }}"
                   class="px-6 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                    Cancel
                </a>
            </div>
        </div>
    </form>
@endsection

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        function setupCharCount(inputId, countId) {
            const input = document.getElementById(inputId);
            const count = document.getElementById(countId);
            if (input && count) {
                count.textContent = input.value.length;
                input.addEventListener('input', function () {
                    count.textContent = this.value.length;
                });
            }
        }

        setupCharCount('title', 'title-chars');
        setupCharCount('body', 'body-chars');
    });
</script>
@endpush
