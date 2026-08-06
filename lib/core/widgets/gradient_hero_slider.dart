import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class GradientHeroSlide {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? cta;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const GradientHeroSlide({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.cta,
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
    this.viewportFraction = 1.0,
  });

  final List<GradientHeroSlide> slides;
  final double height;
  final Duration autoScrollInterval;
  final double viewportFraction;

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
    _controller = PageController(viewportFraction: widget.viewportFraction);
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
              return _GradientHeroCard(slide: slide);
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
    final hasImage = slide.imageUrl != null && slide.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: slide.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: slide.gradient,
          ),
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          boxShadow: AppShadows.shadowMid,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.network(
                slide.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox.shrink();
                },
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              )
            : const SizedBox.shrink(),
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
