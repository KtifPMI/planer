import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/nutrition.dart';
import '../data/repositories/nutrition_repository.dart';
import '../data/services/food_api_service.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository();
});

final selectedNutritionDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final todayMealEntriesProvider = Provider<List<MealEntry>>((ref) {
  final date = ref.watch(selectedNutritionDateProvider);
  return ref.watch(nutritionRepositoryProvider).getEntriesForDate(date);
});

final todayNutritionTotalsProvider = Provider<Map<String, double>>((ref) {
  final date = ref.watch(selectedNutritionDateProvider);
  return ref.watch(nutritionRepositoryProvider).getDailyTotals(date);
});

final mealEntriesForTypeProvider = Provider.family<List<MealEntry>, MealType>((ref, mealType) {
  final date = ref.watch(selectedNutritionDateProvider);
  return ref.watch(nutritionRepositoryProvider).getEntriesForMeal(date, mealType);
});

final foodSearchQueryProvider = StateProvider<String>((ref) => '');

final foodSearchResultsProvider = FutureProvider<List<FoodItem>>((ref) async {
  final query = ref.watch(foodSearchQueryProvider);
  if (query.isEmpty) return [];
  return FoodApiService.searchByName(query);
});
