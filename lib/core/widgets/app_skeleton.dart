import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton._({
    super.key,
    required this.child,
  });

  factory AppSkeleton.listItem() = _SkeletonListItem;
  factory AppSkeleton.card() = _SkeletonCard;
  factory AppSkeleton.articleCard() = _SkeletonArticleCard;
  factory AppSkeleton.videoGrid() = _SkeletonVideoGrid;
  factory AppSkeleton.appointmentCard() = _SkeletonAppointmentCard;
  factory AppSkeleton.doctorHorizontal() = _SkeletonDoctorHorizontal;
  factory AppSkeleton.slider() = _SkeletonSlider;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double? height;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;
    final shimmer = isDark ? AppColors.skeletonShimmerDark : AppColors.skeletonShimmer;

    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: borderRadius,
        ),
      ),
      base: base,
      shimmer: shimmer,
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;
    final shimmer = isDark ? AppColors.skeletonShimmerDark : AppColors.skeletonShimmer;

    return _Shimmer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: base,
          shape: BoxShape.circle,
        ),
      ),
      base: base,
      shimmer: shimmer,
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({
    required this.child,
    required this.base,
    required this.shimmer,
  });

  final Widget child;
  final Color base;
  final Color shimmer;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          colors: [base, shimmer, base],
        );
  }
}

class _SkeletonListItem extends AppSkeleton {
  _SkeletonListItem()
      : super._(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
            child: Row(
              children: [
                const _ShimmerCircle(size: 48),
                const SizedBox(width: AppSpacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _ShimmerBox(
                        width: double.infinity,
                        height: 14,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.radiusSM),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      const _ShimmerBox(
                        width: 160,
                        height: 14,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.radiusSM),
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

class _SkeletonCard extends AppSkeleton {
  _SkeletonCard()
      : super._(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _ShimmerBox(
                width: double.infinity,
                height: 120,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.radiusLG),
                ),
              ),
              const SizedBox(height: AppSpacing.space12),
              const _ShimmerBox(
                width: double.infinity,
                height: 14,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusSM),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              const _ShimmerBox(
                width: 200,
                height: 14,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusSM),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              const _ShimmerBox(
                width: 120,
                height: 14,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusSM),
                ),
              ),
            ],
          ),
        );
}

class _SkeletonArticleCard extends AppSkeleton {
  _SkeletonArticleCard()
      : super._(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _ShimmerBox(
                width: double.infinity,
                height: 140,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.radiusLG),
                ),
              ),
              const SizedBox(height: AppSpacing.space12),
              const _ShimmerBox(
                width: double.infinity,
                height: 14,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusSM),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              const _ShimmerBox(
                width: 200,
                height: 14,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusSM),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              const _ShimmerBox(
                width: 120,
                height: 14,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusSM),
                ),
              ),
            ],
          ),
        );
}

class _SkeletonVideoGrid extends AppSkeleton {
  _SkeletonVideoGrid()
      : super._(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: const _ShimmerBox(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.radiusLG),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    const _ShimmerBox(
                      width: double.infinity,
                      height: 14,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.radiusSM),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    const _ShimmerBox(
                      width: 80,
                      height: 12,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.radiusSM),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: const _ShimmerBox(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.radiusLG),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    const _ShimmerBox(
                      width: double.infinity,
                      height: 14,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.radiusSM),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    const _ShimmerBox(
                      width: 80,
                      height: 12,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.radiusSM),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
}

class _SkeletonAppointmentCard extends AppSkeleton {
  _SkeletonAppointmentCard()
      : super._(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _ShimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.radiusSM),
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                const _ShimmerBox(
                  width: 180,
                  height: 14,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.radiusSM),
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                const _ShimmerBox(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.radiusSM),
                  ),
                ),
              ],
            ),
          ),
        );
}

class _SkeletonDoctorHorizontal extends AppSkeleton {
  _SkeletonDoctorHorizontal()
      : super._(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _ShimmerCircle(size: 80),
              const SizedBox(height: AppSpacing.space8),
              const _ShimmerBox(
                width: 80,
                height: 14,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusSM),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              const _ShimmerBox(
                width: 60,
                height: 12,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusSM),
                ),
              ),
            ],
          ),
        );
}

class _SkeletonSlider extends AppSkeleton {
  _SkeletonSlider()
      : super._(
          child: const _ShimmerBox(
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.radiusLG),
            ),
          ),
        );
}
