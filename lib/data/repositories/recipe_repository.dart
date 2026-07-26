import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';

class RecipeRepository {
  final _box = StorageService.recipesBox;
  static const _uuid = Uuid();

  static String generateId() => _uuid.v4();

  List<Recipe> getAll() {
    return _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Recipe? getById(String id) {
    return _box.get(id);
  }

  Future<void> save(Recipe recipe) async {
    await _box.put(recipe.id, recipe);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
