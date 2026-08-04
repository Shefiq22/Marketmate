import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/providers/shared_preferences_provider.dart';

const _kLocaleKey = 'app_language_code';
const _supportedCodes = {'en', 'ha', 'ig', 'yo', 'pcm'};

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_kLocaleKey);
    if (saved != null &&
        saved.isNotEmpty &&
        _supportedCodes.contains(saved)) {
      return Locale(saved);
    }
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    state = locale;
    ref.read(sharedPreferencesProvider).setString(
          _kLocaleKey,
          locale.languageCode,
        );
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
