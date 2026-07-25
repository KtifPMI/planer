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

  // Entries
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

  List<HabitEntry> getEntriesForMonth(int year, int month) {
    return _entriesBox.values
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  bool isCompleted(String habitId, DateTime date) {
    return _entriesBox.values.any(
      (e) => e.habitId == habitId && _isSameDay(e.date, date),
    );
  }

  Future<void> toggleCompletion(String habitId, DateTime date) async {
    final existing = _entriesBox.values
        .where((e) => e.habitId == habitId && _isSameDay(e.date, date))
        .toList();

    if (existing.isNotEmpty) {
      await _entriesBox.delete(existing.first.key);
    } else {
      final entry = HabitEntry(habitId: habitId, date: date);
      await _entriesBox.put(entry.key, entry);
    }
  }

  int getCompletedCount(String habitId, int year, int month) {
    return _entriesBox.values
        .where((e) =>
            e.habitId == habitId &&
            e.date.year == year &&
            e.date.month == month)
        .length;
  }

  double getProgress(String habitId, int year, int month, int target) {
    if (target <= 0) return 0;
    final completed = getCompletedCount(habitId, year, month);
    return (completed / target).clamp(0.0, 1.0);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
