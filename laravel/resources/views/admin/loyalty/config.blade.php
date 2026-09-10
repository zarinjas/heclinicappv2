@extends('layouts.admin')

@section('title', 'Loyalty — Settings')

@section('subtitle', 'Configure how points are earned, redeemed, and how long they last')

@section('content')
    <form method="POST" action="{{ route('admin.loyalty.config.update') }}" class="max-w-2xl">
        @csrf

        <div class="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div class="p-6 space-y-6">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="earn_rate" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Earn Rate (points per RM 1)
                        </label>
                        <input
                            type="number"
                            step="0.01"
                            name="earn_rate"
                            id="earn_rate"
                            value="{{ old('earn_rate', $config['earn_rate']) }}"
                            min="0"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('earn_rate') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">Points earned = invoice total × earn rate.</p>
                        @error('earn_rate')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="redemption_rate" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Redemption Rate (RM per point)
                        </label>
                        <input
                            type="number"
                            step="0.001"
                            name="redemption_rate"
                            id="redemption_rate"
                            value="{{ old('redemption_rate', $config['redemption_rate']) }}"
                            min="0"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('redemption_rate') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">Discount value = points × redemption rate.</p>
                        @error('redemption_rate')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="min_redemption" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Minimum Redemption (points)
                        </label>
                        <input
                            type="number"
                            name="min_redemption"
                            id="min_redemption"
                            value="{{ old('min_redemption', $config['min_redemption']) }}"
                            min="1"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('min_redemption') border-red-300 @enderror"
                        >
                        @error('min_redemption')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="max_per_txn" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Max Points Per Transaction
                        </label>
                        <input
                            type="number"
                            name="max_per_txn"
                            id="max_per_txn"
                            value="{{ old('max_per_txn', $config['max_per_txn']) }}"
                            min="1"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('max_per_txn') border-red-300 @enderror"
                        >
                        @error('max_per_txn')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label for="expiry_months" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Points Expiry (months)
                        </label>
                        <input
                            type="number"
                            name="expiry_months"
                            id="expiry_months"
                            value="{{ old('expiry_months', $config['expiry_months']) }}"
                            min="1"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('expiry_months') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">Earned points expire after this many months.</p>
                        @error('expiry_months')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="redemption_expiry_days" class="block text-sm font-medium text-[#0F1B3D] mb-1">
                            Redemption Code Validity (days)
                        </label>
                        <input
                            type="number"
                            name="redemption_expiry_days"
                            id="redemption_expiry_days"
                            value="{{ old('redemption_expiry_days', $config['redemption_expiry_days']) }}"
                            min="1"
                            class="w-full px-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#00C9A7] focus:border-transparent outline-none @error('redemption_expiry_days') border-red-300 @enderror"
                        >
                        <p class="mt-1 text-xs text-gray-400">How long a redemption code stays valid before it expires.</p>
                        @error('redemption_expiry_days')
                            <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-xl flex items-center gap-3">
                <button type="submit"
                        class="px-6 py-2 text-sm font-medium text-white bg-[#00C9A7] rounded-lg hover:bg-[#00b093] transition-colors">
                    Save Settings
                </button>
            </div>
        </div>
    </form>
@endsection
