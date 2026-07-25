import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';

class HabitRepository {
  final _box = StorageService.habitsBox;
  final _entriesBox = StorageService.habitEntriesBox;
  static const _uuid = Uuid();

  List<Habit> getAll() => _box.values.toList();

  Future<void> add(Habit habit) => _box.put(habit.id, habit);

  Future<void> update(Habit habit) => _box.put(habit.id, habit);

  Future<void> delete(String id) async {
    await _box.delete(id);
    final keys = _entriesBox.values
        .where((e) => e.habitId == id)
        .map((e) => e.key)
        .toList();
    await _entriesBox.deleteAll(keys);
  }

  Habit? getById(String id) => _box.get(id);

  static String generateId() => _uuid.v4();

  void seedDefaults() {
    if (_box.isNotEmpty) return;

    final defaults = [
      Habit(id: generateId(), name: 'Спорт / движение', icon: '🏃', monthlyTarget: 20, unit: 'раз'),
      Habit(id: generateId(), name: 'Гидратация (2 л воды)', icon: '💧', monthlyTarget: 30, unit: 'дней'),
      Habit(id: generateId(), name: 'Чтение 20 мин', icon: '📖', monthlyTarget: 25, unit: 'дней'),
      Habit(id: generateId(), name: 'Цифровой детокс 1 ч', icon: '📵', monthlyTarget: 20, unit: 'дней'),
      Habit(id: generateId(), name: 'Медитация 15 мин', icon: '🧘', monthlyTarget: 20, unit: 'дней'),
      Habit(id: generateId(), name: 'Дневник 10 мин', icon: '📝', monthlyTarget: 20, unit: 'дней'),
      Habit(id: generateId(), name: 'Планирование дня', icon: '🗒', monthlyTarget: 26, unit: 'дней'),
      Habit(id: generateId(), name: 'Ранний подъём', icon: '⏰', monthlyTarget: 20, unit: 'дней'),
      Habit(id: generateId(), name: 'Сон 8 ч до 23:00', icon: '😴', monthlyTarget: 26, unit: 'дней'),
    ];

    for (final h in defaults) {
      _box.put(h.id, h);
    }
  }

  // --- Entries ---

  List<HabitEntry> getEntriesForDate(DateTime date) {
    return _entriesBox.values
        .where((e) => _isSameDay(e.date, date))
        .toList();
  }

  List<HabitEntry> getEntriesForHabit(String habitId) {
    return _entriesBox.values
        .where((e) => e.habitId == habitId)
        .toList();
  }

  List<HabitEntry> getEntriesForMonth(String habitId, int year, int month) {
    return _entriesBox.values
        .where((e) =>
            e.habitId == habitId &&
            e.date.year == year &&
            e.date.month == month)
        .toList();
  }

  double getValueForDate(String habitId, DateTime date) {
    final entry = _entriesBox.values
        .where((e) =>
            e.habitId == habitId && _isSameDay(e.date, date))
        .toList();
    return entry.isNotEmpty ? entry.first.value : 0;
  }

  double getMonthlyTotal(String habitId, int year, int month) {
    return _entriesBox.values
        .where((e) =>
            e.habitId == habitId &&
            e.date.year == year &&
            e.date.month == month)
        .fold(0, (sum, e) => sum + e.value);
  }

  double getMonthlyProgress(String habitId, int year, int month, double target) {
    if (target <= 0) return 0;
    final total = getMonthlyTotal(habitId, year, month);
    return (total / target).clamp(0.0, 1.0);
  }

  int getDaysCompletedInMonth(String habitId, int year, int month) {
    return _entriesBox.values
        .where((e) =>
            e.habitId == habitId &&
            e.date.year == year &&
            e.date.month == month &&
            e.value > 0)
        .length;
  }

  Future<void> setEntry(String habitId, DateTime date, double value) async {
    final existing = _entriesBox.values
        .where((e) =>
            e.habitId == habitId && _isSameDay(e.date, date))
        .toList();

    if (existing.isNotEmpty) {
      if (value <= 0) {
        await _entriesBox.delete(existing.first.key);
      } else {
        existing.first.value = value;
        await existing.first.save();
      }
    } else if (value > 0) {
      final entry = HabitEntry(habitId: habitId, date: date, value: value);
      await _entriesBox.put(entry.key, entry);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
