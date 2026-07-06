import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.thumbnailUrl,
    this.placeholderGradient,
    required this.title,
    required this.author,
    this.durationLabel,
    this.videoAspectRatio = 16 / 9,
    this.platformLabel,
    this.onTap,
  });

  final String thumbnailUrl;
  final List<Color>? placeholderGradient;
  final String title;
  final String author;
  final String? durationLabel;
  final double videoAspectRatio;
  final String? platformLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final hasThumbnail = thumbnailUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: isDark
            ? Border.all(color: AppColors.dividerDark, width: 1)
            : Border.all(color: AppColors.divider, width: 1),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.radiusLG),
                    topRight: Radius.circular(AppRadius.radiusLG),
                  ),
                  child: AspectRatio(
                    aspectRatio: videoAspectRatio,
                    child: hasThumbnail
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) =>
                                _buildGradientThumbnail(context),
                          )
                        : placeholderGradient != null
                            ? _buildGradientThumbnail(context)
                            : Container(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.divider,
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 36,
                                  color: secondaryTextColor,
                                ),
                              ),
                  ),
                ),
                if (platformLabel != null)
                  Positioned(
                    top: AppSpacing.space8,
                    left: AppSpacing.space8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.music_note_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            platformLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              fontFamilyFallback: ['sans-serif'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                if (durationLabel != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.radiusXS),
                      ),
                      child: Text(
                        durationLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamilyFallback: ['sans-serif'],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading3.copyWith(
                      color: primaryTextColor,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: AppTextStyles.caption.copyWith(
                      color: secondaryTextColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientThumbnail(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: placeholderGradient!,
        ),
      ),
    );
  }
}

class VideoCardSkeleton extends StatelessWidget {
  const VideoCardSkeleton({super.key, this.videoAspectRatio = 16 / 9});

  final double videoAspectRatio;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: videoAspectRatio,
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
