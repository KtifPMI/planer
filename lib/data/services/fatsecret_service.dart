import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../models/nutrition.dart';
import '../../core/config/api_config.dart';

class FatSecretService {
  static String _generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  static String _signRequest(String method, String url, Map<String, String> params) {
    final sortedParams = SplayTreeMap<String, String>.from(params);
    final paramString = sortedParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final baseString = '$method&${Uri.encodeComponent(url)}&${Uri.encodeComponent(paramString)}';
    final signingKey = '${Uri.encodeComponent(ApiConfig.fatSecretConsumerSecret)}&';

    final hmacSha1 = Hmac(sha1, utf8.encode(signingKey));
    final digest = hmacSha1.convert(utf8.encode(baseString));
    return base64Encode(digest.bytes);
  }

  static Map<String, String> _oauthHeaders(String method, String url, {Map<String, String>? extraParams}) {
    final params = <String, String>{
      'oauth_consumer_key': ApiConfig.fatSecretConsumerKey,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'oauth_nonce': _generateNonce(),
      'oauth_version': '1.0',
      ...?extraParams,
    };

    final signature = _signRequest(method, url, params);
    params['oauth_signature'] = signature;

    final authHeader = 'OAuth ' + params.entries
        .where((e) => e.key.startsWith('oauth_'))
        .map((e) => '${e.key}="${Uri.encodeComponent(e.value)}"')
        .join(', ');

    return {'Authorization': authHeader};
  }

  static Future<FoodItem?> searchByBarcode(String barcode) async {
    const url = 'https://platform.fatsecret.com/rest/server.api';

    final extraParams = {
      'method': 'food.get.v3',
      'barcode': barcode,
      'format': 'json',
    };

    final headers = _oauthHeaders('GET', url, extraParams: extraParams);
    final queryString = extraParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    try {
      final response = await http.get(
        Uri.parse('$url?$queryString'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final food = data['food'];
      if (food == null) return null;

      return _parseFoodItem(food, barcode: barcode);
    } catch (_) {
      return null;
    }
  }

  static Future<List<FoodItem>> searchByName(String query) async {
    const url = 'https://platform.fatsecret.com/rest/server.api';

    final extraParams = {
      'method': 'foods.search',
      'search_expression': query,
      'format': 'json',
      'page': '0',
      'max_results': '10',
    };

    final headers = _oauthHeaders('GET', url, extraParams: extraParams);
    final queryString = extraParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    try {
      final response = await http.get(
        Uri.parse('$url?$queryString'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final foods = data['foods']?['food'] as List? ?? [];

      return foods.map((f) => _parseFoodItem(f)).whereType<FoodItem>().toList();
    } catch (_) {
      return [];
    }
  }

  static FoodItem? _parseFoodItem(dynamic food, {String? barcode}) {
    try {
      final desc = food['food_description'] as String? ?? '';
      final nutrients = _parseDescription(desc);

      String? brand;
      if (food['brand_name'] != null && (food['brand_name'] as String).isNotEmpty) {
        brand = food['brand_name'];
      }

      return FoodItem(
        name: food['food_name'] ?? 'Неизвестный продукт',
        barcode: barcode ?? food['food_id']?.toString(),
        calories: nutrients['calories'] ?? 0,
        protein: nutrients['protein'] ?? 0,
        fat: nutrients['fat'] ?? 0,
        carbs: nutrients['carbs'] ?? 0,
        brand: brand,
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, double> _parseDescription(String desc) {
    final result = <String, double>{};

    final calMatch = RegExp(r'(\d+[\.,]?\d*)\s*kcal').firstMatch(desc.toLowerCase());
    if (calMatch != null) {
      result['calories'] = double.tryParse(calMatch.group(1)!.replaceAll(',', '.')) ?? 0;
    }

    final protMatch = RegExp(r'protein[:\s]*(\d+[\.,]?\d*)\s*g').firstMatch(desc.toLowerCase());
    if (protMatch != null) {
      result['protein'] = double.tryParse(protMatch.group(1)!.replaceAll(',', '.')) ?? 0;
    }

    final fatMatch = RegExp(r'fat[:\s]*(\d+[\.,]?\d*)\s*g').firstMatch(desc.toLowerCase());
    if (fatMatch != null) {
      result['fat'] = double.tryParse(fatMatch.group(1)!.replaceAll(',', '.')) ?? 0;
    }

    final carbMatch = RegExp(r'carb[:\s]*(\d+[\.,]?\d*)\s*g').firstMatch(desc.toLowerCase());
    if (carbMatch != null) {
      result['carbs'] = double.tryParse(carbMatch.group(1)!.replaceAll(',', '.')) ?? 0;
    }

    return result;
  }
}
