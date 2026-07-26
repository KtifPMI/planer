import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition.dart';
import '../config/api_config.dart';

class FatSecretService {
  static String? _accessToken;
  static DateTime? _tokenExpiry;

  static Future<String?> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    final credentials = base64Encode(
      utf8.encode('${ApiConfig.fatSecretClientId}:${ApiConfig.fatSecretClientSecret}'),
    );

    try {
      final response = await http.post(
        Uri.parse('https://oauth.fatsecret.com/connect/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials&scope=basic',
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int? ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
        return _accessToken;
      }
    } catch (_) {}
    return null;
  }

  static Future<FoodItem?> searchByBarcode(String barcode) async {
    final token = await _getAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('https://platform.fatsecret.com/rest/server.api?method=food.get.v3&barcode=$barcode&format=json'),
        headers: {'Authorization': 'Bearer $token'},
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
    final token = await _getAccessToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://platform.fatsecret.com/rest/server.api?method=foods.search&search_expression=${Uri.encodeComponent(query)}&format=json&page=0&max_results=10',
        ),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final foods = data['foods']?['food'] as List? ?? [];

      return foods.map<FoodItem>((f) => _parseFoodItem(f)).whereType<FoodItem>().toList();
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
