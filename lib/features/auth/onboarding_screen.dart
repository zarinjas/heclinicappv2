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
    final slide = _slides[_currentPage.clamp(0, _slides.length - 1)];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      body: Column(
        children: [
          // ── Full-screen hero slider (fills all remaining space) ──────
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) => _buildSlide(context, index),
                  ),
                ),
                // Bottom gradient overlay — shared across all slides,
                // raised slightly so the media blends in and no edge shows.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x330A1128),
                          Color(0x990A1128),
                          Color(0xF20A1128),
                        ],
                        stops: [0.0, 0.4, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
                // Skip button
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
              ],
            ),
          ),
          // ── ONE bottom content block, anchored from the bottom safe
          //    area: title → description → dots → button ─────────────────
          SafeArea(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: ValueKey(slide.id),
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.title,
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.subtitle,
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 17,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(_slides.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(
                          right: AppSpacing.space8,
                        ),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.accent
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.space4,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  _isLastPage
                      ? AppButton.whiteSolid(
                          label: 'Get Started',
                          onPressed: _onNext,
                        )
                      : AppButton.whiteSolid(
                          label: 'Next',
                          onPressed: _onNext,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(BuildContext context, int index) {
    final slide = _slides[index];
    final hasMedia = (slide.imageUrl != null && slide.imageUrl!.isNotEmpty) ||
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
        // Full-bleed background video (preferred) or image.
        if (hasMedia)
          _SlideMedia(
            videoUrl: slide.videoUrl,
            imageUrl: slide.imageUrl,
          ),
      ],
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
    final imageUrl = widget.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    // Always render the image underneath while the video is buffering so the
    // slide never looks empty — the video appears on top as soon as ready.
    final background = hasImage
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          )
        : const SizedBox.shrink();

    final controller = _controller;
    if (controller != null) {
      // BoxFit.cover — fill the whole screen, cropping the edges.
      return SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            background,
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ],
        ),
      );
    }

    if (_videoFailed) return const SizedBox.shrink();
    return background;
  }
}
