import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/utils/prefs_cache.dart';

class PendingVerification {
  final String userId;
  final String email;
  const PendingVerification({required this.userId, required this.email});
}

final pendingVerificationProvider =
    AsyncNotifierProvider<PendingVerificationNotifier, PendingVerification?>(
  PendingVerificationNotifier.new,
);

class PendingVerificationNotifier extends AsyncNotifier<PendingVerification?> {
  static const _userIdKey = 'pending_user_id';
  static const _emailKey = 'pending_email';

  static String _userIdForEmailKey(String email) =>
      'pending_user_id_${email.trim().toLowerCase()}';

  @override
  Future<PendingVerification?> build() async {
    final cache = PrefsCache();
    final userId = cache.getString(_userIdKey);
    if (userId == null || userId.isEmpty) return null;
    final email = cache.getString(_emailKey) ?? '';
    return PendingVerification(userId: userId, email: email);
  }

  Future<void> save(String userId, String email) async {
    final cache = PrefsCache();
    final normalizedEmail = email.trim().toLowerCase();

    await cache.setString(_userIdKey, userId);
    await cache.setString(_emailKey, normalizedEmail);
    if (normalizedEmail.isNotEmpty) {
      await cache.setString(_userIdForEmailKey(normalizedEmail), userId);
    }

    state = AsyncValue.data(
      PendingVerification(userId: userId, email: normalizedEmail),
    );
  }

  Future<String?> resolveUserId(String email) async {
    final normalized = email.trim().toLowerCase();
    final cache = PrefsCache();

    if (normalized.isNotEmpty) {
      final byEmail = cache.getString(_userIdForEmailKey(normalized));
      if (byEmail != null && byEmail.isNotEmpty) return byEmail;
    }

    final userId = cache.getString(_userIdKey);
    if (userId == null || userId.isEmpty) return null;

    final savedEmail = cache.getString(_emailKey);
    if (normalized.isNotEmpty &&
        (savedEmail == null ||
            savedEmail.isEmpty ||
            savedEmail == normalized)) {
      await cache.setString(_emailKey, normalized);
      await cache.setString(_userIdForEmailKey(normalized), userId);
      return userId;
    }

    return userId;
  }

  Future<void> clear() async {
    final cache = PrefsCache();
    final savedEmail = cache.getString(_emailKey);

    await cache.remove(_userIdKey);
    await cache.remove(_emailKey);
    if (savedEmail != null && savedEmail.isNotEmpty) {
      await cache.remove(_userIdForEmailKey(savedEmail));
    }

    state = const AsyncValue.data(null);
  }
}
