import 'package:flutter/material.dart';

class AppColors {
  static Brightness _brightness = Brightness.light;

  static void setBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF1B5E20);
  static const primaryBg = Color(0xFFE8F5E9);
  static const primaryMid = Color(0xFFA5D6A7);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF1A1A1A);
  static Color get background =>
      _brightness == Brightness.dark ? darkBackground : const Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEEEE);
  static const borderLight = Color(0xFFF5F5F5);

  static const grey50 = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);

  static const text = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const textLight = Color(0xFFBDBDBD);

  static const star = Color(0xFFFF9800);
  static const error = Color(0xFFC62828);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF57F17);
  static const info = Color(0xFF1565C0);
  static const infoBg = Color(0xFFE3F2FD);

  static const red = Color(0xFFE53935);
  static const redBg = Color(0xFFFFEBEE);
  static const orange = Color(0xFFF4511E);
  static const orangeBg = Color(0xFFFBE9E7);

  // Dark mode — premium deep-slate palette
  static const darkBackground = Color(0xFF0B141A);
  static const darkSurface = Color(0xFF1A2128);
  static const darkCard = Color(0xFF222B35);
  static const darkElevated = Color(0xFF2B3643);
  static const darkText = Color(0xFFE9EDEF);
  static const darkTextSecondary = Color(0xFF6B7685);
  static const darkTextTertiary = Color(0xFF4A5562);
  static const darkBorder = Color(0xFF333D47);
  static const darkDivider = Color(0xFF1E2832);
}

class AppTheme {
  static const String _font = 'Plus Jakarta Sans';

  static TextStyle _pjs({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) =>
      TextStyle(
        fontFamily: _font,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: TextTheme(
      titleLarge: _pjs(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
      bodyLarge: _pjs(fontSize: 16, color: AppColors.text),
      bodyMedium: _pjs(fontSize: 14, color: AppColors.textSecondary),
      labelLarge: _pjs(fontSize: 16, fontWeight: FontWeight.w600),
      bodySmall: _pjs(fontSize: 12, color: AppColors.textSecondary),
      headlineSmall: _pjs(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text),
      titleMedium: _pjs(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _pjs(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      iconTheme: const IconThemeData(color: AppColors.text),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _pjs(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey100,
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
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: _pjs(color: AppColors.grey400, fontSize: 14),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.primaryLight,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkCard,
      onSurfaceVariant: AppColors.darkTextSecondary,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkDivider,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    canvasColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    textTheme: TextTheme(
      titleLarge: _pjs(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkText),
      bodyLarge: _pjs(fontSize: 16, color: AppColors.darkText),
      bodyMedium: _pjs(fontSize: 14, color: AppColors.darkTextSecondary),
      labelLarge: _pjs(fontSize: 16, fontWeight: FontWeight.w600),
      bodySmall: _pjs(fontSize: 12, color: AppColors.darkTextSecondary),
      headlineSmall: _pjs(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.darkText),
      titleMedium: _pjs(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkText),
    ),
    applyElevationOverlayColor: true,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: _pjs(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
      actionsIconTheme: const IconThemeData(color: AppColors.darkText),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _pjs(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        disabledForegroundColor: AppColors.darkTextSecondary,
        side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryLight),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      hintStyle: _pjs(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
      labelStyle: _pjs(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
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
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: _pjs(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      contentTextStyle: _pjs(
        fontSize: 14,
        color: AppColors.darkTextSecondary,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      modalElevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.darkBorder,
      dragHandleSize: Size(40, 4),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle: _pjs(
        color: AppColors.darkText,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    iconTheme: const IconThemeData(color: AppColors.darkText, size: 24),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.darkTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryDark;
        }
        return AppColors.darkBorder;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    listTileTheme: ListTileThemeData(
      iconColor: AppColors.darkTextSecondary,
      titleTextStyle: _pjs(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      subtitleTextStyle: _pjs(
        fontSize: 13,
        color: AppColors.darkTextSecondary,
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.darkElevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      elevation: 4,
      textStyle: _pjs(color: AppColors.darkText),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.darkCard,
      circularTrackColor: AppColors.darkCard,
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.darkElevated.withAlpha((0.95 * 255).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: _pjs(color: AppColors.darkText, fontSize: 12),
    ),
  );
}
