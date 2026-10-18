import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HindiFlow {
  HindiFlow._();

  // Default API: no initialization required.R
  static String _baseUrl =
      'https://hindiflow-api.contact-internchoice.workers.dev';

  static Duration requestTimeout = const Duration(seconds: 90);

  static final http.Client _client = http.Client();
  static final Map<String, String> _memoryCache = <String, String>{};

  static SharedPreferences? _preferences;

  static const String _cachePrefix = 'hindi_flow_cache_v1:';

  static String get _url => '$_baseUrl/translate';

  /// Optional: configure a custom API URL.
  ///
  /// You do not need to call this when using the default API.
  static Future<void> initialize({
    String? baseUrl,
    Duration? timeout,
  }) async {
    if (baseUrl != null) {
      final normalized = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');

      final uri = Uri.tryParse(normalized);

      if (normalized.isEmpty ||
          uri == null ||
          !uri.hasScheme ||
          uri.host.isEmpty ||
          !{'http', 'https'}.contains(uri.scheme.toLowerCase())) {
        throw ArgumentError.value(
          baseUrl,
          'baseUrl',
          'Must be a valid HTTP or HTTPS URL.',
        );
      }

      _baseUrl = normalized;
    }

    if (timeout != null) {
      requestTimeout = timeout;
    }

    _preferences ??= await SharedPreferences.getInstance();
  }

  /// Translate English text into Hindi.
  static Future<String> translate(
    String text, {
    bool useCache = true,
  }) async {
    final input = text.trim();

    if (input.isEmpty) {
      return '';
    }

    final cacheKey = '$_cachePrefix${Uri.encodeComponent(input)}';

    if (useCache) {
      final cached = _memoryCache[cacheKey];
      if (cached != null) {
        return cached;
      }

      final preferences =
          _preferences ??= await SharedPreferences.getInstance();

      final saved = preferences.getString(cacheKey);
      if (saved != null) {
        _memoryCache[cacheKey] = saved;
        return saved;
      }
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_url),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'text': input,
              'source_language': 'eng_Latn',
              'target_language': 'hin_Deva',
            }),
          )
          .timeout(requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HindiFlowException(
          'Translation request failed with HTTP '
          '${response.statusCode}: ${response.body}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const HindiFlowException(
          'The API returned an invalid response.',
        );
      }

      final translated = decoded['translated_text'];

      if (translated is! String || translated.trim().isEmpty) {
        throw const HindiFlowException(
          'The API response does not contain translated_text.',
        );
      }

      final result = translated.trim();

      if (useCache) {
        _memoryCache[cacheKey] = result;

        final preferences =
            _preferences ??= await SharedPreferences.getInstance();

        await preferences.setString(cacheKey, result);
      }

      return result;
    } on HindiFlowException {
      rethrow;
    } catch (e) {
      throw HindiFlowException(
        'Translation failed. Check your internet connection '
        'and API availability. Details: $e',
      );
    }
  }

  /// Recursively translate string values in JSON-like data.
  ///
  /// Map keys and non-string values remain unchanged.
  static Future<dynamic> translateJson(dynamic value) async {
    if (value is String) {
      return translate(value);
    }

    if (value is List) {
      final result = <dynamic>[];

      for (final item in value) {
        result.add(await translateJson(item));
      }

      return result;
    }

    if (value is Map) {
      final result = <String, dynamic>{};

      for (final entry in value.entries) {
        result[entry.key.toString()] = await translateJson(entry.value);
      }

      return result;
    }

    return value;
  }

  /// Clear in-memory and persistent translation caches.
  static Future<void> clearCache() async {
    _memoryCache.clear();

    final preferences = _preferences ??= await SharedPreferences.getInstance();

    final keys = preferences
        .getKeys()
        .where((key) => key.startsWith(_cachePrefix))
        .toList();

    for (final key in keys) {
      await preferences.remove(key);
    }
  }

  /// Close the HTTP client when it is no longer needed.
  static void close() {
    _client.close();
  }
}

class HindiFlowException implements Exception {
  final String message;

  const HindiFlowException(this.message);

  @override
  String toString() => 'HindiFlowException: $message';
}
