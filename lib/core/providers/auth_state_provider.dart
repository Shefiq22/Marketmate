import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../utils/prefs_cache.dart';

enum AuthStatus { loading, onboarding, unauthenticated, authenticated, pendingVerification }

class AuthStateProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.loading;
  String? _role;

  AuthStatus get status => _status;
  String? get role => _role;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isFirstTime => _status == AuthStatus.onboarding;
  bool get isPendingVerification => _status == AuthStatus.pendingVerification;

  static const _onboardingKey = 'onboarding_seen';
  static const _pendingUserIdKey = 'pending_user_id';
  static const _userKey = 'current_user';

  Future<void> initialize() async {
    final cache = PrefsCache();
    final onboardingSeen = cache.getBool(_onboardingKey) ?? false;

    if (!onboardingSeen) {
      _status = AuthStatus.onboarding;
      notifyListeners();
      return;
    }

    final tokenExists = ApiClient().isAuthenticated;

    if (!tokenExists) {
      final pendingUserId = cache.getString(_pendingUserIdKey);
      if (pendingUserId != null && pendingUserId.isNotEmpty) {
        _status = AuthStatus.pendingVerification;
        notifyListeners();
        return;
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final userJson = cache.getString(_userKey);
      if (userJson == null || userJson.isEmpty) {
        _status = AuthStatus.unauthenticated;
        await _clearSession();
        notifyListeners();
        return;
      }
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      _status = AuthStatus.authenticated;
      _role = map['role'] as String?;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      await _clearSession();
    }

    notifyListeners();
  }

  Future<void> _clearSession() async {
    final cache = PrefsCache();
    await Future.wait([
      cache.remove(_pendingUserIdKey),
      cache.remove('pending_email'),
      cache.remove(_userKey),
    ]);
    await ApiClient().clearTokens();
  }

  Future<void> markOnboardingComplete() async {
    await PrefsCache().setBool(_onboardingKey, true);
  }

  void setAuthenticated(String role) {
    _status = AuthStatus.authenticated;
    _role = role;
    notifyListeners();
  }

  Future<void> logout() async {
    final cache = PrefsCache();
    await Future.wait([
      cache.remove(_pendingUserIdKey),
      cache.remove('pending_email'),
      cache.remove(_userKey),
    ]);
    await ApiClient().clearTokens();
    _status = AuthStatus.unauthenticated;
    _role = null;
    notifyListeners();
  }
}
