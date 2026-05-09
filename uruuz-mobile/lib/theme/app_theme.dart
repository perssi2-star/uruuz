import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundWhite,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.ugandanGold,
        surface: AppColors.backgroundWhite,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.deepCharcoal,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textBlack,
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: AppColors.textGrey,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepCharcoal),
        titleTextStyle: TextStyle(
          color: AppColors.deepCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
