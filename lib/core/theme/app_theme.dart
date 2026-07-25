import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightOnSurface,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.h1(AppColors.lightOnBackground),
        headlineMedium: AppTextStyles.h2(AppColors.lightOnBackground),
        headlineSmall: AppTextStyles.h3(AppColors.lightOnBackground),
        titleLarge: AppTextStyles.h4(AppColors.lightOnBackground),
        bodyLarge: AppTextStyles.bodyLarge(AppColors.lightOnBackground),
        bodyMedium: AppTextStyles.bodyMedium(AppColors.lightOnBackground),
        bodySmall: AppTextStyles.bodySmall(AppColors.lightOnSurfaceVariant),
        labelLarge: AppTextStyles.labelLarge(AppColors.lightOnBackground),
        labelMedium: AppTextStyles.labelMedium(AppColors.lightOnSurfaceVariant),
        labelSmall: AppTextStyles.labelSmall(AppColors.lightOnSurfaceVariant),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightDivider, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3(AppColors.lightOnBackground),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.lightSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        error: AppColors.error,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkOnSurface,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.h1(AppColors.darkOnBackground),
        headlineMedium: AppTextStyles.h2(AppColors.darkOnBackground),
        headlineSmall: AppTextStyles.h3(AppColors.darkOnBackground),
        titleLarge: AppTextStyles.h4(AppColors.darkOnBackground),
        bodyLarge: AppTextStyles.bodyLarge(AppColors.darkOnBackground),
        bodyMedium: AppTextStyles.bodyMedium(AppColors.darkOnBackground),
        bodySmall: AppTextStyles.bodySmall(AppColors.darkOnSurfaceVariant),
        labelLarge: AppTextStyles.labelLarge(AppColors.darkOnBackground),
        labelMedium: AppTextStyles.labelMedium(AppColors.darkOnSurfaceVariant),
        labelSmall: AppTextStyles.labelSmall(AppColors.darkOnSurfaceVariant),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3(AppColors.darkOnBackground),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
    );
  }
}
