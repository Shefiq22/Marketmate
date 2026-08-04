import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  static Brightness _brightness = Brightness.light;

  static void setBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  static const Color primary = Color(0xFF27AE60);
  static const Color primaryLight = Color(0xFF52C27E);
  static const Color primaryDark = Color(0xFF1A7D44);
  static const Color primarySurface = Color(0xFFE8F8EF);

  static const Color secondary = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFF9E3D);
  static const Color secondaryDark = Color(0xFFB85A00);
  static const Color secondarySurface = Color(0xFFFFF3E0);
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color white = Color(0xFFFFFFFF);
  static Color get gray1 =>
      _brightness == Brightness.dark ? cardDark : const Color(0xFFF5F5F5);
  static const Color gray2 = Color(0xFF9E9E9E);

  static const Color error = Color(0xFFE53935);
  static const Color errorSurface = Color(0xFFFDECEB);
  static const Color success = primary;
  static const Color warning = secondary;

  static const Color buyerAccent = primary;

  static const Color sellerAccent = Color(0xFF1B6B3A);

  static const Color riderAccent = secondary;
  // Light mode
  static Color get scaffoldLight =>
      _brightness == Brightness.dark ? scaffoldDark : const Color(0xFFF9FAF9);
  static const Color surfaceLight = white;
  static const Color cardLight = white;
  static const Color textPrimary = black;
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textHint = gray2;
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = white;
  static const Color textOnSecondary = white;
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color overlay = Color(0x80000000);

  // Dark mode — premium deep-slate palette
  static const Color scaffoldDark = Color(0xFF0B141A);
  static const Color surfaceDark = Color(0xFF1A2128);
  static const Color cardDark = Color(0xFF222B35);
  static const Color elevatedDark = Color(0xFF2B3643);
  static const Color textPrimaryDark = Color(0xFFE9EDEF);
  static const Color textSecondaryDark = Color(0xFF6B7685);
  static const Color textTertiaryDark = Color(0xFF4A5562);
  static const Color textDisabledDark = Color(0xFF333D47);
  static const Color borderDark = Color(0xFF333D47);
  static const Color dividerDark = Color(0xFF1E2832);
}
