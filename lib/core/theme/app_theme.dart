import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// ==============================================================================
/// SMYL GLOBAL — CENTRAL THEME DEFINITIONS
/// ==============================================================================
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // 1. Dark Theme — "GLOBAL AURORA" (Default)
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidian,
      primaryColor: AppColors.electricCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricCyan,
        onPrimary: AppColors.obsidian,
        secondary: AppColors.auroraTeal,
        onSecondary: AppColors.obsidian,
        tertiary: AppColors.champagneSand,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.warmIvory,
        error: AppColors.danger,
        onError: AppColors.warmIvory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.obsidian,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.warmIvory),
        actionsIconTheme: IconThemeData(color: AppColors.warmIvory),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 1.0,
        space: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.slate),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.electricCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricCyan,
          foregroundColor: AppColors.obsidian,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusButton,
          ),
          textStyle: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.obsidian,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.warmIvory,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusButton,
          ),
          textStyle: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomNav,
        selectedItemColor: AppColors.electricCyan,
        unselectedItemColor: AppColors.slate,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Light Theme — Premium Ivory + Deep Ink + Aurora Accents
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.lightTeal,
        onSecondary: Colors.white,
        tertiary: AppColors.lightChampagne,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        actionsIconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
