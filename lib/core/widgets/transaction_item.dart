import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum TransactionType { earned, redeemed, expired }

class TransactionItem extends StatelessWidget {
  final String description;
  final String? date;
  final int points;
  final TransactionType type;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.description,
    this.date,
    required this.points,
    required this.type,
    this.onTap,
  });

  IconData _iconForType() {
    switch (type) {
      case TransactionType.earned:
        return Icons.add_circle_outline;
      case TransactionType.redeemed:
        return Icons.remove_circle_outline;
      case TransactionType.expired:
        return Icons.access_time;
    }
  }

  Color _amountColor() {
    switch (type) {
      case TransactionType.earned:
        return AppColors.success;
      case TransactionType.redeemed:
        return AppColors.error;
      case TransactionType.expired:
        return AppColors.textSecondary;
    }
  }

  String _amountText() {
    final sign = type == TransactionType.earned ? '+' : '-';
    return '$sign${points.abs()}';
  }

  IconData _arrowIcon() {
    switch (type) {
      case TransactionType.earned:
        return Icons.arrow_drop_up;
      case TransactionType.redeemed:
        return Icons.arrow_drop_down;
      case TransactionType.expired:
        return Icons.arrow_drop_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final amountColor = _amountColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.space8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.space12,
          horizontal: AppSpacing.space16,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: amountColor.withOpacity(isDark ? 0.15 : 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconForType(), size: 20, color: amountColor),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: AppTextStyles.body1.copyWith(color: titleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (date != null && date!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      date!,
                      style:
                          AppTextStyles.body2.copyWith(color: subtitleColor),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_arrowIcon(), size: 16, color: amountColor),
                const SizedBox(width: 2),
                Text(
                  _amountText(),
                  style: AppTextStyles.heading3.copyWith(color: amountColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
