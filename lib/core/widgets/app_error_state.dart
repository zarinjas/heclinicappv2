import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.subtitle = '',
    this.onRetry,
    this.whatsappNumber,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final String? whatsappNumber;

  Future<void> _openWhatsApp() async {
    final number = whatsappNumber ?? '601167208860';
    final url = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space8),
              Text(
                subtitle,
                style: AppTextStyles.body1.copyWith(color: secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.space24),
              AppButton.ghost(
                label: 'Try Again',
                onPressed: onRetry,
                isFullWidth: true,
              ),
            ],
            if (whatsappNumber != null && whatsappNumber!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space12),
              AppButton.ghost(
                label: 'Contact Clinic on WhatsApp',
                onPressed: _openWhatsApp,
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
