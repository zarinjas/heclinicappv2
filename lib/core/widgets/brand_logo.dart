import 'package:flutter/material.dart';

import '../services/branding_service.dart';
import '../theme/app_colors.dart';

// ============================================================================
// APP LOGO — Branding-aware, cached, with white-label support
//
// Usage:
//   BrandLogo(size: 64)           — default gradient pill with initials
//   BrandLogo.splash()            — large splash screen logo
//   BrandLogo.appBar()            — small inline logo for app bars
// ============================================================================

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 48,
    this.showLabel = false,
    this.labelStyle,
    this.colors = const [AppColors.accent, Color(0xFF27F5A3)],
  });

  factory BrandLogo.splash() => const BrandLogo(size: 80, showLabel: true);

  factory BrandLogo.appBar() => const BrandLogo(size: 20, showLabel: false);

  final double size;
  final bool showLabel;
  final TextStyle? labelStyle;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final branding = BrandingService.instance.branding;
    final logoUrl = branding.logoUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image (from API) or fallback gradient pill
        if (logoUrl != null && logoUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.25),
            child: Image.network(
              logoUrl,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallback(),
            ),
          )
        else
          _buildFallback(),

        // Optional label — app name
        if (showLabel) ...[
          SizedBox(height: size * 0.15),
          Text(
            branding.appName,
            style: labelStyle ??
                TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.w700,
                  fontFamilyFallback: ['sans-serif'],
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildFallback() {
    final branding = BrandingService.instance.branding;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Text(
        branding.appShortName,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
          fontFamilyFallback: ['sans-serif'],
        ),
      ),
    );
  }
}
