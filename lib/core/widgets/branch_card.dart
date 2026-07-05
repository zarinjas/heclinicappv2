import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class BranchCard extends StatelessWidget {
  final String name;
  final String address;
  final String operatingHours;
  final String? distance;
  final bool isSelected;
  final VoidCallback? onTap;

  const BranchCard({
    super.key,
    required this.name,
    required this.address,
    required this.operatingHours,
    this.distance,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final borderColor = isSelected
        ? AppColors.accent
        : (isDark ? AppColors.dividerDark : AppColors.divider);
    final borderWidth = isSelected ? 1.5 : 1.0;
    final bgColor = isSelected
        ? AppColors.accent.withOpacity(isDark ? 0.10 : 0.05)
        : (isDark ? AppColors.surfaceDark : AppColors.surface);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusLG),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: AppShadows.shadowLow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTextStyles.heading3.copyWith(color: titleColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.space8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: subtitleColor),
                const SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: Text(
                    address,
                    style:
                        AppTextStyles.body2.copyWith(color: subtitleColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: subtitleColor),
                const SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: Text(
                    operatingHours,
                    style:
                        AppTextStyles.body2.copyWith(color: subtitleColor),
                  ),
                ),
                if (distance != null && distance!.isNotEmpty)
                  Text(
                    distance!,
                    style:
                        AppTextStyles.body2.copyWith(color: subtitleColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BranchCardSkeleton extends StatelessWidget {
  const BranchCardSkeleton({super.key});

  Widget _bar(BuildContext context, double width, double height) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(AppRadius.radiusXS),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
        boxShadow: AppShadows.shadowLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(context, 160, 18),
          const SizedBox(height: AppSpacing.space8),
          _bar(context, 220, 13),
          const SizedBox(height: AppSpacing.space8),
          _bar(context, 140, 13),
        ],
      ),
    );
  }
}
