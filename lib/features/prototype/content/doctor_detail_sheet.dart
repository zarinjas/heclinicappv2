import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';
import '/core/widgets/app_button.dart';

class DoctorDetailSheet extends StatelessWidget {
  const DoctorDetailSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DoctorDetailSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space8,
            AppSpacing.space24,
            AppSpacing.space32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: AppSpacing.space20),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF2868F5), Color(0xFF131C3C)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'AR',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamilyFallback: ['sans-serif'],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'Dr. Ahmad Rizal',
                style: AppTextStyles.heading2.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'General Practitioner',
                style: AppTextStyles.body1.copyWith(color: secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: secondaryText),
                  const SizedBox(width: AppSpacing.space4),
                  Text(
                    'TTDI Branch',
                    style: AppTextStyles.body2.copyWith(color: secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About',
                  style: AppTextStyles.heading3.copyWith(color: textColor),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Dr. Ahmad Rizal has over 15 years of experience in general practice. He graduated from University Malaya and completed his training at Hospital Kuala Lumpur. He is passionate about preventive care and building long-term relationships with his patients.',
                style: AppTextStyles.body1.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.space24),
              AppButton.primary(
                label: 'Book Appointment',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/booking-branch');
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
