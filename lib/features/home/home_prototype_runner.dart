// Home Screen Prototype Runner
//
// Standalone entry point for the new Home Screen visual prototype.
// Run with:
//   flutter run -t lib/features/home/home_prototype_runner.dart
//
// Does NOT touch existing app routing, main.dart, or app state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/features/home/home_screen_prototype.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.scaffoldBg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const HomePrototypeApp());
}

class HomePrototypeApp extends StatelessWidget {
  const HomePrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'He Clinic — Home Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
          bodyColor: AppColors.primary,
          displayColor: AppColors.primary,
        ),
        primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          titleTextStyle: AppTextStyles.heading3.copyWith(
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: const HomeScreenPrototype(),
    );
  }
}
