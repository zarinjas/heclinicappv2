import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

enum LoyaltyTier { standard, silver, gold }

class LoyaltyCard extends StatelessWidget {
  const LoyaltyCard({
    super.key,
    required this.pointsBalance,
    this.tier = LoyaltyTier.standard,
    this.onRedeem,
    this.onViewHistory,
    this.variant = LoyaltyCardVariant.full,
    this.showProgress = false,
    this.progressValue = 0,
    this.progressLabel,
    this.nextTierLabel,
  });

  final int pointsBalance;
  final LoyaltyTier tier;
  final VoidCallback? onRedeem;
  final VoidCallback? onViewHistory;
  final LoyaltyCardVariant variant;
  final bool showProgress;
  final double progressValue;
  final String? progressLabel;
  final String? nextTierLabel;

  @override
  Widget build(BuildContext context) {
    if (variant == LoyaltyCardVariant.hidden) {
      return const SizedBox.shrink();
    }

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.pointsGradientStart, AppColors.pointsGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius2XL),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TierBadge(tier: tier),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatPoints(pointsBalance),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                      fontFamilyFallback: ['sans-serif'],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'pts',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Patient Appreciation Points',
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              if (showProgress) ...[
                const SizedBox(height: AppSpacing.space16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                  child: LinearProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tierGold),
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                if (progressLabel != null)
                  Text(
                    progressLabel!,
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                if (nextTierLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    nextTierLabel!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tierGold.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
              if (variant == LoyaltyCardVariant.full) ...[
                const SizedBox(height: AppSpacing.space20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Redeem',
                        variant: AppButtonVariant.whiteSolid,
                        icon: const Icon(Icons.redeem_outlined, size: 16),
                        onPressed: onRedeem,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: AppButton(
                        label: 'History',
                        variant: AppButtonVariant.whiteGhost,
                        icon: const Icon(Icons.history_rounded, size: 16),
                        onPressed: onViewHistory,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return card;
  }

  String _formatPoints(int points) {
    final s = points.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});
  final LoyaltyTier tier;

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (tier) {
      LoyaltyTier.gold => AppColors.tierGold.withValues(alpha: 0.2),
      LoyaltyTier.silver => AppColors.tierSilver.withValues(alpha: 0.2),
      LoyaltyTier.standard => Colors.white.withValues(alpha: 0.15),
    };
    final borderColor = switch (tier) {
      LoyaltyTier.gold => AppColors.tierGold.withValues(alpha: 0.5),
      LoyaltyTier.silver => AppColors.tierSilver.withValues(alpha: 0.5),
      LoyaltyTier.standard => Colors.white.withValues(alpha: 0.3),
    };
    final labelColor = switch (tier) {
      LoyaltyTier.gold => AppColors.tierGold,
      LoyaltyTier.silver => AppColors.tierSilver,
      LoyaltyTier.standard => Colors.white,
    };
    final icon = switch (tier) {
      LoyaltyTier.gold => Icons.star_rounded,
      LoyaltyTier.silver => Icons.star_half_rounded,
      LoyaltyTier.standard => Icons.star_outline_rounded,
    };
    final label = switch (tier) {
      LoyaltyTier.gold => 'Gold Member',
      LoyaltyTier.silver => 'Silver Member',
      LoyaltyTier.standard => 'Standard',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: labelColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: labelColor, fontSize: 11),
          ),
        ],
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
