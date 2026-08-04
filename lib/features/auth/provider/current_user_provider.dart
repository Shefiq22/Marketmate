import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/utils/prefs_cache.dart';
import 'package:market_mate/features/auth/data/auth_repository.dart';

class UserModel {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String userId;

  const UserModel({
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'customer',
    this.userId = '',
  });

  String get initial {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }

  String get firstName {
    if (name.isEmpty) return '';
    return name.trim().split(' ').first;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'userId': userId,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'customer',
        userId: json['userId'] as String? ?? '',
      );

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? userId,
  }) =>
      UserModel(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        userId: userId ?? this.userId,
      );
}

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  CurrentUserNotifier() : super(null) {
    _restoreFromCache();
  }

  static const _key = 'current_user';

  /// Reads cached user synchronously — [PrefsCache] is already loaded
  /// during boot so no async handshake is needed.
  void _restoreFromCache() {
    final raw = PrefsCache().getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        state = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        debugPrint('[Auth] Restored user from persistence — role: ${state?.role}');
      } catch (_) {}
    }
  }

  Future<void> setUser(UserModel user) async {
    state = user;
    await PrefsCache().setString(_key, jsonEncode(user.toJson()));
  }

  Future<void> update({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? userId,
  }) async {
    final current = state ?? UserModel(name: '', email: '');
    final updated = current.copyWith(
      name: (name != null && name.isNotEmpty) ? name : null,
      email: (email != null && email.isNotEmpty) ? email : null,
      phone: (phone != null && phone.isNotEmpty) ? phone : null,
      role: (role != null && role.isNotEmpty) ? role : null,
      userId: (userId != null && userId.isNotEmpty) ? userId : null,
    );
    state = updated;
    await PrefsCache().setString(_key, jsonEncode(updated.toJson()));
  }

  Future<void> refreshFromToken() async {
    // Always try API first
    try {
      final repo = AuthRepository();
      final profile = await repo.fetchProfile();
      if (profile != null) {
        final name = (profile['name'] ?? profile['fullName'] ?? '') as String;
        final email = (profile['email'] ?? '') as String;
        if (name.isNotEmpty || email.isNotEmpty) {
          final role = (profile['role'] ?? state?.role ?? '') as String;
          final userId = (profile['_id'] ?? profile['id'] ?? profile['userId'] ?? state?.userId ?? '') as String;
          final phone = (profile['phone'] ?? '') as String;
          final user = UserModel(
            name: name,
            email: email,
            phone: phone,
            role: role.isNotEmpty ? role : 'customer',
            userId: userId,
          );
          debugPrint('[Auth] Refreshed user from API profile — name="$name", role="$role"');
          state = user;
          await PrefsCache().setString(_key, jsonEncode(user.toJson()));
          return;
        }
      }
    } catch (_) {}

    // API failed. If we already have data, keep it.
    if (state != null && state!.name.isNotEmpty) return;

    // Fall back to JWT decode
    final token = ApiClient().accessToken;
    if (token == null) return;

    final decoded = decodeUserFromJwt(token);
    if (decoded == null) return;

    debugPrint('[Auth] Refreshing user from JWT — name="${decoded.name}", role="${decoded.role}"');
    state = decoded;
    await PrefsCache().setString(_key, jsonEncode(decoded.toJson()));
  }

  Future<void> clear() async {
    state = null;
    await PrefsCache().remove(_key);
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserModel?>(
  (ref) => CurrentUserNotifier(),
);

UserModel? decodeUserFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      debugPrint('[Auth] JWT has ${parts.length} parts, expected 3');
      return null;
    }

    debugPrint('[Auth] Raw JWT received: ${token.substring(0, min(50, token.length))}...');

    final payload = JwtDecoder.decode(token);
    debugPrint('[Auth] Decoded JWT payload keys: ${payload.keys.join(', ')}');
    debugPrint('[Auth] Decoded JWT payload: $payload');

    final name = (payload['name'] ??
                  payload['fullName'] ?? payload['full_name'] ??
                  payload['fullname'] ??
                  payload['displayName'] ?? payload['display_name'] ??
                  payload['username'] ?? '') as String;
    final email = (payload['email'] ?? payload['mail'] ?? '') as String;
    final role = (payload['role'] ??
                  payload['user_type'] ??
                  payload['userType'] ??
                  payload['userRole'] ??
                  payload['account_type'] ??
                  payload['accountType'] ??
                  payload['type'] ??
                  '') as String;
    final phone = (payload['phone'] ?? payload['phoneNumber'] ?? payload['phone_number'] ?? '') as String;
    final userId = _extractUserId(payload);

    debugPrint('[Auth] Extracted — userId: $userId, role: "$role", name: "$name", email: "$email", phone: "$phone"');

    if (name.isEmpty && email.isEmpty && userId.isEmpty && role.isEmpty) {
      debugPrint('[Auth] JWT payload has no usable data — returning null');
      return null;
    }

    final user = UserModel(name: name, email: email, phone: phone, role: role.isNotEmpty ? role : 'customer', userId: userId);
    debugPrint('[Auth] Final role stored in UserModel: "${user.role}"');
    return user;
  } catch (e) {
    debugPrint('[Auth] JWT decode error: $e');
    return null;
  }
}

String _extractUserId(Map<String, dynamic> payload) {
  return (payload['user_id'] ??
          payload['userId'] ??
          payload['sub'] ??
          payload['id'] ??
          '')
      .toString();
}

int min(int a, int b) => a < b ? a : b;
