import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.author,
    this.onTap,
  });

  final String thumbnailUrl;
  final String title;
  final String author;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark ? AppColors.surfaceDark : AppColors.divider,
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 36,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(color: primaryTextColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            author,
            style: AppTextStyles.caption.copyWith(color: secondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class VideoCardSkeleton extends StatelessWidget {
  const VideoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(AppRadius.radiusSM),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        Container(
          width: 80,
          height: 10,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(AppRadius.radiusSM),
          ),
        ),
      ],
    );
  }
}
