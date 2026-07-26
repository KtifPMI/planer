import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition.dart';

class FoodApiException implements Exception {
  final String message;
  final bool isNotFound;
  FoodApiException(this.message, {this.isNotFound = false});
  @override
  String toString() => message;
}

class FoodApiService {
  static Future<FoodItem?> searchByBarcode(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json?lang=ru&fields=product_name,generic_name,nutriments,brands,image_front_url',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw FoodApiException('Ошибка сервера (${response.statusCode})');
      }

      final data = json.decode(response.body);
      if (data['status'] != 1 || data['product'] == null) {
        throw FoodApiException(
          'Продукт с штрихкодом $barcode не найден в базе OpenFoodFacts',
          isNotFound: true,
        );
      }

      final product = data['product'];
      final nutriments = product['nutriments'] ?? {};

      final name = product['product_name'] ??
          product['generic_name'] ??
          'Неизвестный продукт';

      return FoodItem(
        name: name,
        barcode: barcode,
        calories: _toDouble(nutriments['energy-kcal_100g']),
        protein: _toDouble(nutriments['proteins_100g']),
        fat: _toDouble(nutriments['fat_100g']),
        carbs: _toDouble(nutriments['carbohydrates_100g']),
        brand: product['brands'],
        imageUrl: product['image_front_url'],
      );
    } on FoodApiException {
      rethrow;
    } catch (e) {
      throw FoodApiException('Нет подключения к интернету или таймаут запроса');
    }
  }

  static Future<List<FoodItem>> searchByName(String query) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=10&lang=ru',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
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
