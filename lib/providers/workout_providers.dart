import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final allWorkoutsProvider = Provider((ref) {
  return ref.watch(workoutRepositoryProvider).getAllSessions();
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
  final now = DateTime.now();
  return ref.watch(workoutRepositoryProvider)
      .getSessionsThisMonth(now.year, now.month);
});

final exerciseTemplatesProvider = Provider((ref) {
  return ref.watch(workoutRepositoryProvider).getAllTemplates();
});

final weightProgressionProvider =
    Provider.family<List<double>, String>((ref, exerciseName) {
  return ref.watch(workoutRepositoryProvider)
      .getWeightProgression(exerciseName);
});
