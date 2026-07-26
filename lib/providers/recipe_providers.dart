import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/recipe.dart';
import '../data/repositories/recipe_repository.dart';
import '../data/services/storage_service.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});

final recipesListProvider = Provider<List<Recipe>>((ref) {
  ref.watch(recipesRefreshProvider);
  return ref.watch(recipeRepositoryProvider).getAll();
});

final recipesRefreshProvider = StateProvider<int>((ref) => 0);

void refreshRecipes(WidgetRef ref) {
  ref.read(recipesRefreshProvider.notifier).state++;
}

class NutritionTargets {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const NutritionTargets({
    this.calories = 2000,
    this.protein = 120,
    this.fat = 40,
    this.carbs = 250,
  });
}

final nutritionTargetsProvider = StateProvider<NutritionTargets>((ref) {
  final box = StorageService.settingsBox;
  return NutritionTargets(
    calories: (box.get('targetCalories') as num?)?.toDouble() ?? 2000,
    protein: (box.get('targetProtein') as num?)?.toDouble() ?? 120,
    fat: (box.get('targetFat') as num?)?.toDouble() ?? 40,
    carbs: (box.get('targetCarbs') as num?)?.toDouble() ?? 250,
  );
});

void saveNutritionTargets(WidgetRef ref, NutritionTargets targets) {
  final box = StorageService.settingsBox;
  box.put('targetCalories', targets.calories);
  box.put('targetProtein', targets.protein);
  box.put('targetFat', targets.fat);
  box.put('targetCarbs', targets.carbs);
  ref.read(nutritionTargetsProvider.notifier).state = targets;
}
