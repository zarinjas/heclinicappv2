import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/theme/app_theme.dart';

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 14,
                  width: 160,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          colors: [baseColor, highlightColor, baseColor],
        );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          colors: [baseColor, highlightColor, baseColor],
        );
  }
}

class SkeletonSlider extends StatelessWidget {
  const SkeletonSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          colors: [baseColor, highlightColor, baseColor],
        );
  }
}

class SkeletonGrid extends StatelessWidget {
  final int itemCount;

  const SkeletonGrid({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: 1500.ms,
              colors: [baseColor, highlightColor, baseColor],
            );
      },
    );
  }
}

class SkeletonTextBlock extends StatelessWidget {
  final int lineCount;

  const SkeletonTextBlock({super.key, this.lineCount = 3});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lineCount, (index) {
        final widths = [1.0, 0.8, 0.6];
        final width = widths[index % widths.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: FractionallySizedBox(
            widthFactor: width,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
        );
      }),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          colors: [baseColor, highlightColor, baseColor],
        );
  }
}
