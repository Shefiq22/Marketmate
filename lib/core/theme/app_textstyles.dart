import 'package:flutter/material.dart';
import 'app_colors.dart';


abstract final class AppTextStyles {
  AppTextStyles._();

 
  static const String _fontFamily = 'Plus Jakarta Sans';


  static TextStyle _base({
    required double fontSize,
    required double height,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: fontSize,
        height: height / fontSize, 
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );

  static TextStyle h1({Color? color}) => _base(
        fontSize: 20,
        height: 20,
        weight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.2,
      );

 
  static TextStyle h2({Color? color}) => _base(
        fontSize: 18,
        height: 18,
        weight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.1,
      );

 
  static TextStyle h3({Color? color}) => _base(
        fontSize: 16,
        height: 20,
        weight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );


  static TextStyle b1({Color? color}) => _base(
        fontSize: 16,
        height: 24,
        weight: FontWeight.w400,
        color: color ?? AppColors.textPrimary,
      );


  static TextStyle b1Medium({Color? color}) => _base(
        fontSize: 16,
        height: 24,
        weight: FontWeight.w500,
        color: color ?? AppColors.textPrimary,
      );

 
  static TextStyle b2({Color? color}) => _base(
        fontSize: 14,
        height: 20,
        weight: FontWeight.w400,
        color: color ?? AppColors.textSecondary,
      );


  static TextStyle b2Medium({Color? color}) => _base(
        fontSize: 14,
        height: 20,
        weight: FontWeight.w500,
        color: color ?? AppColors.textPrimary,
      );


  static TextStyle button({Color? color}) => _base(
        fontSize: 16,
        height: 22,
        weight: FontWeight.w600,
        color: color ?? AppColors.textOnPrimary,
        letterSpacing: 0.2,
      );

  static TextStyle caption({Color? color}) => _base(
        fontSize: 12,
        height: 16,
        weight: FontWeight.w400,
        color: color ?? AppColors.textHint,
      );

  
  static TextStyle captionMedium({Color? color}) => _base(
        fontSize: 12,
        height: 16,
        weight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );


  static TextStyle label({Color? color}) => _base(
        fontSize: 10,
        height: 14,
        weight: FontWeight.w500,
        color: color ?? AppColors.textHint,
        letterSpacing: 0.4,
      );

  static TextStyle price({Color? color}) => _base(
        fontSize: 20,
        height: 24,
        weight: FontWeight.w700,
        color: color ?? AppColors.primary,
      );


  static TextStyle appBarTitle({Color? color}) => _base(
        fontSize: 18,
        height: 22,
        weight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.1,
      );


  static TextTheme get textTheme => TextTheme(
        displayLarge: h1(),
        displayMedium: h1(),
        displaySmall: h2(),
        headlineLarge: h1(),
        headlineMedium: h2(),
        headlineSmall: h3(),
        titleLarge: h2(),
        titleMedium: b1Medium(),
        titleSmall: b2Medium(),
        bodyLarge: b1(),
        bodyMedium: b2(),
        bodySmall: caption(),
        labelLarge: button(),
        labelMedium: captionMedium(),
        labelSmall: label(),
      );

  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: h1(color: AppColors.textPrimaryDark),
        displayMedium: h1(color: AppColors.textPrimaryDark),
        displaySmall: h2(color: AppColors.textPrimaryDark),
        headlineLarge: h1(color: AppColors.textPrimaryDark),
        headlineMedium: h2(color: AppColors.textPrimaryDark),
        headlineSmall: h3(color: AppColors.textPrimaryDark),
        titleLarge: h2(color: AppColors.textPrimaryDark),
        titleMedium: b1Medium(color: AppColors.textPrimaryDark),
        titleSmall: b2Medium(color: AppColors.textPrimaryDark),
        bodyLarge: b1(color: AppColors.textPrimaryDark),
        bodyMedium: b2(color: AppColors.textSecondaryDark),
        bodySmall: caption(color: AppColors.textTertiaryDark),
        labelLarge: button(),
        labelMedium: captionMedium(color: AppColors.textSecondaryDark),
        labelSmall: label(color: AppColors.textTertiaryDark),
      );
}