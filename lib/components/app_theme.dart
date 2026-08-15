import 'package:flutter/material.dart';
import 'package:ubantu/components/app_colors.dart';
import 'package:ubantu/components/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentOrange,
        surface: AppColors.background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primaryDark),
      ),
      useMaterial3: true,
    );
  }
}
