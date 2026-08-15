import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthRepository {
  final ApiClient _client = ApiClient();

  String _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('234') && digits.length == 13) return '+$digits';
    if (digits.startsWith('0') && digits.length == 11) return '+234${digits.substring(1)}';
    if (digits.startsWith('234') && digits.length == 12) return '+234${digits.substring(3)}';
    return phone.startsWith('+') ? phone : '+$phone';
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? referralCode,
  }) async {
    final res = await _client.post(ApiEndpoints.register, body: {
      'name': name,
      'email': email,
      'phone': _formatPhone(phone),
      'password': password,
      'role': role,
      if (referralCode != null && referralCode.trim().isNotEmpty)
        'referralCode': referralCode.trim().toUpperCase(),
    });
    if (!res.success) throw AuthException(res.message, statusCode: res.statusCode);
    final data = res.data as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String userId,
    required String otp,
  }) async {
    final res = await _client.post(ApiEndpoints.verifyEmail, body: {
      'userId': userId,
      'otp': otp,
    });
    if (!res.success) {
      throw AuthException(res.message, statusCode: res.statusCode);
    }
    final data = res.data as Map<String, dynamic>;
    await _extractAndSetTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> verifyPhone({
    required String userId,
    required String otp,
  }) async {
    final res = await _client.post(ApiEndpoints.verifyPhone, body: {
      'userId': userId,
      'otp': otp,
    });
    if (!res.success) {
      throw AuthException(res.message, statusCode: res.statusCode);
    }
    final data = res.data as Map<String, dynamic>;
    await _extractAndSetTokens(data);
    return data;
  }

  Future<void> resendOtp(String userId, {String type = 'email'}) async {
    final res = await _client.post(ApiEndpoints.resendOtp, body: {
      'userId': userId,
      'type': type,
    });
    if (!res.success) {
      throw AuthException(res.message, statusCode: res.statusCode);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(ApiEndpoints.login, body: {
      'email': email,
      'password': password,
    });
    if (!res.success) {
      throw AuthException(res.message, statusCode: res.statusCode);
    }
    final data = res.data as Map<String, dynamic>;
    await _extractAndSetTokens(data);
    return data;
  }

  /// Tries keys [accessToken], [token], [access_token] in that order.
  Future<void> _extractAndSetTokens(Map<String, dynamic> data) async {
    final tokens = data['tokens'] ?? data;
    final access = tokens['accessToken'] as String?
        ?? tokens['token'] as String?
        ?? tokens['access_token'] as String?;
    if (access != null) {
      final refresh = tokens['refreshToken'] as String?
          ?? tokens['refresh_token'] as String?
          ?? tokens['refresh'] as String?
          ?? '';
      await _client.setTokens(access, refresh);
    }
  }

  Future<void> setTokens(String access, String refresh) async {
    await _client.setTokens(access, refresh);
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (_) {}
    await _client.clearTokens();
  }

  Future<void> requestPasswordReset(String email) async {
    final res = await _client.post(ApiEndpoints.forgotPassword, body: {
      'email': email,
    });
    if (!res.success) {
      throw AuthException(res.message, statusCode: res.statusCode);
    }
  }

  Future<void> verifyPasswordResetCode({
    required String email,
    required String otp,
  }) async {
    final res = await _client.post(ApiEndpoints.forgotPassword, body: {
      'email': email,
      'otp': otp,
    });
    if (!res.success) {
      throw AuthException(res.message, statusCode: res.statusCode);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await _client.post(ApiEndpoints.resetPassword, body: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
    if (!res.success) {
      throw AuthException(res.message, statusCode: res.statusCode);
    }
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final res = await _client.get(ApiEndpoints.myProfile);
      if (res.success && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Persists the device's FCM push token on the user's profile
  /// (`PATCH /api/v1/users/me`) so the backend can deliver push
  /// notifications to this device.
  Future<void> updateFcmToken(String fcmToken) async {
    final res = await _client.patch(
      ApiEndpoints.myProfile,
      body: {'fcmToken': fcmToken},
    );
    if (!res.success) {
      throw AuthException(res.message, statusCode: res.statusCode);
    }
  }

  bool get isAuthenticated => _client.isAuthenticated;
}

class AuthException implements Exception {
  final String message;
  int? statusCode;
  AuthException(this.message, {this.statusCode});
  @override
  String toString() => message;
}
