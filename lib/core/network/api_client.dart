import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'api_endpoints.dart';
import '../utils/prefs_cache.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;

  /// Refresh lock — prevents concurrent refresh calls.
  Completer<bool>? _refreshCompleter;

  /// Invoked when a silent token refresh fails and the session can no longer
  /// be restored. The app uses this to force a logout instead of hanging on
  /// unauthenticated requests forever.
  VoidCallback? onSessionExpired;

  void _notifySessionExpired() {
    debugPrint('[RefreshDebug] Session cannot be refreshed — notifying app to log out.');
    onSessionExpired?.call();
  }

  Future<void> init() async {
    // Primary: read from PrefsCache (fast, in-memory)
    final cache = PrefsCache();
    _accessToken = cache.getString(_tokenKey);
    _refreshToken = cache.getString(_refreshTokenKey);

    // Fallback: if PrefsCache wasn't initialized in time, read directly
    // from SharedPreferences (slower platform channel, but reliable)
    if (_accessToken == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        _accessToken = prefs.getString(_tokenKey);
        _refreshToken = prefs.getString(_refreshTokenKey);
        if (_accessToken != null) {
          debugPrint('[ApiClientDebug] init() fallback: loaded token from SharedPreferences directly');
        }
      } catch (e) {
        debugPrint('[ApiClientDebug] init() fallback failed: $e');
      }
    }

    debugPrint('[ApiClientDebug] init() complete — token present: ${_accessToken != null}');
  }

  Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    if (refresh.isNotEmpty) {
      _refreshToken = refresh;
    }
    final cache = PrefsCache();
    await Future.wait([
      cache.setString(_tokenKey, access),
      if (refresh.isNotEmpty) cache.setString(_refreshTokenKey, refresh),
      cache.setString('auth_token', access),
    ]);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final cache = PrefsCache();
    await Future.wait([
      cache.remove(_tokenKey),
      cache.remove(_refreshTokenKey),
      cache.remove('auth_token'),
    ]);
  }

  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;
  void setAccessToken(String token) { _accessToken = token; }

  static const String _localeKey = 'marketmate_locale';

  /// Safety-truncated tail for token audit logs.
  static String _safeTail(String? t) =>
      t != null && t.length > 5 ? t.substring(t.length - 5) : 'null';

  /// Ensures the in-memory token is synced from persistent storage.
  /// Called before every request to prevent stale/empty token states.
  Future<void> _syncTokenFromStorage() async {
    if (_accessToken != null) return;

    // Primary: read from PrefsCache (fast)
    final cached = PrefsCache().getString(_tokenKey);
    if (cached != null && cached.isNotEmpty) {
      _accessToken = cached;
      debugPrint('[ApiClientDebug] Token synced from PrefsCache: ${_safeTail(cached)}');
      return;
    }

    // Fallback: read directly from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_tokenKey);
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        debugPrint('[ApiClientDebug] Token synced from SharedPreferences fallback: ${_safeTail(_accessToken)}');
      }
    } catch (e) {
      debugPrint('[ApiClientDebug] SharedPreferences fallback failed: $e');
    }
  }

  Future<Map<String, String>> get _headers async {
    await _syncTokenFromStorage();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final locale = PrefsCache().getString(_localeKey);
    if (locale != null && locale.isNotEmpty) {
      headers['Accept-Language'] = locale;
    }
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    } else {
      debugPrint('[ApiClientDebug] CRITICAL: TOKEN IS NULL after sync — request will be unauthenticated');
    }
    return headers;
  }

  /// Attempts a silent token refresh with a concurrency lock.
  /// Returns the new access token string, or null on failure.
  /// If another refresh is already in-flight, waits for its result.
  Future<String?> _handleTokenRefresh() async {
    if (_refreshCompleter != null) {
      debugPrint('[RefreshDebug] Refresh already in-flight — waiting for result...');
      final success = await _refreshCompleter!.future;
      return success ? _accessToken : null;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      debugPrint('[RefreshDebug] Step 1: Refresh lifecycle initialized.');

      if (_refreshToken == null || _refreshToken!.isEmpty) {
        debugPrint('[RefreshDebug] ❌ No refresh token available — cannot refresh');
        _notifySessionExpired();
        completer.complete(false);
        return null;
      }

      debugPrint('[RefreshDebug] 2. Sending stored refresh token to backend...');
      final uri = Uri.parse('${AppConfig.baseUrl}${ApiEndpoints.refreshToken}');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'] ?? body;
        final newAccess = data['accessToken'] as String? ??
            data['token'] as String? ??
            data['access_token'] as String?;
        final newRefresh = data['refreshToken'] as String? ??
            data['refresh_token'] as String? ??
            data['refresh'] as String? ??
            '';
        if (newAccess == null || newAccess.isEmpty) {
          debugPrint('[RefreshDebug] ❌ CRITICAL: No access token in refresh response');
          completer.complete(false);
          return null;
        }
        await setTokens(newAccess, newRefresh);
        debugPrint('[RefreshDebug] Step 2: New token string written to memory storage successfully.');
        completer.complete(true);
        return newAccess;
      }

      debugPrint('[RefreshDebug] ❌ CRITICAL: Silent token refresh failed: status ${res.statusCode}');
      _notifySessionExpired();
      completer.complete(false);
      return null;
    } catch (e) {
      debugPrint('[RefreshDebug] ❌ CRITICAL: Silent token refresh failed: $e');
      completer.complete(false);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Executes an HTTP request with 401 → refresh → recursive retry.
  /// Uses explicit header cloning and checks for "Access token expired"
  /// to avoid false retries on non-expiry 401 errors.
  Future<ApiResponse> _executeWithRetry({
    required Uri uri,
    required String method,
    required String path,
    String? body,
    required Map<String, String> headers,
    int attempt = 0,
  }) async {
    Future<http.Response> _send() {
      switch (method) {
        case 'GET':
          return http.get(uri, headers: headers);
        case 'POST':
          return http.post(uri, headers: headers, body: body);
        case 'PATCH':
          return http.patch(uri, headers: headers, body: body);
        case 'DELETE':
          return http.delete(uri, headers: headers);
        default:
          return http.post(uri, headers: headers, body: body);
      }
    }

    debugPrint('[ApiClient] $method $path — Authorization header present: ${headers.containsKey('Authorization')}');
    var response = await _send().timeout(AppConfig.requestTimeout);

    if (response.statusCode == 401) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] == 'Access token expired') {
        debugPrint('[RefreshDebug] Token expired detected. Fetching fresh session...');
        final newToken = await _handleTokenRefresh();
        if (newToken != null && attempt < 1) {
          debugPrint('[RefreshDebug] Success! Re-injecting fresh token and retrying request.');
          final updatedHeaders = Map<String, String>.from(headers);
          updatedHeaders['Authorization'] = 'Bearer $newToken';
          debugPrint('[RefreshDebug] Step 3: Outbound retry request on the wire.');
          return _executeWithRetry(
            uri: uri,
            method: method,
            path: path,
            body: body,
            headers: updatedHeaders,
            attempt: attempt + 1,
          );
        }
        debugPrint('[RefreshDebug] ❌ Refresh failed — falling through to return original 401 error.');
      }
    }

    return _handleResponse(response);
  }

  Future<ApiResponse> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path')
        .replace(queryParameters: query);
    return _executeWithRetry(
      uri: uri,
      method: 'GET',
      path: path,
      headers: await _headers,
    );
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final bodyStr = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      uri: uri,
      method: 'POST',
      path: path,
      body: bodyStr,
      headers: await _headers,
    );
  }

  Future<ApiResponse> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final bodyStr = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      uri: uri,
      method: 'PATCH',
      path: path,
      body: bodyStr,
      headers: await _headers,
    );
  }

  Future<ApiResponse> delete(String path) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    return _executeWithRetry(
      uri: uri,
      method: 'DELETE',
      path: path,
      headers: await _headers,
    );
  }

  Future<ApiResponse> uploadFile(
    String path, {
    required File file,
    String fieldName = 'file',
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final locale = PrefsCache().getString(_localeKey);

    Future<http.Response> _doUpload(String? overrideToken) async {
      final request = http.MultipartRequest('POST', uri);
      if (locale != null && locale.isNotEmpty) {
        request.headers['Accept-Language'] = locale;
      }
      final token = overrideToken ?? _accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      final streamed = await request.send().timeout(AppConfig.uploadTimeout);
      return http.Response.fromStream(streamed);
    }

    // Ensure token is loaded before upload
    await _syncTokenFromStorage();
    var response = await _doUpload(null);

    if (response.statusCode == 401) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] == 'Access token expired') {
        debugPrint('[RefreshDebug] Token expired detected on upload. Fetching fresh session...');
        final newToken = await _handleTokenRefresh();
        if (newToken != null) {
          debugPrint('[RefreshDebug] Success! Retrying upload with fresh token.');
          response = await _doUpload(newToken);
          return _handleResponse(response);
        }
      }
    }

    return _handleResponse(response);
  }

  Future<ApiResponse> _handleResponse(http.Response response) async {
    try {
      final decoded = jsonDecode(response.body);

      final Map<String, dynamic> body;
      if (decoded is List) {
        body = {'data': decoded};
      } else if (decoded is Map<String, dynamic>) {
        body = decoded;
      } else {
        return ApiResponse.error(
          message: 'Unexpected response format (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          message: body['message'] as String? ?? 'Success',
          data: body['data'],
          meta: body['meta'],
        );
      }
      if (response.statusCode >= 400) {
        debugPrint('[ApiClient] ❌ Request failed: ${response.statusCode} ${response.request?.url}');
        debugPrint('[ApiClient] Response body: ${response.body}');
      }
      return ApiResponse.error(
        message: body['message'] as String? ?? 'An error occurred',
        statusCode: response.statusCode,
        errors: body['errors'],
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to parse response (${response.statusCode}): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final dynamic meta;
  final int? statusCode;
  final dynamic errors;

  ApiResponse._({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.success({String? message, dynamic data, dynamic meta}) {
    return ApiResponse._(
      success: true,
      message: message ?? 'Success',
      data: data,
      meta: meta,
    );
  }

  factory ApiResponse.error({
    String? message,
    int? statusCode,
    dynamic errors,
  }) {
    return ApiResponse._(
      success: false,
      message: message ?? 'An error occurred',
      statusCode: statusCode,
      errors: errors,
    );
  }

  List<dynamic> get dataList {
    if (data is List<dynamic>) return data as List<dynamic>;
    if (data is Map) {
      final m = data as Map;
      for (final key in ['items', 'data', 'results', 'docs']) {
        if (m[key] is List) return m[key] as List<dynamic>;
      }
    }
    return [];
  }
}
