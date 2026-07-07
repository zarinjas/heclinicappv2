import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/branding_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _loadBranding();
  }

  Future<void> _loadBranding() async {
    // Wait for branding service to fetch from API
    await BrandingService.instance.init();

    if (!mounted) return;
    setState(() => _ready = true);
    _animController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branding = BrandingService.instance;
    final bgColor = branding.splashBgColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: _ready
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(branding),
              )
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
    final hasGif = splashUrl != null && splashUrl.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasGif)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
              child: Image.network(
              splashUrl,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallbackLogo(),
            ),
          )
        else
          _buildFallbackLogo(),
        const SizedBox(height: 24),
        Text(
          branding.tagline,
          style: AppTextStyles.body1.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
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
