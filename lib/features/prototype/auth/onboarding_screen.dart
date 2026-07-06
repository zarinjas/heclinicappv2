import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      gradient: [Color(0xFF131C3C), Color(0xFF3B8DFF)],
      title: 'Your Health, Simplified',
      subtitle: 'Book appointments and track your health in one place',
    ),
    _OnboardingSlide(
      gradient: [Color(0xFF2868F5), Color(0xFF27F5A3)],
      title: 'Book in Minutes',
      subtitle:
          'See real available slots and connect with your doctor instantly',
    ),
    _OnboardingSlide(
      gradient: [Color(0xFF1D2B5F), Color(0xFFF5A623)],
      title: 'Stay in the Loop',
      subtitle:
          'Get instant updates on your appointments and health records',
    ),
  ];

  int get _totalSlides => _slides.length;
  bool get _isLastPage => _currentPage == _totalSlides - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_isLastPage) {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 55,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _totalSlides,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _slides[index].gradient,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 45,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _slides[_currentPage].title,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        Text(
                          _slides[_currentPage].subtitle,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: AppSpacing.space12,
              right: AppSpacing.space16,
              child: _isLastPage
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: _onSkip,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        child: Text(
                          'Skip',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.space32,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space32,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalSlides, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space4,
                          ),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.divider,
                            borderRadius:
                                BorderRadius.circular(AppRadius.radiusFull),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _isLastPage
                          ? AppButton.primary(
                              label: 'Get Started',
                              onPressed: _onNext,
                            )
                          : SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.radiusXL,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  textStyle: AppTextStyles.button,
                                  elevation: 0,
                                ),
                                child: const Text('Next'),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final List<Color> gradient;
  final String title;
  final String subtitle;

  const _OnboardingSlide({
    required this.gradient,
    required this.title,
    required this.subtitle,
  });
}
