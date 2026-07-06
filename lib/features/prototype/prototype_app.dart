// He Clinic V2 — Full UI Prototype Runner
//
// Run with:
//   flutter run -t lib/features/prototype/prototype_app.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';

import 'auth/forgot_email_screen.dart';
import 'auth/forgot_newpassword_screen.dart';
import 'auth/forgot_otp_screen.dart';
import 'auth/login_screen.dart';
import 'auth/onboarding_screen.dart';
import 'auth/register_step1_screen.dart';
import 'auth/register_step2_screen.dart';
import 'auth/splash_screen.dart';
import 'auth/welcome_screen.dart';
import 'booking/appointment_detail_screen.dart';
import 'booking/booking_branch_screen.dart';
import 'booking/booking_confirm_screen.dart';
import 'booking/booking_datetime_screen.dart';
import 'booking/booking_doctor_screen.dart';
import 'booking/my_bookings_screen.dart';
import 'content/article_detail_screen.dart';
import 'content/articles_list_screen.dart';
import 'content/branch_detail_screen.dart';
import 'content/doctors_list_screen.dart';
import 'content/packages_screen.dart';
import 'content/videos_list_screen.dart';
import 'loyalty/my_points_screen.dart';
import 'profile/biometric_screen.dart';
import 'profile/change_password_screen.dart';
import 'profile/clinic_info_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/notification_prefs_screen.dart';
import 'profile/privacy_screen.dart';
import 'profile/terms_screen.dart';
import 'prototype_shell.dart';

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
  runApp(const PrototypeApp());
}

class PrototypeApp extends StatelessWidget {
  const PrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'He Clinic — Prototype',
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
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: AppTextStyles.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register1': (_) => const RegisterStep1Screen(),
        '/register2': (_) => const RegisterStep2Screen(),
        '/forgot-email': (_) => const ForgotEmailScreen(),
        '/forgot-otp': (_) => const ForgotOtpScreen(),
        '/forgot-password': (_) => const ForgotNewPasswordScreen(),
        '/shell': (_) => const PrototypeShell(),
        '/booking-branch': (_) => const BookingBranchScreen(),
        '/booking-doctor': (_) => const BookingDoctorScreen(),
        '/booking-datetime': (_) => const BookingDateTimeScreen(),
        '/booking-confirm': (_) => const BookingConfirmScreen(),
        '/my-bookings': (_) => const MyBookingsScreen(),
        '/appointment-detail': (_) => const AppointmentDetailScreen(),
        '/my-points': (_) => const MyPointsScreen(),
        '/edit-profile': (_) => const EditProfileScreen(),
        '/change-password': (_) => const ChangePasswordScreen(),
        '/notification-prefs': (_) => const NotificationPrefsScreen(),
        '/biometric': (_) => const BiometricScreen(),
        '/clinic-info': (_) => const ClinicInfoScreen(),
        '/privacy': (_) => const PrivacyScreen(),
        '/terms': (_) => const TermsScreen(),
        '/articles-list': (_) => const ArticlesListScreen(),
        '/article-detail': (_) => const ArticleDetailScreen(),
        '/videos-list': (_) => const VideosListScreen(),
        '/packages': (_) => const PackagesScreen(),
        '/doctors-list': (_) => const DoctorsListScreen(),
        '/branch-detail': (_) => const BranchDetailScreen(),
        '/health': (_) => const PrototypeShell(initialTab: 2),
      },
    );
  }
}
