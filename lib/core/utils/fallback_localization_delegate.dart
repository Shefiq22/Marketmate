import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  static const _supported = {'ha', 'ig', 'yo', 'pcm'};

  @override
  bool isSupported(Locale locale) => _supported.contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en', 'US'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  static const _supported = {'ha', 'ig', 'yo', 'pcm'};

  @override
  bool isSupported(Locale locale) => _supported.contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en', 'US'));

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}
