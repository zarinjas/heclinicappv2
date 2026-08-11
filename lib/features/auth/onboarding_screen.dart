import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/services/cms_api.dart';
import '../../core/services/onboarding_media_cache.dart';
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

  // Keep-alive keys so _SlideMedia widgets retain state across page switches
  // — videos stay loaded and don't restart.
  final Map<int, GlobalKey<_SlideMediaState>> _mediaKeys = {};

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
      // Warm the cache for every slide's media so later pages play instantly
      // (in case the splash-time prefetch didn't finish).
      OnboardingMediaCache.instance
          .prefetch(_slides.expand((s) => [s.videoUrl, s.imageUrl]));
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

  /// Preload the video for the next page when we're close to it (when the user
  /// reaches any page, preload the *following* page's video in the background).
  void _preloadNeighbors(int current) {
    final next = current + 1;
    if (next < _slides.length) {
      _mediaKeys.putIfAbsent(next, () => GlobalKey<_SlideMediaState>());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mediaKeys[next]?.currentState?.ensureInitialized();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1128),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final slide = _slides[_currentPage.clamp(0, _slides.length - 1)];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _preloadNeighbors(index);
                    },
                    itemBuilder: (context, index) {
                      _mediaKeys.putIfAbsent(
                        index,
                        () => GlobalKey<_SlideMediaState>(),
                      );
                      return _buildSlide(context, index,
                          key: _mediaKeys[index]);
                    },
                  ),
                ),
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
                          borderRadius: BorderRadius.circular(AppSpacing.space4),
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

  Widget _buildSlide(BuildContext context, int index, {GlobalKey<_SlideMediaState>? key}) {
    final slide = _slides[index];
    final hasImage = slide.imageUrl != null && slide.imageUrl!.isNotEmpty;
    final hasVideo = slide.videoUrl != null && slide.videoUrl!.isNotEmpty;
    final hasMedia = hasImage || hasVideo;
    return Stack(
      fit: StackFit.expand,
      children: [
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
        if (hasMedia)
          _SlideMedia(
            key: key,
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
  const _SlideMedia({super.key, this.videoUrl, this.imageUrl});

  final String? videoUrl;
  final String? imageUrl;

  @override
  State<_SlideMedia> createState() => _SlideMediaState();
}

class _SlideMediaState extends State<_SlideMedia> {
  VideoPlayerController? _controller;
  VideoLoadState _loadState = VideoLoadState.idle;
  String _debugLastError = '';
  bool _mounted = true;

  // Shorter than before: a healthy fast-start MP4 initialises in 1–3s. 15s
  // just made a dead URL freeze the slide on a spinner.
  static const _kInitTimeout = Duration(seconds: 8);
  static const _kProbeTimeout = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.videoUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _initVideo(videoUrl);
    }
  }

  /// Called by the parent page to trigger preloading after the widget is
  /// already rendered but the video might not have been initialized yet
  /// (e.g. for a neighboring page that was built lazily).
  void ensureInitialized() {
    final videoUrl = widget.videoUrl;
    if (videoUrl != null && videoUrl.isNotEmpty && _controller == null && !_videoFinished
        && _loadState == VideoLoadState.idle) {
      _initVideo(videoUrl);
    }
  }

  bool get _videoFinished => _loadState == VideoLoadState.playing || _loadState == VideoLoadState.failed;

  Future<void> _initVideo(String rawUrl) async {
    // Laravel builds media URLs from its own APP_URL (often localhost), which
    // is unreachable from an emulator or physical device — rebase onto the API
    // host the app actually connected to.
    final url = CmsApi.resolveMediaUrl(rawUrl);
    _loadState = VideoLoadState.loading;
    if (_mounted) setState(() {});

    // Prefer a locally cached copy → plays instantly with no network round-trip.
    // Otherwise stream from the network and cache it in the background so the
    // next launch is instant.
    VideoPlayerController controller;
    final cached = await OnboardingMediaCache.instance.getIfCached(rawUrl);
    if (cached != null && await cached.file.exists()) {
      controller = VideoPlayerController.file(cached.file);
    } else {
      // Cheap liveness probe. A missing/stale upload 404s; without this the
      // player would block for the full init timeout before giving up and
      // showing the fallback. Skipped when we already have a cached file.
      if (!await _urlIsPlayable(url)) {
        if (_mounted) {
          _debugLastError = 'Video not reachable (probe failed): $url';
          _loadState = VideoLoadState.failed;
          setState(() {});
        }
        return;
      }

      controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          'Accept': '*/*',
          'Range': 'bytes=0-', // enable byte-range streaming
        },
      );
      // Fire-and-forget: warm the cache for next time.
      OnboardingMediaCache.instance.download(rawUrl);
    }

    if (!_mounted) {
      controller.dispose();
      return;
    }

    try {
      await controller.initialize().timeout(_kInitTimeout);
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!_mounted) {
        controller.dispose();
        return;
      }
      _loadState = VideoLoadState.playing;
      _controller = controller;
    } on TimeoutException {
      controller.dispose();
      if (_mounted) {
        _debugLastError = 'Video timed out — file may be too large or '
            'server too slow. Try uploading a compressed MP4 with '
            'fast-start metadata (ffmpeg -movflags faststart).\n$url';
        _loadState = VideoLoadState.failed;
      }
    } catch (e) {
      controller.dispose();
      if (_mounted) {
        _debugLastError = 'Video failed to load.\n$url\n$e';
        _loadState = VideoLoadState.failed;
      }
    }
    if (_mounted) setState(() {});
  }

  /// Fast reachability check using a ranged GET of the first byte. Returns
  /// false on 404/timeout/network error so the caller can fall back instantly
  /// instead of waiting on the video player's own long init timeout.
  Future<bool> _urlIsPlayable(String url) async {
    try {
      final resp = await http.get(
        Uri.parse(url),
        headers: {'Range': 'bytes=0-1'},
      ).timeout(_kProbeTimeout);
      // 200 (full) or 206 (partial) both mean the file is served.
      return resp.statusCode == 200 || resp.statusCode == 206;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawImageUrl = widget.imageUrl;
    final imageUrl = rawImageUrl == null || rawImageUrl.isEmpty
        ? null
        : CmsApi.resolveMediaUrl(rawImageUrl);
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    final background = hasImage
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          )
        : const SizedBox.shrink();

    final controller = _controller;

    if (controller != null) {
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

    if (_loadState == VideoLoadState.loading) {
      return SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            background,
            // Pulsing shimmer overlay while video initializes
            const Center(
              child: _LoadingIndicator(),
            ),
          ],
        ),
      );
    }

    if (_loadState == VideoLoadState.failed) {
      debugPrint('[_SlideMedia] $_debugLastError');
      return background;
    }

    return background;
  }
}

enum VideoLoadState { idle, loading, playing, failed }

/// Minimal pulsing dot indicator — doesn't block the slide content.
class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
