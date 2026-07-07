import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/branding_service.dart';
import '../../../core/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.accent,
                      Color(0xFF27F5A3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.radiusSM),
                ),
                alignment: Alignment.center,
                child: Text(
                  BrandingService.instance.appShortName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              Text(
                BrandingService.instance.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Your health journey starts here',
                style: AppTextStyles.body1.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.space24,
                  0,
                  AppSpacing.space24,
                  bottomPadding + AppSpacing.space24,
                ),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Log In',
                      variant: AppButtonVariant.whiteSolid,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/login'),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppButton(
                      label: 'Create Account',
                      variant: AppButtonVariant.whiteGhost,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register1'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
