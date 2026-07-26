import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition.dart';

class FoodApiService {
  static Future<FoodItem?> searchByBarcode(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data['status'] != 1) return null;

      final product = data['product'];
      if (product == null) return null;

      final nutriments = product['nutriments'] ?? {};

      return FoodItem(
        name: product['product_name'] ?? product['generic_name'] ?? 'Неизвестный продукт',
        barcode: barcode,
        calories: _toDouble(nutriments['energy-kcal_100g']),
        protein: _toDouble(nutriments['proteins_100g']),
        fat: _toDouble(nutriments['fat_100g']),
        carbs: _toDouble(nutriments['carbohydrates_100g']),
        brand: product['brands'],
        imageUrl: product['image_front_url'],
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<FoodItem>> searchByName(String query) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=10',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final products = data['products'] as List? ?? [];

      return products.map<FoodItem>((p) {
        final nutriments = p['nutriments'] ?? {};
        return FoodItem(
          name: p['product_name'] ?? 'Неизвестный продукт',
          barcode: p['code'],
          calories: _toDouble(nutriments['energy-kcal_100g']),
          protein: _toDouble(nutriments['proteins_100g']),
          fat: _toDouble(nutriments['fat_100g']),
          carbs: _toDouble(nutriments['carbohydrates_100g']),
          brand: p['brands'],
          imageUrl: p['image_front_url'],
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
