import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_chip.dart';

enum LoyaltyTier { standard, silver, gold }

class LoyaltyCard extends StatelessWidget {
  const LoyaltyCard({
    super.key,
    required this.pointsBalance,
    this.tier = LoyaltyTier.standard,
    this.onRedeem,
    this.onViewHistory,
    this.variant = LoyaltyCardVariant.full,
  });

  final int pointsBalance;
  final LoyaltyTier tier;
  final VoidCallback? onRedeem;
  final VoidCallback? onViewHistory;
  final LoyaltyCardVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == LoyaltyCardVariant.hidden) {
      return const SizedBox.shrink();
    }

    final card = Container(
      padding: EdgeInsets.all(variant == LoyaltyCardVariant.compact
          ? AppSpacing.space16
          : AppSpacing.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.pointsGradientStart, AppColors.pointsGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius2XL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TierBadge(tier: tier),
            ],
          ),
          SizedBox(
            height: variant == LoyaltyCardVariant.compact
                ? AppSpacing.space8
                : AppSpacing.space16,
          ),
          Center(
            child: Text(
              _formatPoints(pointsBalance),
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
                fontSize: variant == LoyaltyCardVariant.compact ? 28 : 32,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Center(
            child: Text(
              'Patient Appreciation Points',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          if (variant == LoyaltyCardVariant.full) ...[
            const SizedBox(height: AppSpacing.space20),
            Row(
              children: [
                Expanded(
                  child: _OutlinedButton(
                    label: 'Redeem Points',
                    onTap: onRedeem,
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                Expanded(
                  child: _OutlinedButton(
                    label: 'View History',
                    onTap: onViewHistory,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    return card;
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
      final k = points / 1000;
      return k == k.roundToDouble()
          ? '${k.round()}K'
          : '${k.toStringAsFixed(1)}K';
    }
    return points.toString();
  }

  TierChipVariant get _tierChipVariant {
    return switch (tier) {
      LoyaltyTier.standard => TierChipVariant.standard,
      LoyaltyTier.silver => TierChipVariant.silver,
      LoyaltyTier.gold => TierChipVariant.gold,
    };
  }

  String get _tierLabel {
    return switch (tier) {
      LoyaltyTier.standard => 'Standard',
      LoyaltyTier.silver => 'Silver',
      LoyaltyTier.gold => 'Gold',
    };
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final LoyaltyTier tier;

  TierChipVariant get _variant {
    return switch (tier) {
      LoyaltyTier.standard => TierChipVariant.standard,
      LoyaltyTier.silver => TierChipVariant.silver,
      LoyaltyTier.gold => TierChipVariant.gold,
    };
  }

  String get _label {
    return switch (tier) {
      LoyaltyTier.standard => 'Standard',
      LoyaltyTier.silver => 'Silver',
      LoyaltyTier.gold => 'Gold',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: _label,
      type: AppChipType.tier,
      tierVariant: _variant,
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

enum LoyaltyCardVariant { full, compact, hidden }

class LoyaltyCardSkeleton extends StatelessWidget {
  const LoyaltyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: shimmerColor,
        borderRadius: BorderRadius.circular(AppRadius.radius2XL),
      ),
    );
  }
}
