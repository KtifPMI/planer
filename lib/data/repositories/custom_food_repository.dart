import 'package:uuid/uuid.dart';
import '../models/nutrition.dart';
import '../services/storage_service.dart';

class CustomFoodRepository {
  final _box = StorageService.customFoodsBox;
  static const _uuid = Uuid();

  static String generateId() => _uuid.v4();

  List<FoodItem> getAll() {
    return _box.values.toList();
  }

  List<FoodItem> search(String query) {
    if (query.isEmpty) return getAll();
    final q = query.toLowerCase();
    return _box.values.where((f) =>
      f.name.toLowerCase().contains(q) ||
      (f.brand?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  FoodItem? getById(String id) {
    return _box.get(id);
  }

  Future<void> save(FoodItem food) async {
    if (food.barcode == null || food.barcode!.isEmpty) {
      food.barcode = generateId();
    }
    await _box.put(food.barcode, food);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
