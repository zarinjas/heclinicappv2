import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final bool showTrailingArrow;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.showTrailingArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final titleColor =
        brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: titleColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  'See all',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.accent,
                    fontSize: 13,
                  ),
                ),
                if (showTrailingArrow) ...[
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
