import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class HeroSlide {
  final String imageUrl;
  final VoidCallback? onTap;
  final String? textOverlay;

  const HeroSlide({required this.imageUrl, this.onTap, this.textOverlay});
}

class HeroSlider extends StatefulWidget {
  const HeroSlider({
    super.key,
    required this.slides,
  });

  final List<HeroSlide> slides;

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  late final PageController _controller;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.slides.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void didUpdateWidget(covariant HeroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slides.length <= 1 && _timer != null) {
      _timer?.cancel();
      _timer = null;
    } else if (widget.slides.length > 1 && _timer == null) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || widget.slides.length <= 1) return;
      final nextPage = (_currentPage + 1) % widget.slides.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveDotColor = isDark
        ? AppColors.textSecondaryDark.withOpacity(0.4)
        : AppColors.textSecondary.withOpacity(0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusLG),
            child: PageView.builder(
              controller: _controller,
              onPageChanged: _onPageChanged,
              itemCount: widget.slides.length,
              itemBuilder: (context, index) {
                final slide = widget.slides[index];
                return GestureDetector(
                  onTap: slide.onTap,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        slide.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                      if (slide.textOverlay != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.space12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black54,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              slide.textOverlay!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: AppSpacing.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                width: index == _currentPage ? 18.0 : 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? AppColors.accent
                      : inactiveDotColor,
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class HeroSliderSkeleton extends StatelessWidget {
  const HeroSliderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;
    final shimmer =
        isDark ? AppColors.skeletonShimmerDark : AppColors.skeletonShimmer;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1500.milliseconds,
          colors: [base, shimmer, base],
        );
  }
}
