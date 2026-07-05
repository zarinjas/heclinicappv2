import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF0F1B3D);
  static const Color accent = Color(0xFF00C9A7);
  static const Color gold = Color(0xFFF5A623);
  static const Color bgLight = Color(0xFFF8F9FC);
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF141C2E);
  static const Color textPrimary = Color(0xFF0F1B3D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color divider = Color(0xFFE5E7EB);
}

class AppSpacing {
  const AppSpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  const AppRadius._();
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

class AppShadows {
  AppShadows._();

  static const BoxShadow low = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4.0,
    offset: Offset(0.0, 1.0),
    spreadRadius: 0.0,
  );

  static const BoxShadow mid = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16.0,
    offset: Offset(0.0, 4.0),
    spreadRadius: 0.0,
  );

  static const BoxShadow high = BoxShadow(
    color: Color(0x29000000),
    blurRadius: 32.0,
    offset: Offset(0.0, 8.0),
    spreadRadius: 0.0,
  );
}

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Plus Jakarta Sans';

  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: 0.0,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: 0.0,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.0,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.0,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        letterSpacing: 0.0,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.0,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.0,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        letterSpacing: 0.0,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textInverse,
        letterSpacing: 0.0,
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textInverse,
      secondary: AppColors.accent,
      onSecondary: AppColors.textInverse,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textInverse,
    );

    final textTheme = _buildTextTheme(AppColors.textPrimary, AppColors.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      dividerColor: AppColors.divider,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.textInverse),
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Color(0x80FFFFFF),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: AppColors.error,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textInverse,
          disabledBackgroundColor: AppColors.divider,
          disabledForegroundColor: const Color(0xFF9CA3AF),
          minimumSize: const Size(double.infinity, 52.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0.0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent, width: 1.5),
          minimumSize: const Size(double.infinity, 52.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        side: BorderSide.none,
        backgroundColor: AppColors.bgLight,
        selectedColor: AppColors.accent.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        labelPadding: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.textInverse,
      secondary: AppColors.accent,
      onSecondary: AppColors.textInverse,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textInverse,
      error: AppColors.error,
      onError: AppColors.textInverse,
    );

    final textTheme =
        _buildTextTheme(AppColors.textInverse, const Color(0xFF9CA3AF));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      dividerColor: const Color(0xFF1F2937),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFF1F2937), width: 1.0),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.textInverse),
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Color(0x80FFFFFF),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9CA3AF),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9CA3AF),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: AppColors.error,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textInverse,
          disabledBackgroundColor: AppColors.divider,
          disabledForegroundColor: const Color(0xFF9CA3AF),
          minimumSize: const Size(double.infinity, 52.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0.0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent, width: 1.5),
          minimumSize: const Size(double.infinity, 52.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        side: BorderSide.none,
        backgroundColor: AppColors.bgDark,
        selectedColor: AppColors.accent.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        labelPadding: EdgeInsets.zero,
      ),
    );
  }
}
