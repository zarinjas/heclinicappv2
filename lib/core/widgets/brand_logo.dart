import 'package:flutter/material.dart';

import '../services/branding_service.dart';
import '../theme/app_colors.dart';

// ============================================================================
// APP LOGO — Branding-aware, cached, with white-label support
//
// URL fallback: if original URL fails, automatically tries replacing
// localhost ↔ host IP so images work regardless of simulator network.
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
        if (logoUrl != null && logoUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.25),
            child: _tryImageUrl(logoUrl, 0),
          )
        else
          _buildFallback(),
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

  Widget _tryImageUrl(String? url, int attempt) {
    if (url == null || attempt >= 3) {
      return _buildFallback();
    }

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        // Try next URL variant on failure
        final nextUrl = _alternateUrl(url);
        if (nextUrl != null && nextUrl != url) {
          return _tryImageUrl(nextUrl, attempt + 1);
        }
        return _buildFallback();
      },
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

  /// Try replacing localhost ↔ 192.168.x.x when loading fails
  static String? _alternateUrl(String url) {
    if (url.contains('localhost')) {
      return url.replaceFirst('localhost', '192.168.0.103');
    }
    if (url.contains('192.168.0.103')) {
      return url.replaceFirst('192.168.0.103', 'localhost');
    }
    return null;
  }
}
