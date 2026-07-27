import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final habitsListProvider = StateNotifierProvider<HabitsListNotifier, List<Habit>>((ref) {
  return HabitsListNotifier(ref.read(habitRepositoryProvider));
});

class HabitsListNotifier extends StateNotifier<List<Habit>> {
  final HabitRepository _repo;

  HabitsListNotifier(this._repo) : super([]) {
    _repo.seedDefaults();
    load();
  }

  void load() => state = _repo.getAll();

  Future<void> add(Habit habit) async {
    await _repo.add(habit);
    load();
  }

  Future<void> update(Habit habit) async {
    await _repo.update(habit);
    load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    load();
  }
}

// Current month/year for tracking
final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected date on the habits screen
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Entries for selected date
final entriesForDateProvider = Provider.family<List<HabitEntry>, DateTime>((ref, date) {
  final repo = ref.read(habitRepositoryProvider);
  return repo.getEntriesForDate(date);
});

// Get value for specific habit on specific date
final habitValueProvider = Provider.family<double, Map<String, dynamic>>((ref, params) {
  final repo = ref.read(habitRepositoryProvider);
  final habitId = params['habitId'] as String;
  final date = params['date'] as DateTime;
  return repo.getValueForDate(habitId, date);
});

// Monthly total for habit
final habitMonthlyTotalProvider = Provider.family<double, Map<String, dynamic>>((ref, params) {
  final repo = ref.read(habitRepositoryProvider);
  final habitId = params['habitId'] as String;
  final year = params['year'] as int;
  final month = params['month'] as int;
  return repo.getMonthlyTotal(habitId, year, month);
});

// Monthly progress for habit (0..1)
final habitMonthlyProgressProvider = Provider.family<double, Map<String, dynamic>>((ref, params) {
  final repo = ref.read(habitRepositoryProvider);
  final habitId = params['habitId'] as String;
  final year = params['year'] as int;
  final month = params['month'] as int;
  final target = params['target'] as double;
  return repo.getMonthlyProgress(habitId, year, month, target);
});

// Days completed in month
final habitDaysCompletedProvider = Provider.family<int, Map<String, dynamic>>((ref, params) {
  final repo = ref.read(habitRepositoryProvider);
  final habitId = params['habitId'] as String;
  final year = params['year'] as int;
  final month = params['month'] as int;
  return repo.getDaysCompletedInMonth(habitId, year, month);
});

// Set entry
final setEntryProvider = Provider<HabitEntrySetter>((ref) {
  return HabitEntrySetter(ref.read(habitRepositoryProvider));
});

class HabitEntrySetter {
  final HabitRepository _repo;
  HabitEntrySetter(this._repo);

  Future<void> set(String habitId, DateTime date, double value) async {
    await _repo.setEntry(habitId, date, value);
  }
}

// Today's completion stats
final todayStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final repo = ref.read(habitRepositoryProvider);
  final today = DateTime.now();
  final habits = repo.getScheduledForDate(today);
  int done = 0;
  for (final h in habits) {
    if (repo.getValueForDate(h.id, today) > 0) done++;
  }
  return {'done': done, 'total': habits.length};
});
