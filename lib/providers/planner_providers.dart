import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/planner_repository.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository();
});

final currentWeekProvider = Provider((ref) {
  return ref.watch(plannerRepositoryProvider).getCurrentWeek();
});

final weekAnalyticsProvider = Provider<Map<String, dynamic>>((ref) {
  final plan = ref.watch(currentWeekProvider);
  return ref.watch(plannerRepositoryProvider).getWeekAnalytics(plan);
});
