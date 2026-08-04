import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:market_mate/core/config/app_config.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';
import 'package:market_mate/core/utils/prefs_cache.dart';

class CloudinaryUploadService {
  CloudinaryUploadService();

  /// Dynamically fetches the freshest available access token at call time.
  String? _resolveToken() {
    final apiToken = ApiClient().accessToken;
    if (apiToken != null) return apiToken;
    return PrefsCache().getString('auth_token') ?? PrefsCache().getString('access_token');
  }

  Future<Map<String, dynamic>> getSignature(String folder) async {
    final token = _resolveToken();
    if (token == null || token.isEmpty) {
      debugPrint('[CloudinaryUploadService] No access token available — session expired?');
      throw Exception('Session expired. Please log in again.');
    }

    debugPrint('[CloudinaryUploadService] Requesting signature for folder: $folder');
    debugPrint('Sending Token Prefix: ${token.substring(0, token.length >= 10 ? 10 : token.length)}...');

    final uri = Uri.parse('${AppConfig.baseUrl}${ApiEndpoints.uploadSignature}')
        .replace(queryParameters: {'folder': folder});

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(AppConfig.requestTimeout);

    if (response.statusCode == 401) {
      debugPrint('[CloudinaryUploadService] 401 on signature request — token may be expired or corrupted');
      throw Exception('Authentication expired. Please log in again.');
    }
    if (response.statusCode != 200) {
      debugPrint('[CloudinaryUploadService] Signature request FAILED: HTTP ${response.statusCode} — ${response.body}');
      throw Exception('Failed to get upload signature: HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? decoded;

    debugPrint('[CloudinaryUploadService] Signature received: cloud_name=${data['cloud_name'] ?? data['cloudName']}');
    return data;
  }

  Future<String> uploadImage(File file, {String folder = 'chat'}) async {
    debugPrint('[CloudinaryUploadService] Starting upload — file: ${file.path}, size: ${file.lengthSync()}, folder: $folder');

    final sig = await getSignature(folder);

    final cloudName = (sig['cloud_name'] ?? sig['cloudName'] ?? '').toString();
    final apiKey = (sig['api_key'] ?? '').toString();
    final timestamp = (sig['timestamp'] ?? '').toString();
    final signature = (sig['signature'] ?? '').toString();

    debugPrint('[CloudinaryUploadService] Signature fields — cloudName: $cloudName, apiKey: $apiKey, timestamp: $timestamp, signature: ${signature.substring(0, signature.length > 8 ? 8 : signature.length)}...');

    if (cloudName.isEmpty) {
      throw Exception('Cloudinary cloud name not configured');
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['api_key'] = apiKey;
    request.fields['timestamp'] = timestamp;
    request.fields['signature'] = signature;
    request.fields['folder'] = folder;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    debugPrint('[CloudinaryUploadService] Sending multipart request to Cloudinary...');
    final streamed = await request.send().timeout(const Duration(seconds: 120));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      debugPrint('[CloudinaryUploadService] Cloudinary responded with status ${response.statusCode}: ${response.body}');
      throw Exception('Cloudinary upload failed (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final url = data['secure_url'] as String;
    debugPrint('[CloudinaryUploadService] Upload success — secure_url: $url');
    return url;
  }
}
