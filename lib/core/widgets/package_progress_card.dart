import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

/// A treatment package with its remaining session count.
///
/// Session usage is recorded by clinic staff in Plato (each redeemed session is
/// added as a treatment line on the same invoice), so this card only reflects
/// that data — it never changes it.
class PackageProgressCard extends StatelessWidget {
  const PackageProgressCard({
    super.key,
    required this.name,
    required this.total,
    required this.remaining,
  });

  final String name;
  final int total;
  final int remaining;

  bool get _isFinished => remaining <= 0;
  bool get _isLow => !_isFinished && remaining <= 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final progress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;
    final statusColor = _isFinished
        ? AppColors.error
        : _isLow
            ? AppColors.warning
            : AppColors.accent;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            ),
            child: Icon(
              Icons.medical_information_outlined,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  _isFinished
                      ? 'All sessions completed'
                      : '$remaining of $total sessions left',
                  style: AppTextStyles.body2.copyWith(color: textSecondary),
                ),
                const SizedBox(height: AppSpacing.space8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$remaining',
                style: AppTextStyles.heading2.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'left',
                style: AppTextStyles.caption.copyWith(color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
