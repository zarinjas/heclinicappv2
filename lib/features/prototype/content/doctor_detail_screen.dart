import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.space32),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF2868F5), Color(0xFF131C3C)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AR',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Dr. Ahmad Rizal',
              style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'General Practitioner',
              style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'TTDI Branch',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Dr. Ahmad Rizal has over 15 years of experience in general practice. '
                    'He graduated from University Malaya and completed his residency at Hospital Kuala Lumpur. '
                    'He specializes in preventive medicine and chronic disease management.',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton.primary(
              label: 'Book Appointment',
              onPressed: () => Navigator.pushNamed(context, '/booking-branch'),
            ),
            const SizedBox(height: AppSpacing.space32),
          ],
        ),
      ),
    );
  }
}
