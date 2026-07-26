import 'package:hive/hive.dart';

@HiveType(typeId: 21)
class RecipeIngredient extends HiveObject {
  @HiveField(0) String foodName;
  @HiveField(1) double grams;
  @HiveField(2) double calories;
  @HiveField(3) double protein;
  @HiveField(4) double fat;
  @HiveField(5) double carbs;
  @HiveField(6) String? barcode;

  RecipeIngredient({
    required this.foodName,
    required this.grams,
    this.calories = 0,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.barcode,
  });
}

@HiveType(typeId: 20)
class Recipe extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) List<RecipeIngredient> ingredients;
  @HiveField(3) double targetCalories;
  @HiveField(4) double targetProtein;
  @HiveField(5) double targetFat;
  @HiveField(6) double targetCarbs;
  @HiveField(7) int servings;
  @HiveField(8) DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    this.ingredients = const [],
    this.targetCalories = 0,
    this.targetProtein = 0,
    this.targetFat = 0,
    this.targetCarbs = 0,
    this.servings = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalCalories => ingredients.fold(0, (s, i) => s + i.calories);
  double get totalProtein => ingredients.fold(0, (s, i) => s + i.protein);
  double get totalFat => ingredients.fold(0, (s, i) => s + i.fat);
  double get totalCarbs => ingredients.fold(0, (s, i) => s + i.carbs);

  double get totalGrams => ingredients.fold(0, (s, i) => s + i.grams);

  double caloriesPerServing => servings > 0 ? totalCalories / servings : 0;
  double proteinPerServing => servings > 0 ? totalProtein / servings : 0;
  double fatPerServing => servings > 0 ? totalFat / servings : 0;
  double carbsPerServing => servings > 0 ? totalCarbs / servings : 0;
}
