import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/providers/shared_preferences_provider.dart';
import 'package:market_mate/core/utils/prefs_cache.dart';
import 'package:market_mate/dashboard/buyer/providers/products_provider.dart';
import 'package:market_mate/dashboard/seller/providers/seller_state_providers.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';
import 'pending_verification_provider.dart';

bool isUnverifiedAccountMessage(String message) {
  final lower = message.toLowerCase();
  return lower.contains('not verified') ||
      lower.contains('unverified') ||
      lower.contains('verify your') ||
      lower.contains('email verification');
}

enum UserRole { farmerOrWholesaler, retailerOrConsumer, rider }

String userRoleToApi(UserRole role) {
  return switch (role) {
    UserRole.farmerOrWholesaler => 'seller',
    UserRole.retailerOrConsumer => 'customer',
    UserRole.rider => 'rider',
  };
}

UserRole apiToUserRole(String role) {
  return switch (role) {
    'seller' => UserRole.farmerOrWholesaler,
    'customer' => UserRole.retailerOrConsumer,
    'rider' => UserRole.rider,
    _ => UserRole.retailerOrConsumer,
  };
}

final selectedRoleProvider = StateProvider<UserRole?>((ref) => null);

final activeRoleProvider = StateProvider<UserRole>(
  (ref) => UserRole.retailerOrConsumer,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authStateProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.isAuthenticated;
});

final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>(
      (ref) => LoginFormNotifier(),
    );

final registerFormProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>(
      (ref) => RegisterFormNotifier(ref),
    );

class LoginFormState {
  final String email;
  final String password;
  final bool passwordVisible;
  final bool isLoading;
  final String? error;
  final bool needsVerification;
  final bool emailError;
  final bool passwordError;
  final bool isWrongPasswordError;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.passwordVisible = false,
    this.isLoading = false,
    this.error,
    this.needsVerification = false,
    this.emailError = false,
    this.passwordError = false,
    this.isWrongPasswordError = false,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? passwordVisible,
    bool? isLoading,
    String? error,
    bool? needsVerification,
    bool? emailError,
    bool? passwordError,
    bool? isWrongPasswordError,
  }) => LoginFormState(
    email: email ?? this.email,
    password: password ?? this.password,
    passwordVisible: passwordVisible ?? this.passwordVisible,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    needsVerification: needsVerification ?? this.needsVerification,
    emailError: emailError ?? this.emailError,
    passwordError: passwordError ?? this.passwordError,
    isWrongPasswordError: isWrongPasswordError ?? this.isWrongPasswordError,
  );

  bool get isValid => email.isNotEmpty && password.length >= 6;
}

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void reset() => state = const LoginFormState();
  void setEmail(String v) => state = state.copyWith(
    email: v,
    error: null,
    needsVerification: false,
    emailError: false,
    passwordError: false,
  );
  void setPassword(String v) => state = state.copyWith(
    password: v,
    error: null,
    needsVerification: false,
    emailError: false,
    passwordError: false,
  );
  void togglePassword() =>
      state = state.copyWith(passwordVisible: !state.passwordVisible);
  void setError(String message) =>
      state = state.copyWith(isLoading: false, error: message);

  String _friendlyErrorMessage(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('user not found') ||
        lower.contains('no account') ||
        lower.contains('email does not exist') ||
        lower.contains('not registered') ||
        lower.contains('unknown user') ||
        lower.contains('no user found') ||
        lower.contains('invalid user') ||
        lower.contains('invalid email') ||
        lower.contains('does not exist')) {
      return 'Email not registered.';
    }
    if (lower.contains('invalid password') ||
        lower.contains('wrong password') ||
        lower.contains('incorrect password')) {
      return 'Incorrect password.';
    }
    if (lower.contains('account locked') ||
        lower.contains('disabled') ||
        lower.contains('suspended') ||
        lower.contains('blocked')) {
      return 'Account locked. Contact support.';
    }
    if (lower.contains('expired') || lower.contains('session')) {
      return 'Session expired. Try again.';
    }
    if (lower.contains('too many') || lower.contains('rate limit')) {
      return 'Too many attempts. Try again later.';
    }
    if (lower.contains('not verified') ||
        lower.contains('unverified') ||
        lower.contains('verify your') ||
        lower.contains('email verification')) {
      return msg;
    }
    return 'Login failed. Check your credentials.';
  }

  Future<Map<String, dynamic>?> login(AuthRepository repo) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      needsVerification: false,
      isWrongPasswordError: false,
    );
    try {
      final data = await repo.login(
        email: state.email,
        password: state.password,
      );
      state = state.copyWith(isLoading: false);
      return data;
    } on AuthException catch (e) {
      final needsVerification =
          e.statusCode == 403 || isUnverifiedAccountMessage(e.message);
      final friendly = _friendlyErrorMessage(e.message);

      final emailNotRegistered = friendly == 'Email not registered.';
      final isWrongPassword = friendly == 'Incorrect password.';

      state = state.copyWith(
        isLoading: false,
        error: friendly,
        needsVerification: needsVerification,
        emailError: emailNotRegistered,
        passwordError: isWrongPassword,
        isWrongPasswordError: isWrongPassword,
      );
      return null;
    } on FormatException {
      state = state.copyWith(
        isLoading: false,
        error: 'Server error. Try again.',
      );
      return null;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      String error;
      if (msg.contains('socketexception') ||
          msg.contains('connection refused') ||
          msg.contains('connection closed') ||
          msg.contains('network') ||
          msg.contains('timeout') ||
          msg.contains('host unreachable')) {
        error = 'Network issue. Check your connection.';
      } else if (msg.contains('bad response') ||
          msg.contains('500') ||
          msg.contains('502') ||
          msg.contains('503')) {
        error = 'Server issue. Try again later.';
      } else {
        error = 'Something went wrong. Try again.';
      }
      state = state.copyWith(isLoading: false, error: error);
      return null;
    }
  }
}

class RegisterFormState {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String referralCode;
  final bool passwordVisible;
  final bool isLoading;
  final String? error;
  final String? userId;

  const RegisterFormState({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.referralCode = '',
    this.passwordVisible = false,
    this.isLoading = false,
    this.error,
    this.userId,
  });

  RegisterFormState copyWith({
    String? name,
    String? phone,
    String? email,
    String? password,
    String? referralCode,
    bool? passwordVisible,
    bool? isLoading,
    String? error,
    String? userId,
  }) => RegisterFormState(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    password: password ?? this.password,
    referralCode: referralCode ?? this.referralCode,
    passwordVisible: passwordVisible ?? this.passwordVisible,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    userId: userId,
  );

  bool get isValid =>
      name.isNotEmpty &&
      phone.isNotEmpty &&
      email.isNotEmpty &&
      password.length >= 6;
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Ref _ref;
  RegisterFormNotifier(this._ref) : super(const RegisterFormState());

  void setName(String v) => state = state.copyWith(name: v, error: null);
  void setEmail(String v) => state = state.copyWith(email: v, error: null);
  void setPhone(String v) => state = state.copyWith(phone: v, error: null);
  void setPassword(String v) =>
      state = state.copyWith(password: v, error: null);
  void setReferralCode(String v) =>
      state = state.copyWith(referralCode: v, error: null);
  void togglePassword() =>
      state = state.copyWith(passwordVisible: !state.passwordVisible);

  Future<String?> register() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final role = _ref.read(selectedRoleProvider);
      final data = await repo.register(
        name: state.name,
        email: state.email,
        phone: state.phone,
        password: state.password,
        role: userRoleToApi(role ?? UserRole.retailerOrConsumer),
        referralCode: state.referralCode,
      );
      final userId = _extractUserId(data);
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Registration succeeded but the server did not return your account ID. Please contact support.',
        );
        return null;
      }
      await _ref
          .read(pendingVerificationProvider.notifier)
          .save(userId, state.email);
      state = state.copyWith(isLoading: false, userId: userId);
      return userId;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _friendlyRegisterMessage(e.message, statusCode: e.statusCode),
      );
      return null;
    } on TimeoutException {
      state = state.copyWith(
        isLoading: false,
        error: 'Request timed out. Check your connection and try again.',
      );
      return null;
    } on SocketException {
      state = state.copyWith(
        isLoading: false,
        error:
            'Unable to reach the server. Please check your internet connection.',
      );
      return null;
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network') ||
          message.contains('host lookup') ||
          message.contains('failed host lookup')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Network issue. Please check your connection and try again.',
        );
        return null;
      }
      if (message.contains('formatexception') ||
          message.contains('bad response')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Server response was invalid. Please try again later.',
        );
        return null;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to complete registration. Please try again.',
      );
      return null;
    }
  }

  String _friendlyRegisterMessage(String msg, {int? statusCode}) {
    final lower = msg.toLowerCase();
    if (lower.contains('email already') ||
        lower.contains('email exists') ||
        lower.contains('already registered')) {
      return 'This email is already registered. Please log in or use a different email.';
    }
    if (lower.contains('invalid email') ||
        lower.contains('email format') ||
        lower.contains('email is invalid')) {
      return 'Please enter a valid email address.';
    }
    if (lower.contains('weak password') || lower.contains('password must')) {
      return 'Password must be stronger and match the required format.';
    }
    if (lower.contains('phone') && lower.contains('invalid')) {
      return 'Please enter a valid phone number.';
    }
    if (lower.contains('referral') && (lower.contains('invalid') || lower.contains('not found'))) {
      return 'That referral code is invalid. Check it and try again, or leave it blank.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server issue occurred. Please try again later.';
    }
    if (lower.contains('request timed out') || lower.contains('timeout')) {
      return 'Request timed out. Check your connection and try again.';
    }
    return msg.isNotEmpty
        ? msg
        : 'Unable to complete registration. Please try again.';
  }

  String? _extractUserId(Map<String, dynamic> data) {
    final direct = data['_id'] ?? data['userId'] ?? data['id'];
    final parsed = _parseId(direct);
    if (parsed != null) return parsed;

    final user = data['user'];
    if (user is Map<String, dynamic>) {
      return _parseId(user['_id'] ?? user['id'] ?? user['userId']);
    }
    return null;
  }

  String? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return value;
    if (value is int) return value.toString();
    if (value is Map) {
      final oid = value[r'$oid'] ?? value['oid'];
      if (oid != null) return oid.toString();
    }
    final text = value.toString();
    return text.isNotEmpty ? text : null;
  }

  void reset() => state = const RegisterFormState();
}

final verifyEmailProvider = StateProvider<String?>((ref) => null);

final verifyPhoneProvider = StateProvider<String?>((ref) => null);

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Reads the raw JWT from the auth session storage.
/// Falls back to PrefsCache for legacy `access_token` key.
final tokenProvider = Provider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('auth_token') ?? PrefsCache().getString('access_token');
});

class AuthNotifier extends AsyncNotifier<AuthState> {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _onboardingKey = 'onboarding_seen';
  static const _pendingUserIdKey = 'pending_user_id';

  @override
  Future<AuthState> build() async {
    // When a silent token refresh fails, the session cannot be recovered. Log
    // out so the user is routed to login instead of hanging on a dashboard
    // that keeps hitting unauthenticated requests.
    ApiClient().onSessionExpired = () {
      Future.microtask(() async {
        if (!ref.mounted) return;
        debugPrint('[AuthNotifier] Session expired — logging out.');
        await logout();
      });
    };

    final prefs = ref.read(sharedPreferencesProvider);

    final onboardingSeen = prefs.getBool(_onboardingKey) ?? false;
    if (!onboardingSeen) return AuthOnboarding();

    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      final role = prefs.getString(_roleKey) ?? '';
      return _roleToState(role);
    }

    // Migration from old PrefsCache keys
    if (ApiClient().isAuthenticated) {
      final oldToken = PrefsCache().getString('access_token');
      final userJson = PrefsCache().getString('current_user');
      if (oldToken != null && oldToken.isNotEmpty && userJson != null) {
        try {
          final map = jsonDecode(userJson) as Map<String, dynamic>;
          final role = map['role'] as String? ?? '';
          if (role.isNotEmpty) {
            await prefs.setString(_tokenKey, oldToken);
            await prefs.setString(_roleKey, role);
            return _roleToState(role);
          }
        } catch (_) {}
      }
    }

    final pendingUserId = prefs.getString(_pendingUserIdKey);
    if (pendingUserId != null && pendingUserId.isNotEmpty) {
      return AuthPendingVerification();
    }

    return AuthUnauthenticated();
  }

  AuthState _roleToState(String role) {
    return switch (role) {
      'seller' => AuthSeller(),
      'rider' => AuthRider(),
      _ => AuthBuyer(),
    };
  }

  Future<void> authenticate(String role) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = ApiClient().accessToken
        ?? PrefsCache().getString('access_token')
        ?? prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      ApiClient().setAccessToken(token);
      await Future.wait([
        PrefsCache().setString('access_token', token),
        prefs.setString(_tokenKey, token),
      ]);
    }
    await prefs.setString(_roleKey, role);

    // Invalidate all cached providers to force fresh fetches with the new token.
    // This prevents stale "sold out" data from a previous session.
    ref.invalidate(productsProvider);
    ref.invalidate(productsByCategoryProvider);
    ref.invalidate(vendorsProvider);
    ref.invalidate(sellerProductsProvider);
    ref.invalidate(sellerProductsByCategoryProvider);
    ref.invalidate(sellerDashboardStatsProvider);
    ref.invalidate(sellerEarningsProvider);
    ref.invalidate(bestSellersProvider);

    state = AsyncData(_roleToState(role));
  }

  Future<void> logout() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await Future.wait([
        prefs.remove(_tokenKey),
        prefs.remove(_roleKey),
        prefs.remove(_pendingUserIdKey),
        prefs.remove('pending_email'),
        PrefsCache().remove('current_user'),
      ]);
      await ApiClient().clearTokens();
    } catch (e) {
      debugPrint('[AuthNotifier] Logout cleanup error: $e');
    }

    // Invalidate all cached providers to prevent stale data leaking
    // into the next login session (e.g. false "sold out" products).
    ref.invalidate(productsProvider);
    ref.invalidate(productsByCategoryProvider);
    ref.invalidate(vendorsProvider);
    ref.invalidate(sellerProductsProvider);
    ref.invalidate(sellerProductsByCategoryProvider);
    ref.invalidate(sellerDashboardStatsProvider);
    ref.invalidate(sellerEarningsProvider);
    ref.invalidate(bestSellersProvider);

    state = const AsyncData(AuthUnauthenticated());
  }
}
