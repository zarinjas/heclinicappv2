import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/branding_service.dart';
import '../../core/widgets/app_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static String routeName = 'AuthSplashScreen';
  static String routePath = '/authSplash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadBranding();
  }

  Future<void> _loadBranding() async {
    await BrandingService.instance.init();
    if (!mounted) return;
    setState(() => _ready = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    final branding = BrandingService.instance;
    final bgColor = branding.splashBgColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: _ready
          ? _buildContent(branding)
          : const Center(child: AppLoader(size: 64, color: Colors.white70)),
    );
  }

  Widget _buildContent(BrandingService branding) {
    // Splash logo falls back to the main app logo when a dedicated
    // splash logo hasn't been uploaded in the admin panel.
    final splashUrl = (branding.splashLogoUrl ?? '').isNotEmpty
        ? branding.splashLogoUrl
        : branding.logoUrl;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      child: Column(
        children: [
          // 70% — image / splash GIF
          Expanded(
            flex: 7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: splashUrl != null && splashUrl.isNotEmpty
                    ? _brandImage(splashUrl!, 0)
                        .animate()
                        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.easeOut,
                        )
                    : _buildFallbackLogo(),
              ),
            ),
          ),
          // 30% — text
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  branding.tagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ).animate().fadeIn(
                      duration: 600.ms,
                      delay: 400.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
          SizedBox(height: bottomPadding + 8),
        ],
      ),
    );
  }

  Widget _brandImage(String url, int attempt) {
    if (attempt >= 3) return _buildFallbackLogo();
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        final next = _alternateUrl(url);
        if (next != null && next != url) {
          return _brandImage(next, attempt + 1);
        }
        return _buildFallbackLogo();
      },
    );
  }

  static String? _alternateUrl(String url) {
    if (url.contains('localhost')) {
      return url.replaceFirst('localhost', '192.168.0.103');
    }
    if (url.contains('192.168.0.103')) {
      return url.replaceFirst('192.168.0.103', 'localhost');
    }
    return null;
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, Color(0xFF27F5A3)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusMD),
      ),
      alignment: Alignment.center,
      child: Text(
        BrandingService.instance.appShortName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
