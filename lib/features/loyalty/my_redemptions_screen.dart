import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../backend/api_requests/loyalty_api.dart';
import '../../core/services/models/loyalty_redemption.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_loader.dart';
import '../content/widgets/voucher_code_sheet.dart';

class MyRedemptionsScreen extends StatefulWidget {
  const MyRedemptionsScreen({super.key});

  static const String routeName = '/my-redemptions';

  @override
  State<MyRedemptionsScreen> createState() => _MyRedemptionsScreenState();
}

class _MyRedemptionsScreenState extends State<MyRedemptionsScreen> {
  List<LoyaltyRedemption> _redemptions = [];
  bool _loading = true;
  String? _error;

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
      final response = await LoyaltyApi.getLoyaltyRedemptionsCall.call();
      if (!mounted) return;

      if (response.succeeded) {
        final raw = GetLoyaltyRedemptionsCall.data(response.jsonBody) ?? [];
        final list = raw
            .whereType<Map<String, dynamic>>()
            .map(LoyaltyRedemption.fromJson)
            .toList();
        setState(() {
          _redemptions = list;
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _loading = false;
          _error = 'Please login to view your redemptions.';
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Unable to load your redemptions.';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
      appBar: AppAppBar.sub(title: 'My Redemptions'),
      body: _buildBody(isDark),
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

    if (_redemptions.isEmpty) {
      return const AppEmptyState(
        icon: Icons.card_giftcard_outlined,
        title: 'No redemptions yet',
        subtitle: 'Redeem your points from My Points or He Rewards to see them here.',
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: _redemptions.length,
        itemBuilder: (context, index) {
          final r = _redemptions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space12),
            child: _RedemptionCard(
              redemption: r,
              isDark: isDark,
              onTap: r.isPending ? () => _showCode(r) : null,
            ),
          );
        },
      ),
    );
  }

  void _showCode(LoyaltyRedemption r) {
    VoucherCodeSheet.show(
      context,
      code: r.code,
      discount: '${r.title} · ${r.pointsLabel}',
      title: 'Redemption Code',
    );
  }
}

class _RedemptionCard extends StatelessWidget {
  final LoyaltyRedemption redemption;
  final bool isDark;
  final VoidCallback? onTap;

  const _RedemptionCard({
    required this.redemption,
    required this.isDark,
    this.onTap,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('d MMM yyyy').format(dt);
  }

  Color get _statusColor {
    if (redemption.isPending) return const Color(0xFF10B981);
    if (redemption.isCancelled) return AppColors.error;
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  }

  String get _statusLabel {
    switch (redemption.status) {
      case 'fulfilled':
        return 'Fulfilled';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  String get _subtitle {
    final date = _formatDate(redemption.createdAt);
    if (redemption.isCancelled) return date.isEmpty ? 'Cancelled' : 'Cancelled · $date';
    if (redemption.isFulfilled) return date.isEmpty ? 'Fulfilled' : 'Fulfilled · $date';
    final exp = _formatDate(redemption.expiresAt);
    return exp.isEmpty ? date : 'Valid until $exp';
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final opacity = redemption.isPending ? 1.0 : 0.6;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              redemption.title,
                              style: AppTextStyles.heading3.copyWith(
                                fontSize: 14,
                                color: titleColor,
                              ),
                            ),
                          ),
                          Text(
                            redemption.pointsLabel,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        redemption.code,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (redemption.discountLabel.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          redemption.discountLabel,
                          style: AppTextStyles.caption.copyWith(color: secondaryColor),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        _subtitle,
                        style: AppTextStyles.caption.copyWith(color: secondaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                      ),
                      child: Text(
                        _statusLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (redemption.isPending) ...[
                      const SizedBox(height: AppSpacing.space8),
                      const Icon(Icons.qr_code_rounded, color: AppColors.accent, size: 20),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
