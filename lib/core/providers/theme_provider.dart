import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/providers/shared_preferences_provider.dart';

const _kThemeModeKey = 'app_theme_mode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_kThemeModeKey);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light, // default to light on first launch
    };
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(next);
  }

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(
          _kThemeModeKey,
          switch (mode) {
            ThemeMode.light => 'light',
            ThemeMode.dark => 'dark',
            ThemeMode.system => 'system',
          },
        );
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final activeBrightnessProvider = Provider<Brightness>((ref) {
  final mode = ref.watch(themeModeProvider);
  return switch (mode) {
    ThemeMode.dark => Brightness.dark,
    ThemeMode.light => Brightness.light,
    ThemeMode.system =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
  };
});

final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(activeBrightnessProvider) == Brightness.dark;
});
