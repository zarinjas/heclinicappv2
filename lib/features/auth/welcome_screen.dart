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
    final buttonColor = branding.welcomeButtonColor;
    final logoSize = branding.welcomeLogoSize;
    final logoUrl = (branding.welcomeLogoUrl ?? '').isNotEmpty
        ? branding.welcomeLogoUrl
        : (branding.appBarLogoUrl ?? '').isNotEmpty
            ? branding.appBarLogoUrl
            : branding.logoUrl;

    return Scaffold(
      backgroundColor: branding.welcomeOverlayColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(branding),
          SafeArea(
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
        ],
      ),
    );
  }

  /// Background: uploaded image (when configured) with the color overlay on
  /// top. Without an image, the overlay alone is used as the backdrop.
  Widget _buildBackground(BrandingService branding) {
    final bgImageUrl = branding.welcomeBgImageUrl;
    final hasImage = bgImageUrl != null && bgImageUrl.isNotEmpty;
    final backdrop = _buildOverlay(branding, solid: true);

    if (!hasImage) return backdrop;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          bgImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => backdrop,
        ),
        _buildOverlay(branding),
      ],
    );
  }

  /// Color overlay — solid, linear gradient, or radial gradient.
  /// `solid: true` renders it fully opaque (standalone backdrop).
  Widget _buildOverlay(BrandingService branding, {bool solid = false}) {
    final opacity = solid ? 1.0 : branding.welcomeOverlayOpacity;

    switch (branding.welcomeOverlayType) {
      case 'solid':
        return Container(
          color: branding.welcomeOverlayColor.withValues(alpha: opacity),
        );
      case 'radial':
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.1,
              colors: [
                branding.welcomeRadialCenterColor.withValues(alpha: opacity),
                branding.welcomeRadialEdgeColor.withValues(alpha: opacity),
              ],
            ),
          ),
        );
      case 'linear':
      default:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                branding.welcomeLinearStartColor.withValues(alpha: opacity),
                branding.welcomeLinearEndColor.withValues(alpha: opacity),
              ],
            ),
          ),
        );
    }
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
