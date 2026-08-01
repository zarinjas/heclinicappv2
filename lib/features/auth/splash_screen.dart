import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/branding_service.dart';

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
      body: Center(
        child: _ready
            ? _buildContent(branding)
            : const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                ),
              ),
      ),
    );
  }

  Widget _buildContent(BrandingService branding) {
    final splashUrl = branding.splashLogoUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (splashUrl != null && splashUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            child: _brandImage(splashUrl!, 0, 120),
          )
              .animate()
              .fadeIn(duration: 800.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 800.ms,
                curve: Curves.easeOut,
              )
        else
          _buildFallbackLogo(),
        const SizedBox(height: 24),
        Text(
          branding.tagline,
          style: AppTextStyles.body1.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ).animate().fadeIn(
              duration: 600.ms,
              delay: 400.ms,
              curve: Curves.easeOut,
            ),
      ],
    );
  }

  Widget _brandImage(String url, int attempt, double size) {
    if (attempt >= 3) return _buildFallbackLogo();
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        final next = _alternateUrl(url);
        if (next != null && next != url) {
          return _brandImage(next, attempt + 1, size);
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
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, Color(0xFF27F5A3)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusSM),
      ),
      alignment: Alignment.center,
      child: Text(
        BrandingService.instance.appShortName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
