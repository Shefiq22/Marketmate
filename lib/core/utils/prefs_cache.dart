import 'package:shared_preferences/shared_preferences.dart';

/// Single shared [SharedPreferences] instance loaded once at app boot.
/// Every other provider/file reads from this cache instead of calling
/// [SharedPreferences.getInstance()], eliminating ~20 redundant
/// platform-channel handshakes during startup and throughout the session.
class PrefsCache {
  PrefsCache._();
  static final PrefsCache _instance = PrefsCache._();
  factory PrefsCache() => _instance;

  SharedPreferences? _prefs;

  bool get loaded => _prefs != null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getString(String key) => _prefs?.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs?.setString(key, value) ?? Future.value(false);
  bool? getBool(String key) => _prefs?.getBool(key);
  Future<bool> setBool(String key, bool value) =>
      _prefs?.setBool(key, value) ?? Future.value(false);
  Future<bool> remove(String key) =>
      _prefs?.remove(key) ?? Future.value(false);
}
