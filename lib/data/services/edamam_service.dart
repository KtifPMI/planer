import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition.dart';

class EdamamService {
  static const _appId = 'YOUR_EDAMAM_APP_ID';
  static const _appKey = 'YOUR_EDAMAM_APP_KEY';
  static const _baseUrl = 'https://api.edamam.com/api/food-database/v2';

  static Future<FoodItem?> searchByBarcode(String barcode) async {
    final url = Uri.parse(
      '$_baseUrl/parser?upc=$barcode&app_id=$_appId&app_key=$_appKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final hints = data['hints'] as List? ?? [];
      if (hints.isEmpty) return null;

      final food = hints[0]['food'];
      if (food == null) return null;

      final nutrients = food['nutrients'] ?? {};

      return FoodItem(
        name: food['label'] ?? 'Неизвестный продукт',
        barcode: barcode,
        calories: (nutrients['ENERC_KCAL'] as num?)?.toDouble() ?? 0,
        protein: (nutrients['PROCNT'] as num?)?.toDouble() ?? 0,
        fat: (nutrients['FAT'] as num?)?.toDouble() ?? 0,
        carbs: (nutrients['CHOCDF'] as num?)?.toDouble() ?? 0,
        brand: food['brand'],
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<FoodItem>> searchByName(String query) async {
    final url = Uri.parse(
      '$_baseUrl/autocomplete?ingr=${Uri.encodeComponent(query)}&app_id=$_appId&app_key=$_appKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final hints = data['hints'] as List? ?? [];

      final results = <FoodItem>[];
      for (final hint in hints.take(10)) {
        final food = hint['food'];
        if (food == null) continue;
        final nutrients = food['nutrients'] ?? {};
        results.add(FoodItem(
          name: food['label'] ?? 'Неизвестный продукт',
          calories: (nutrients['ENERC_KCAL'] as num?)?.toDouble() ?? 0,
          protein: (nutrients['PROCNT'] as num?)?.toDouble() ?? 0,
          fat: (nutrients['FAT'] as num?)?.toDouble() ?? 0,
          carbs: (nutrients['CHOCDF'] as num?)?.toDouble() ?? 0,
          brand: food['brand'],
        ));
      }
      return results;
    } catch (_) {
      return [];
    }
  }
}
