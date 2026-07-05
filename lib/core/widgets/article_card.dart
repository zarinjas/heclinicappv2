import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.date,
    this.categoryLabel,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String excerpt;
  final String author;
  final String date;
  final String? categoryLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.radiusLG),
              topRight: Radius.circular(AppRadius.radiusLG),
            ),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: isDark ? AppColors.surfaceDark : AppColors.divider,
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                if (categoryLabel != null)
                  Positioned(
                    top: AppSpacing.space8,
                    left: AppSpacing.space8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space8,
                        vertical: AppSpacing.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.9),
                        borderRadius:
                            BorderRadius.circular(AppRadius.radiusSM),
                      ),
                      child: Text(
                        categoryLabel!,
                        style: AppTextStyles.caption.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(color: primaryTextColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  excerpt,
                  style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$author • $date',
                        style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleCardSkeleton extends StatelessWidget {
  const ArticleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.radiusLG),
            topRight: Radius.circular(AppRadius.radiusLG),
          ),
          child: Container(
            height: 140,
            width: double.infinity,
            color: shimmerColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(AppRadius.radiusSM),
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
                width: 180,
                height: 12,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                ),
              ),
              const SizedBox(height: AppSpacing.space12),
              Container(
                width: 140,
                height: 12,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
