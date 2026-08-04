import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_mate/core/theme/app_textstyles.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  AppTheme._();

  static const _smallRadius = Radius.circular(8);
  static const _mediumRadius = Radius.circular(12);
  static const _largeRadius = Radius.circular(16);
  static const _xlargeRadius = Radius.circular(24);
  static const _smallShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(_smallRadius),
  );
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primarySurface,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.secondarySurface,
      onSecondaryContainer: AppColors.secondaryDark,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorSurface,
      onErrorContainer: AppColors.error,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.gray1,
      onSurfaceVariant: Color.fromRGBO(74, 74, 74, 1),
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: AppColors.shadowLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      fontFamily: 'Plus Jakarta Sans',
      textTheme: AppTextStyles.textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadowLight,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle(),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        toolbarHeight: 60,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.gray1,
              disabledForegroundColor: AppColors.textDisabled,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              minimumSize: const Size(double.infinity, 52),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(_mediumRadius),
              ),
              textStyle: AppTextStyles.button(),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.white.withAlpha((0.12 * 255).round());
                }
                return null;
              }),
            ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(_mediumRadius),
          ),
          textStyle: AppTextStyles.button(color: AppColors.primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: AppTextStyles.button(color: AppColors.primary),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(_smallRadius),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(_mediumRadius),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray1,
        hintStyle: AppTextStyles.b2(color: AppColors.gray2),
        labelStyle: AppTextStyles.b2(color: AppColors.textSecondary),
        floatingLabelStyle: AppTextStyles.caption(color: AppColors.primary),
        errorStyle: AppTextStyles.caption(color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(_smallRadius),
          borderSide: BorderSide(
            color: AppColors.border.withAlpha((0.5 * 255).round()),
            width: 1,
          ),
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return AppColors.border;
          return AppColors.gray2;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return AppColors.border;
          return AppColors.gray2;
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray2,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.label(color: AppColors.primary),
        unselectedLabelStyle: AppTextStyles.label(color: AppColors.gray2),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primarySurface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.gray2, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label(color: AppColors.primary);
          }
          return AppTextStyles.label(color: AppColors.gray2);
        }),
        elevation: 8,
        height: 72,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray1,
        selectedColor: AppColors.primarySurface,
        disabledColor: AppColors.gray1,
        side: BorderSide.none,
        labelStyle: AppTextStyles.caption(color: AppColors.textSecondary),
        secondaryLabelStyle: AppTextStyles.caption(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(_largeRadius),
        ),
        titleTextStyle: AppTextStyles.h2(),
        contentTextStyle: AppTextStyles.b2(),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        modalElevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: _xlargeRadius,
            topRight: _xlargeRadius,
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(40, 4),
        clipBehavior: Clip.antiAlias,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle: AppTextStyles.b2(color: AppColors.white),
        shape: _smallShape,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        elevation: 4,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: AppColors.textSecondary,
        titleTextStyle: AppTextStyles.b1(),
        subtitleTextStyle: AppTextStyles.b2(),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.white;
          return AppColors.gray2;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.border;
        }),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySurface,
        circularTrackColor: AppColors.primarySurface,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.gray2,
        labelStyle: AppTextStyles.b2Medium(color: AppColors.primary),
        unselectedLabelStyle: AppTextStyles.b2(color: AppColors.gray2),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        indicatorColor: AppColors.primary,
        dividerColor: AppColors.divider,
      ),

      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.black.withAlpha((0.88 * 255).round()),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        textStyle: AppTextStyles.caption(color: AppColors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.secondaryLight,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.cardDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.dividerDark,
    );

    final offWhite = AppColors.textPrimaryDark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextStyles.darkTextTheme,
      fontFamily: 'Plus Jakarta Sans',
      // Scaffold / main canvas
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      canvasColor: AppColors.scaffoldDark,
      // Cards / elevated surfaces
      cardColor: AppColors.cardDark,
      applyElevationOverlayColor: true,

      // AppBar matches the surface for a flat, premium look
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: offWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle(color: offWhite),
        iconTheme: IconThemeData(color: offWhite, size: 24),
        actionsIconTheme: IconThemeData(color: offWhite, size: 24),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        toolbarHeight: 60,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: AppColors.cardDark,
              disabledForegroundColor: AppColors.textDisabledDark,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              minimumSize: const Size(double.infinity, 52),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(_mediumRadius),
              ),
              textStyle: AppTextStyles.button(),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return offWhite.withAlpha((0.12 * 255).round());
                }
                return null;
              }),
            ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: AppColors.textDisabledDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(_mediumRadius),
          ),
          textStyle: AppTextStyles.button(color: AppColors.primaryLight),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: AppTextStyles.button(color: AppColors.primaryLight),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(_smallRadius),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(_mediumRadius),
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        hintStyle: AppTextStyles.b2(color: AppColors.textSecondaryDark),
        labelStyle: AppTextStyles.b2(color: AppColors.textSecondaryDark),
        floatingLabelStyle: AppTextStyles.caption(
          color: AppColors.primaryLight,
        ),
        errorStyle: AppTextStyles.caption(color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(_smallRadius),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(_smallRadius),
          borderSide: BorderSide(
            color: AppColors.borderDark.withAlpha((0.5 * 255).round()),
            width: 1,
          ),
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return AppColors.borderDark;
          return AppColors.textSecondaryDark;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return AppColors.borderDark;
          return AppColors.textSecondaryDark;
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: offWhite.withAlpha((0.72 * 255).round()),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.label(color: colorScheme.primary),
        unselectedLabelStyle: AppTextStyles.label(
          color: offWhite.withAlpha((0.72 * 255).round()),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: colorScheme.primary.withAlpha((0.12 * 255).round()),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return const IconThemeData(
            color: AppColors.textSecondaryDark,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label(color: colorScheme.primary);
          }
          return AppTextStyles.label(color: AppColors.textSecondaryDark);
        }),
        elevation: 8,
        height: 72,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardDark,
        selectedColor: colorScheme.primary.withAlpha((0.18 * 255).round()),
        disabledColor: AppColors.cardDark,
        side: BorderSide.none,
        labelStyle: AppTextStyles.caption(color: AppColors.textSecondaryDark),
        secondaryLabelStyle: AppTextStyles.caption(
          color: AppColors.primaryLight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.elevatedDark,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(_largeRadius),
        ),
        titleTextStyle: AppTextStyles.h2(color: AppColors.textPrimaryDark),
        contentTextStyle: AppTextStyles.b2(color: AppColors.textSecondaryDark),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.elevatedDark,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        modalElevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: _xlargeRadius,
            topRight: _xlargeRadius,
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.borderDark,
        dragHandleSize: Size(40, 4),
        clipBehavior: Clip.antiAlias,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardDark,
        contentTextStyle: AppTextStyles.b2(color: offWhite),
        shape: _smallShape,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        elevation: 4,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: AppColors.textSecondaryDark,
        titleTextStyle: AppTextStyles.b1(color: AppColors.textPrimaryDark),
        subtitleTextStyle: AppTextStyles.b2(color: AppColors.textSecondaryDark),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.textSecondaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.borderDark;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.borderDark, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.borderDark;
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: AppColors.cardDark,
        circularTrackColor: AppColors.cardDark,
      ),

      // Sliders, selection, and other interactive elements
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: offWhite.withAlpha((0.12 * 255).round()),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withAlpha((0.12 * 255).round()),
        valueIndicatorTextStyle: TextStyle(color: offWhite),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withAlpha((0.24 * 255).round()),
        selectionHandleColor: colorScheme.primary,
      ),

      bottomAppBarTheme: BottomAppBarThemeData(color: AppColors.surfaceDark),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
        unselectedIconTheme: IconThemeData(
          color: offWhite.withAlpha((0.72 * 255).round()),
          size: 24,
        ),
        indicatorColor: colorScheme.primary.withAlpha((0.12 * 255).round()),
      ),

      toggleButtonsTheme: ToggleButtonsThemeData(
        color: offWhite.withAlpha((0.9 * 255).round()),
        selectedColor: colorScheme.onPrimary,
        fillColor: colorScheme.primary.withAlpha((0.18 * 255).round()),
        borderColor: AppColors.borderDark,
        selectedBorderColor: colorScheme.primary,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: offWhite.withAlpha((0.72 * 255).round()),
        labelStyle: AppTextStyles.b2Medium(color: colorScheme.primary),
        unselectedLabelStyle: AppTextStyles.b2(
          color: offWhite.withAlpha((0.72 * 255).round()),
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        indicatorColor: colorScheme.primary,
        dividerColor: AppColors.dividerDark,
      ),

      // Ensure icons use the off-white color for good contrast
      iconTheme: IconThemeData(color: offWhite, size: 24),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.elevatedDark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
        elevation: 4,
        iconColor: AppColors.textSecondaryDark,
        textStyle: AppTextStyles.b1(color: offWhite),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.b1(color: AppColors.primaryLight);
          }
          return AppTextStyles.b1(color: offWhite);
        }),
      ),

      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.elevatedDark),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              side: BorderSide(color: AppColors.borderDark, width: 1),
            ),
          ),
          elevation: WidgetStateProperty.all(4),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.elevatedDark.withAlpha((0.95 * 255).round()),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        textStyle: AppTextStyles.caption(color: offWhite),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // Subtle UI polish: dividers, splash, focus
      dividerColor: offWhite.withAlpha((0.12 * 255).round()),
      splashColor: offWhite.withAlpha((0.06 * 255).round()),
      highlightColor: Colors.transparent,
      focusColor: offWhite.withAlpha((0.12 * 255).round()),
      // toggleableActiveColor removed (unsupported). Use Switch/Checkbox/Radio themes above.
    );
  }
}
