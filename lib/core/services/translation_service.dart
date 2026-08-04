import 'package:flutter/foundation.dart';
import 'package:market_mate/core/config/app_config.dart';
import 'package:market_mate/core/network/api_client.dart';

/// Abstract translation service.
abstract class TranslationService {
  const TranslationService();

  Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  });
}

/// Production translation backed by a server-side translation endpoint
/// (Google Cloud Translation, DeepL, etc.).
class GoogleCloudTranslationService extends TranslationService {
  const GoogleCloudTranslationService();

  @override
  Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    if (text.isEmpty) return text;
    final client = ApiClient();
    final localeToGoogle = {'ha': 'ha', 'ig': 'ig', 'yo': 'yo', 'pcm': 'en'};
    final target = localeToGoogle[targetLanguage] ?? targetLanguage;

    final res = await client.post(
      '${AppConfig.baseUrl}/api/v1/translate',
      body: {
        'text': text,
        'source': sourceLanguage,
        'target': target,
      },
    );

    if (!res.success) {
      debugPrint('[TranslationService] API error: ${res.message}');
      return text;
    }
    return (res.data as Map<String, dynamic>?)?['translatedText'] as String? ??
        text;
  }
}

/// Mock service for development — word-substitution dictionary.
class MockTranslationService extends TranslationService {
  const MockTranslationService();

  static const _mockTranslations = {
    'ha': {
      'Fresh': 'Sabbi', 'Apples': 'Tuffa', 'Tomatoes': 'Tumatur',
      'Rice': 'Shinkafa', 'Yam': 'Doya', 'Vegetables': 'Kayan lambu',
      'Organic': 'Nazarin halitta', 'Chicken': 'Kaza', 'Fish': 'Kifi',
      'Beef': 'Naman sa', 'Goat': 'Akuya', 'Pepper': 'Tattasai',
      'Oil': 'Man', 'Garri': 'Gari', 'Beans': 'Wake',
      'fresh': 'sabbi', 'high': 'babba', 'quality': 'inganci',
    },
    'ig': {
      'Fresh': 'Ọhụrụ', 'Apples': 'Apụl', 'Tomatoes': 'Tomatọ',
      'Rice': 'Osikapa', 'Yam': 'Ji', 'Vegetables': 'Akwụkwọ nri',
      'Organic': 'Organic', 'Chicken': 'Ọkụkọ', 'Fish': 'Azụ',
      'Beef': 'Anụ ehi', 'Goat': 'Ewu', 'Pepper': 'Ose',
      'Oil': 'Mmanụ', 'Garri': 'Garri', 'Beans': 'Agwa',
      'fresh': 'ọhụrụ', 'high': 'elu', 'quality': 'mma',
    },
    'yo': {
      'Fresh': 'Tuntun', 'Apples': 'Èso àpù', 'Tomatoes': 'Tòmátì',
      'Rice': 'Ìrẹsì', 'Yam': 'Iṣu', 'Vegetables': 'Ẹ̀fọ́',
      'Organic': 'Organic', 'Chicken': 'Adìẹ', 'Fish': 'Eja',
      'Beef': 'Eran malu', 'Goat': 'Ewure', 'Pepper': 'Ata',
      'Oil': 'Epo', 'Garri': 'Gari', 'Beans': 'Ewa',
      'fresh': 'tuntun', 'high': 'ga', 'quality': 'didara',
    },
  };

  @override
  Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    if (text.isEmpty || targetLanguage == 'en' || targetLanguage == 'pcm') {
      return text;
    }
    final dict = _mockTranslations[targetLanguage];
    if (dict == null) return text;

    final lowerMap = <String, String>{};
    for (final entry in dict.entries) {
      lowerMap[entry.key.toLowerCase()] = entry.value;
    }
    return text.split(' ').map((word) {
      final trimmed = word.trim();
      if (trimmed.isEmpty) return word;
      final lower = trimmed.toLowerCase();
      final replacement = lowerMap[lower];
      if (replacement == null) return word;
      final isCapitalized = trimmed[0] == trimmed[0].toUpperCase();
      return isCapitalized
          ? '${replacement[0].toUpperCase()}${replacement.substring(1)}'
          : replacement;
    }).join(' ');
  }
}

/// In-memory caching decorator.
///
/// Stores translated results in a [Map] keyed by `"$targetLang:$sourceText"`
/// so subsequent requests for the same string + language pair return instantly.
class CachedTranslationService extends TranslationService {
  final TranslationService _inner;
  final Map<String, String> _cache = {};

  CachedTranslationService([TranslationService? inner])
      : _inner = inner ?? const MockTranslationService();

  int get cachedCount => _cache.length;

  @override
  Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    if (text.isEmpty || targetLanguage == sourceLanguage) return text;

    final key = '$targetLanguage:$text';
    final cached = _cache[key];
    if (cached != null) return cached;

    final result = await _inner.translate(
      text: text,
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
    );

    _cache[key] = result;
    return result;
  }

  void clearCache() => _cache.clear();
}
