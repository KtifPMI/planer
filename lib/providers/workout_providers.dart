import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/workout.dart';
import '../data/repositories/workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final selectedWorkoutMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final allWorkoutsProvider = Provider((ref) {
  final month = ref.watch(selectedWorkoutMonthProvider);
  return ref.watch(workoutRepositoryProvider)
      .getSessionsForMonth(month.year, month.month);
});

final monthWorkoutsProvider = Provider((ref) {
  final now = DateTime.now();
  return ref.watch(workoutRepositoryProvider)
      .getSessionsForMonth(now.year, now.month);
});

final latestWorkoutProvider = Provider((ref) {
  return ref.watch(workoutRepositoryProvider).getLatestSession();
});

final workoutCountThisMonthProvider = Provider<int>((ref) {
  final month = ref.watch(selectedWorkoutMonthProvider);
  return ref.watch(workoutRepositoryProvider)
      .getSessionsThisMonth(month.year, month.month);
});

final exerciseProgressListProvider = Provider<List<ProgressEntry>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  final allSessions = repo.getAllSessions();
  final Map<String, List<WeightEntry>> exerciseData = {};

  for (final session in allSessions) {
    for (final ex in session.exercises) {
      if (ex.sets.isEmpty) continue;
      exerciseData.putIfAbsent(ex.exerciseName, () => []);
      final maxSet = ex.sets.reduce((a, b) => a.weight >= b.weight ? a : b);
      exerciseData[ex.exerciseName]!.add(WeightEntry(
        date: session.date,
        weight: maxSet.weight,
        reps: maxSet.reps,
      ));
    }
  }

  return exerciseData.entries
      .map((e) => ProgressEntry(
            exerciseName: e.key,
            entries: e.value..sort((a, b) => a.date.compareTo(b.date)),
          ))
      .toList()
    ..sort((a, b) => b.entries.length.compareTo(a.entries.length));
});

class ProgressEntry {
  final String exerciseName;
  final List<WeightEntry> entries;
  const ProgressEntry({required this.exerciseName, required this.entries});
}

class WeightEntry {
  final DateTime date;
  final double weight;
  final int reps;
  const WeightEntry({required this.date, required this.weight, required this.reps});
}

final exerciseTemplatesProvider = Provider((ref) {
  return ref.watch(workoutRepositoryProvider).getAllTemplates();
});

final weightProgressionProvider =
    Provider.family<List<double>, String>((ref, exerciseName) {
  return ref.watch(workoutRepositoryProvider)
      .getWeightProgression(exerciseName);
});

final allWorkoutTemplatesProvider = Provider<List<WorkoutTemplate>>((ref) {
  return ref.watch(workoutRepositoryProvider).getAllWorkoutTemplates();
});

final todayWorkoutTemplatesProvider = Provider<List<WorkoutTemplate>>((ref) {
  final today = DateTime.now().weekday;
  return ref.watch(workoutRepositoryProvider).getTemplatesForDay(today);
});

final todaySessionProvider = Provider<WorkoutSession?>((ref) {
  return ref.watch(workoutRepositoryProvider).getSessionForDate(DateTime.now());
});

final workoutTemplatesThisWeekProvider = Provider<int>((ref) {
  final templates = ref.watch(allWorkoutTemplatesProvider);
  return templates.where((t) => t.dayOfWeek > 0).length;
});

final workoutCountThisWeekProvider = Provider<int>((ref) {
  return ref.watch(workoutRepositoryProvider).getSessionsForWeek(DateTime.now());
});

void invalidateAllWorkouts(WidgetRef ref) {
  ref.invalidate(allWorkoutsProvider);
  ref.invalidate(monthWorkoutsProvider);
  ref.invalidate(latestWorkoutProvider);
  ref.invalidate(workoutCountThisMonthProvider);
  ref.invalidate(todaySessionProvider);
  ref.invalidate(allWorkoutTemplatesProvider);
  ref.invalidate(todayWorkoutTemplatesProvider);
  ref.invalidate(workoutTemplatesThisWeekProvider);
  ref.invalidate(workoutCountThisWeekProvider);
  ref.invalidate(exerciseProgressListProvider);
}
