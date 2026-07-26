import 'package:uuid/uuid.dart';
import '../models/nutrition.dart';
import '../services/storage_service.dart';

class NutritionRepository {
  final _mealEntries = StorageService.mealEntriesBox;
  static const _uuid = Uuid();

  static String generateId() => _uuid.v4();

  List<MealEntry> getEntriesForDate(DateTime date) {
    return _mealEntries.values
        .where((e) => _isSameDay(e.date, date))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<MealEntry> getEntriesForMeal(DateTime date, MealType mealType) {
    return _mealEntries.values
        .where((e) => _isSameDay(e.date, date) && e.mealType == mealType)
        .toList();
  }

  Future<void> addEntry(MealEntry entry) async {
    await _mealEntries.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await _mealEntries.delete(id);
  }

  Map<String, double> getDailyTotals(DateTime date) {
    final entries = getEntriesForDate(date);
    double calories = 0, protein = 0, fat = 0, carbs = 0;
    for (final e in entries) {
      calories += e.calories;
      protein += e.protein;
      fat += e.fat;
      carbs += e.carbs;
    }
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  List<MealEntry> getWeekEntries(DateTime weekStart) {
    final entries = <MealEntry>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      entries.addAll(getEntriesForDate(day));
    }
    return entries;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
