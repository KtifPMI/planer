import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final allHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).getAll();
});

final todayEntriesProvider = Provider<List<HabitEntry>>((ref) {
  return ref.watch(habitRepositoryProvider).getEntriesForDate(DateTime.now());
});

final habitsWithProgressProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  final habits = repo.getAll();
  final now = DateTime.now();

  return habits.map((habit) {
    final completed = repo.isCompleted(habit.id, now);
    final monthProgress = repo.getProgress(
      habit.id, now.year, now.month, habit.targetPerMonth,
    );
    return {
      'habit': habit,
      'completedToday': completed,
      'monthProgress': monthProgress,
      'completedCount': repo.getCompletedCount(habit.id, now.year, now.month),
    };
  }).toList();
});

final monthHabitStatsProvider =
    Provider.family<Map<String, dynamic>, String>((ref, habitId) {
  final repo = ref.watch(habitRepositoryProvider);
  final now = DateTime.now();
  final habit = repo.getById(habitId);
  if (habit == null) return {};

  final entries = repo.getEntriesForMonth(now.year, now.month);
  final habitEntries = entries.where((e) => e.habitId == habitId).toList();
  final completed = habitEntries.length;
  final target = habit.targetPerMonth;
  final progress = target > 0 ? (completed / target).clamp(0.0, 1.0) : 0.0;

  return {
    'completed': completed,
    'target': target,
    'progress': progress,
    'entries': habitEntries,
  };
});
