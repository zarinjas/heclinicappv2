import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Bottom sheet that displays a claimed voucher's unique code and QR so the
/// patient can show it to the staff at the counter.
class VoucherCodeSheet extends StatelessWidget {
  final String code;
  final String? discount;
  final String title;

  const VoucherCodeSheet({
    super.key,
    required this.code,
    this.discount,
    this.title = '',
  });

  static Future<void> show(
    BuildContext context, {
    required String code,
    String? discount,
    String title = '',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => VoucherCodeSheet(
        code: code,
        discount: discount,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.space16),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space24,
        AppSpacing.space16,
        AppSpacing.space24,
        AppSpacing.space24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusXL),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
        Text(
          title.isEmpty ? 'Voucher Claimed' : title,
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
          ),
        ),
        if (discount != null && discount!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            discount!,
            style: AppTextStyles.heading2.copyWith(color: AppColors.accent),
          ),
        ],
        const SizedBox(height: AppSpacing.space20),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          child: Text(
            code,
            style: AppTextStyles.heading1.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              fontFamily: 'monospace',
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.space20),
        Container(
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
          ),
          child: QrImageView(
            data: code,
            version: QrVersions.auto,
            size: 180,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(AppSpacing.space12),
          ),
        ),
        const SizedBox(height: AppSpacing.space20),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space8,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.radiusSM),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Show this to the staff at the counter',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.space24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusXL),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]),
    );
  }
}
