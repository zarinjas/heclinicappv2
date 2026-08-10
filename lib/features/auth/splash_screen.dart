import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/services/branding_service.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/services/onboarding_media_cache.dart';
import '../../core/widgets/app_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static String routeName = 'AuthSplashScreen';
  static String routePath = '/authSplash';

  /// Legacy route identifiers inherited from the FlutterFlow splash screen.
  ///
  /// `nav.dart` registered the old `SplashScreenWidget.routeName` / `.routePath`
  /// but built this widget, so `/splashScreen` has always rendered this screen.
  /// The constants live here now that the old widget is gone; existing links
  /// and `goNamed('SplashScreen')` callers keep working.
  static String legacyRouteName = 'SplashScreen';
  static String legacyRoutePath = '/splashScreen';

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

    final appState = FFAppState();
    final isLoggedIn = appState.isLoggedIn || appState.tokenauth.isNotEmpty;

    // For logged-out users, warm the onboarding media cache during the splash
    // window so the background video/GIF plays instantly on the next screen.
    if (!isLoggedIn) {
      _prefetchOnboardingMedia();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      // Logged-in users go straight home — onboarding only shows for
      // logged-out users (first launch / after logout).
      context.go(isLoggedIn ? '/' : '/onboarding');
    });
  }

  Future<void> _prefetchOnboardingMedia() async {
    try {
      await OnboardingService.instance.init();
      final urls = OnboardingService.instance.slides
          .expand((s) => [s.videoUrl, s.imageUrl]);
      await OnboardingMediaCache.instance.prefetch(urls);
    } catch (_) {
      // Prefetch is best-effort; playback still falls back to streaming.
    }
  }

  @override
  Widget build(BuildContext context) {
    final branding = BrandingService.instance;

    return Scaffold(
      // White background so the admin-panel "Loading GIF" (which itself has
      // a white background) blends seamlessly edge-to-edge.
      backgroundColor: Colors.white,
      body: _ready
          ? _buildContent(branding)
          : const Center(child: AppLoader(size: 64, color: AppColors.primary)),
    );
  }

  Widget _buildContent(BrandingService branding) {
    // Use the admin panel "Loading GIF" first, then fall back to the
    // splash logo, then the main app logo.
    final splashUrl = (branding.loadingGifUrl ?? '').isNotEmpty
        ? branding.loadingGifUrl
        : (branding.splashLogoUrl ?? '').isNotEmpty
            ? branding.splashLogoUrl
            : branding.logoUrl;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: splashUrl != null && splashUrl.isNotEmpty
            ? _brandImage(splashUrl, 0)
            : _buildFallbackLogo(),
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
