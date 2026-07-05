import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickAction({required this.icon, required this.label, this.onTap});
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.actions,
  });

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.space12,
        mainAxisSpacing: AppSpacing.space12,
        childAspectRatio: 1.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return AppCard(
          onTap: action.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 28,
                color: AppColors.accent,
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                action.label,
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuickActionGridSkeleton extends StatelessWidget {
  const QuickActionGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;
    final shimmer =
        isDark ? AppColors.skeletonShimmerDark : AppColors.skeletonShimmer;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border =
        isDark ? AppColors.dividerDark : AppColors.divider;

    Widget shimmerTile() {
      return Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: border, width: 1),
          boxShadow: AppShadows.shadowLow,
        ),
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ShimmerBox(width: 28, height: 28, borderRadius: 4.0),
            const SizedBox(height: AppSpacing.space12),
            _ShimmerBox(width: 80, height: 12, borderRadius: AppRadius.radiusSM),
          ],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.space12,
      mainAxisSpacing: AppSpacing.space12,
      childAspectRatio: 1.4,
      children: List.generate(
        4,
        (_) => shimmerTile()
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1500.ms, colors: [base, shimmer, base]),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
