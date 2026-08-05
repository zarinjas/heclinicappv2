import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/branding_service.dart';
import '../../core/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static String routeName = 'WelcomeScreen';
  static String routePath = '/welcome';

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final branding = BrandingService.instance;
    final bgColor = branding.welcomeBgColor;
    final gradientColor = branding.welcomeBgGradientColor;
    final buttonColor = branding.welcomeButtonColor;
    final logoSize = branding.welcomeLogoSize;
    final logoUrl = (branding.appBarLogoUrl ?? '').isNotEmpty
        ? branding.appBarLogoUrl
        : branding.logoUrl;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgColor,
              gradientColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              _buildLogo(branding, logoUrl, logoSize),
              const SizedBox(height: AppSpacing.space24),
              Text(
                branding.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
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
                    _buildLoginButton(context, buttonColor),
                    const SizedBox(height: AppSpacing.space16),
                    AppButton(
                      label: 'Create Account',
                      variant: AppButtonVariant.whiteGhost,
                      onPressed: () => context.go('/registerStep1'),
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    TextButton(
                      onPressed: () => context.go('/claimAccount'),
                      child: Text(
                        'Already a patient? Verify my account',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
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

  Widget _buildLogo(BrandingService branding, String? logoUrl, double size) {
    // Use the uploaded app logo when available, otherwise fall back to the
    // short-name box.
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackLogo(branding, size),
      );
    }

    return _buildFallbackLogo(branding, size);
  }

  Widget _buildFallbackLogo(BrandingService branding, double size) {
    return Container(
      width: size,
      height: size,
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
        branding.appShortName,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, Color buttonColor) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          ),
          elevation: 0,
        ),
        child: Text(
          'Log In',
          style: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
