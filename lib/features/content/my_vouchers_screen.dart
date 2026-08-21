import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../backend/api_requests/voucher_api.dart';
import '../../core/services/models/claimed_voucher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_toast.dart';
import 'widgets/voucher_code_sheet.dart';

class MyVouchersScreen extends StatefulWidget {
  const MyVouchersScreen({super.key});

  @override
  State<MyVouchersScreen> createState() => _MyVouchersScreenState();
}

class _MyVouchersScreenState extends State<MyVouchersScreen> {
  List<ClaimedVoucher> _vouchers = [];
  bool _loading = true;
  String? _error;

  List<ClaimedVoucher> get _active =>
      _vouchers.where((v) => v.isActive).toList();
  List<ClaimedVoucher> get _closed =>
      _vouchers.where((v) => !v.isActive).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await VoucherApi.getMyVouchersCall.call();
      if (!mounted) return;

      if (response.succeeded) {
        final raw = GetMyVouchersCall.rawList(response.jsonBody) ?? [];
        final vouchers = raw
            .whereType<Map<String, dynamic>>()
            .map(ClaimedVoucher.fromJson)
            .toList();
        setState(() {
          _vouchers = vouchers;
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _loading = false;
          _error = 'Please login to view your vouchers.';
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Unable to load your vouchers.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    try {
      final response = await VoucherApi.getMyVouchersCall.call();
      if (!mounted) return;
      final raw = GetMyVouchersCall.rawList(response.jsonBody) ?? [];
      final vouchers = raw
          .whereType<Map<String, dynamic>>()
          .map(ClaimedVoucher.fromJson)
          .toList();
      setState(() {
        _vouchers = vouchers;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, message: 'Refresh failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
        appBar: AppAppBar.sub(title: 'My Vouchers'),
        body: Column(
          children: [
            TabBar(
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Used / Expired'),
              ],
            ),
            Expanded(child: _buildBody(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const Center(child: AppLoader());
    }

    if (_error != null) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: _error!,
        ctaLabel: 'Try Again',
        onCtaTap: _load,
      );
    }

    if (_vouchers.isEmpty) {
      return const AppEmptyState(
        icon: Icons.confirmation_num_outlined,
        title: 'No vouchers yet',
        subtitle: 'Claim an offer from the Vouchers screen to see it here.',
      );
    }

    return TabBarView(
      children: [
        _buildList(_active, isDark),
        _buildList(_closed, isDark),
      ],
    );
  }

  Widget _buildList(List<ClaimedVoucher> vouchers, bool isDark) {
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _refresh,
      child: _buildListContent(vouchers, isDark),
    );
  }

  Widget _buildListContent(List<ClaimedVoucher> vouchers, bool isDark) {
    if (vouchers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 80),
          AppEmptyState(
            icon: Icons.confirmation_num_outlined,
            title: 'Nothing here yet',
            subtitle: 'Claim a voucher to see it in this tab.',
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < vouchers.length; i++) ...[
          _ClaimedCard(
            voucher: vouchers[i],
            isDark: isDark,
            onTap: vouchers[i].isActive ? () => _showCode(vouchers[i]) : null,
          ),
          if (i < vouchers.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _showCode(ClaimedVoucher voucher) {
    VoucherCodeSheet.show(
      context,
      code: voucher.code,
      discount: voucher.discount,
      title: voucher.title,
    );
  }
}

class _ClaimedCard extends StatelessWidget {
  final ClaimedVoucher voucher;
  final bool isDark;
  final VoidCallback? onTap;

  const _ClaimedCard({
    required this.voucher,
    required this.isDark,
    this.onTap,
  });

  List<Color> get _gradient {
    const colors = [
      [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
      [Color(0xFF131C3C), Color(0xFF3B8DFF)],
      [Color(0xFF27F5A3), Color(0xFF2868F5)],
      [Color(0xFFF5A623), Color(0xFFF54636)],
    ];
    return colors[voucher.id % colors.length];
  }

  String get _discount => voucher.discount ?? '';

  String get _subtitle {
    if (voucher.isUsed) {
      final used = voucher.usedAt;
      return used != null ? 'Used on ${DateFormat('d MMM yyyy').format(used)}' : 'Used';
    }
    if (!voucher.isActive) {
      final expired = voucher.expiresAt;
      return expired != null
          ? 'Expired on ${DateFormat('d MMM yyyy').format(expired)}'
          : 'Expired';
    }
    final expires = voucher.expiresAt;
    return expires != null
        ? 'Valid until ${DateFormat('d MMM yyyy').format(expires)}'
        : 'No expiry';
  }

  @override
  Widget build(BuildContext context) {
    final opacity = voucher.isActive ? 1.0 : 0.55;
    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _gradient),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.radiusLG),
                    bottomLeft: Radius.circular(AppRadius.radiusLG),
                  ),
                ),
                child: Center(
                  child: Text(
                    _discount,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.title,
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voucher.code,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (voucher.isActive)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.qr_code_rounded, color: AppColors.accent, size: 24),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
