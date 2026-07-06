import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class GradientHeroSlide {
  final String title;
  final String subtitle;
  final String cta;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const GradientHeroSlide({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.gradient,
    this.onTap,
  });
}

class GradientHeroSlider extends StatefulWidget {
  const GradientHeroSlider({
    super.key,
    required this.slides,
    this.height = 180,
    this.autoScrollInterval = const Duration(seconds: 4),
  });

  final List<GradientHeroSlide> slides;
  final double height;
  final Duration autoScrollInterval;

  @override
  State<GradientHeroSlider> createState() => _GradientHeroSliderState();
}

class _GradientHeroSliderState extends State<GradientHeroSlider> {
  late final PageController _controller;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _timer = Timer.periodic(widget.autoScrollInterval, (_) {
      if (!_controller.hasClients || widget.slides.length < 2) return;
      final next = (_current + 1) % widget.slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.slides.length,
            itemBuilder: (_, i) {
              final slide = widget.slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _GradientHeroCard(slide: slide),
              );
            },
          ),
        ),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: AppSpacing.space12),
          _DotsIndicator(count: widget.slides.length, current: _current),
        ],
      ],
    );
  }
}

class _GradientHeroCard extends StatelessWidget {
  const _GradientHeroCard({required this.slide});
  final GradientHeroSlide slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradient,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius2XL),
        boxShadow: AppShadows.shadowMid,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      slide.subtitle,
                      style: AppTextStyles.body2.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: slide.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slide.cta,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.accent.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppRadius.radiusFull),
          ),
        );
      }),
    );
  }
}
