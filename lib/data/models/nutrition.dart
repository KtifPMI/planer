import 'package:hive/hive.dart';

part 'nutrition.g.dart';

@HiveType(typeId: 17)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snack,
}

@HiveType(typeId: 18)
class FoodItem extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String? barcode;
  @HiveField(2) double calories;
  @HiveField(3) double protein;
  @HiveField(4) double fat;
  @HiveField(5) double carbs;
  @HiveField(6) String? brand;
  @HiveField(7) String? imageUrl;

  FoodItem({
    required this.name,
    this.barcode,
    this.calories = 0,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.brand,
    this.imageUrl,
  });
}

@HiveType(typeId: 19)
class MealEntry extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String foodName;
  @HiveField(2) MealType mealType;
  @HiveField(3) double grams;
  @HiveField(4) double calories;
  @HiveField(5) double protein;
  @HiveField(6) double fat;
  @HiveField(7) double carbs;
  @HiveField(8) DateTime date;
  @HiveField(9) String? barcode;

  MealEntry({
    required this.id,
    required this.foodName,
    required this.mealType,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.date,
    this.barcode,
  });

  double get caloriesPerGram => grams > 0 ? calories / grams : 0;
  double get proteinPerGram => grams > 0 ? protein / grams : 0;
  double get fatPerGram => grams > 0 ? fat / grams : 0;
  double get carbsPerGram => grams > 0 ? carbs / grams : 0;
}
