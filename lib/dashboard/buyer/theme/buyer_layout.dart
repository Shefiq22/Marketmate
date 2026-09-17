import 'package:flutter/material.dart';

/// Fixed layout tokens for buyer screens — avoids percentage-based bloat.
abstract final class BuyerLayout {
  static const double screenPadding = 20;
  static const double sectionGap = 20;
  static const double itemGap = 12;
  static const double cardRadius = 14;
  static const double cardPadding = 14;
  static const double maxContentWidth = 600;
  static const double headerTop = 12;
  static const double bottomNavClearance = 88;

  static EdgeInsets screenInsets({double bottom = 0}) =>
      EdgeInsets.fromLTRB(screenPadding, headerTop, screenPadding, bottom);

  static BoxDecoration cardDecoration(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ??
          (isDark ? const Color(0xFF222B35) : Colors.white),
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(
        color: isDark ? const Color(0xFF333D47) : const Color(0xFFEEEEEE),
      ),
      boxShadow: isDark
          ? []
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }
}
