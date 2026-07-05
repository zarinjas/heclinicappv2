import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels = const <String>[],
  });

  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.dividerDark : AppColors.divider;

    return SizedBox(
      height: 52,
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          final isLast = index == totalSteps - 1;

          Widget stepCircle;
          if (isCompleted) {
            stepCircle = Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            );
          } else if (isActive) {
            stepCircle = Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                ),
              ),
            );
          } else {
            stepCircle = Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: dividerColor, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: AppTextStyles.label.copyWith(color: secondaryColor),
                ),
              ),
            );
          }

          final Widget line;
          if (!isLast) {
            final lineColor = isCompleted ? AppColors.accent : dividerColor;
            line = Expanded(
              child: Container(height: 1, color: lineColor),
            );
          } else {
            line = const SizedBox.shrink();
          }

          final label = index < labels.length ? labels[index] : 'Step $stepNumber';

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    stepCircle,
                    line,
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? primaryColor : secondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
