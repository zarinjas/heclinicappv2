import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static String routeName = 'SplashScreen';
  static String routePath = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    context.go('/mainPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 80,
                );
              },
            )
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 24),
            Text(
              'He Clinic',
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.easeOut,
                )
                .moveY(
                  begin: 16,
                  end: 0,
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 8),
            Text(
              'Your health, our priority',
              style: AppTextStyles.body1.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            )
                .animate()
                .fadeIn(
                  duration: 600.ms,
                  delay: 400.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
