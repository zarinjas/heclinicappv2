import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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

  static const _slides = <_OnboardingSlide>[
    _OnboardingSlide(
      title: 'Welcome to He Clinic',
      subtitle: 'Your trusted partner for quality healthcare services in Malaysia.',
      icon: Icons.medical_services,
    ),
    _OnboardingSlide(
      title: 'Book Appointments Easily',
      subtitle:
          'Skip the queue — book, reschedule, or cancel appointments with just a few taps.',
      icon: Icons.calendar_month,
    ),
    _OnboardingSlide(
      title: 'All Your Health Records',
      subtitle:
          'Access medical records, lab results, and prescriptions anytime, anywhere.',
      icon: Icons.folder_open,
    ),
  ];

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
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final dotActiveColor = AppColors.accent;
    final dotInactiveColor =
        isDark ? AppColors.textSecondaryDark : AppColors.divider;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.space12,
                  right: AppSpacing.space16,
                ),
                child: AppButton.ghost(
                  label: 'Skip',
                  onPressed: _onSkip,
                  isFullWidth: false,
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          slide.icon,
                          size: 120,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: AppSpacing.space48),
                        Text(
                          slide.title,
                          style: AppTextStyles.heading1.copyWith(
                            color:
                                isDark ? AppColors.textPrimaryDark : AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.space16),
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
                  );
                },
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

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
