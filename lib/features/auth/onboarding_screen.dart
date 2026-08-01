import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotActiveColor = AppColors.accent;
    final dotInactiveColor =
        isDark ? AppColors.textSecondaryDark : AppColors.divider;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBgDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Column(
                        children: [
                          Expanded(
                            flex: 55,
                            child: Container(
                              width: double.infinity,
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
                          ),
                          Expanded(
                            flex: 45,
                            child: Container(
                              width: double.infinity,
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.space32,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      slide.title,
                                      style: AppTextStyles.heading1.copyWith(
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      slide.subtitle,
                                      style: AppTextStyles.body1.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    right: 16,
                    child: _isLastPage
                        ? const SizedBox.shrink()
                        : AppButton.ghost(
                            label: 'Skip',
                            onPressed: _onSkip,
                            isFullWidth: false,
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space32,
              ),
              child: Row(
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
                          ? dotActiveColor
                          : dotInactiveColor,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.space4),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space32,
              ),
              child: _isLastPage
                  ? AppButton.primary(
                      label: 'Get Started',
                      onPressed: _onNext,
                    )
                  : AppButton.primary(
                      label: 'Next',
                      onPressed: _onNext,
                    ),
            ),
            const SizedBox(height: AppSpacing.space32),
          ],
        ),
      ),
    );
  }
}

