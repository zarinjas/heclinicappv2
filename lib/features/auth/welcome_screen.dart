import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static String routeName = 'WelcomeScreen';
  static String routePath = '/welcome';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space32,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.medical_services,
                    color: AppColors.accent,
                    size: 80,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.space24),
              Text(
                'He Clinic',
                style: AppTextStyles.heading1.copyWith(
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Your trusted healthcare partner',
                style: AppTextStyles.body1.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Book appointments, access records, and more.',
                style: AppTextStyles.body2.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              const Spacer(flex: 2),
              AppButton.primary(
                label: 'Login',
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: AppSpacing.space16),
              AppButton.secondary(
                label: 'Create Account',
                onPressed: () => context.go('/registerStep1'),
              ),
              const SizedBox(height: AppSpacing.space48),
            ],
          ),
        ),
      ),
    );
  }
}
