import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/services/models/onboarding_slide.dart';
import '../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static String routeName = 'OnboardingScreen';
  static String routePath = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<OnboardingSlide> _slides = OnboardingSlide.fallbackList;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    await OnboardingService.instance.init();
    if (mounted) {
      setState(() {
        _slides = OnboardingService.instance.slides;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _slides.length - 1;

  void _onNext() {
    if (_isLastPage) {
      context.go('/welcome');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkip() {
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    // Fixed bottom controls: padding 24 + dots 8 + gap 20 + button 52.
    final controlsHeight = 24.0 + 8.0 + 20.0 + 52.0 + bottomSafe;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      body: Stack(
        children: [
          // ── Full-screen slider ─────────────────────────────────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                final hasMedia = (slide.imageUrl != null &&
                        slide.imageUrl!.isNotEmpty) ||
                    (slide.videoUrl != null && slide.videoUrl!.isNotEmpty);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fallback gradient (visible while/if the media fails).
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            slide.gradientStart,
                            slide.gradientEnd,
                          ],
                        ),
                      ),
                    ),
                    // Full-bleed background video (preferred) or image,
                    // both from the Admin Panel.
                    if (hasMedia)
                      _SlideMedia(
                        videoUrl: slide.videoUrl,
                        imageUrl: slide.imageUrl,
                      ),
                    // Dark navy/black gradient overlay at the bottom for
                    // text readability.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: MediaQuery.sizeOf(context).height * 0.5,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0x990A1128),
                              Color(0xF70A1128),
                            ],
                            stops: [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Title + subtitle on top of the bottom gradient.
                    Positioned(
                      left: AppSpacing.space24,
                      right: AppSpacing.space24,
                      bottom: controlsHeight + AppSpacing.space16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slide.title,
                            style: AppTextStyles.heading1.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          Text(
                            slide.subtitle,
                            style: AppTextStyles.body1.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Skip button ────────────────────────────────────────────────
          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _isLastPage
                    ? const SizedBox.shrink()
                    : AppButton.ghost(
                        label: 'Skip',
                        onPressed: _onSkip,
                        isFullWidth: false,
                      ),
              ),
            ),
          ),

          // ── Page indicator + primary button, fixed near bottom safe area
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space24,
                  0,
                  AppSpacing.space24,
                  AppSpacing.space24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space4,
                          ),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.space4,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.space20),
                    _isLastPage
                        ? AppButton.primary(
                            label: 'Get Started',
                            onPressed: _onNext,
                            backgroundColor: AppColors.primary,
                          )
                        : AppButton.primary(
                            label: 'Next',
                            onPressed: _onNext,
                            backgroundColor: AppColors.primary,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plays the slide's background media: a muted, looping video when the admin
/// uploaded one, otherwise the plain image. Falls back to the image if the
/// video fails to load.
class _SlideMedia extends StatefulWidget {
  const _SlideMedia({this.videoUrl, this.imageUrl});

  final String? videoUrl;
  final String? imageUrl;

  @override
  State<_SlideMedia> createState() => _SlideMediaState();
}

class _SlideMediaState extends State<_SlideMedia> {
  VideoPlayerController? _controller;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.videoUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _initVideo(videoUrl);
    }
  }

  Future<void> _initVideo(String url) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      controller.dispose();
      if (mounted) setState(() => _videoFailed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null) {
      // BoxFit.cover — fill the whole screen, cropping the edges.
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    final imageUrl = widget.imageUrl;
    if (_videoFailed || imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

