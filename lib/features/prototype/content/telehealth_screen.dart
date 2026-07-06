import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';

class TelehealthScreen extends StatelessWidget {
  const TelehealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Telehealth'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.space32),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27F5A3), Color(0xFF3B8DFF)],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.space24),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Text(
              'Telehealth Consultation',
              style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'Speak with a doctor from the comfort of your home via video call. '
              'Our telehealth service connects you to experienced practitioners for '
              'non-emergency consultations.',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space32),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: Text(
                          'Available Monday - Friday, 8am - 8pm',
                          style: AppTextStyles.body1.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: Text(
                          'RM 30 per 15-minute consultation',
                          style: AppTextStyles.body1.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: Text(
                          'Prescriptions and MC provided where appropriate',
                          style: AppTextStyles.body1.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton.whatsApp(
              label: 'Start WhatsApp Consultation',
              icon: const Text('', style: TextStyle(fontSize: 0)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening WhatsApp...'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'Tap the button above to connect with our medical team via WhatsApp.',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
