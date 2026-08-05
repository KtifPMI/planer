import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart' as app_date;
import '../data/repositories/planner_repository.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository();
});

final selectedPlannerWeekProvider = StateProvider<DateTime>((ref) {
  return app_date.startOfWeek(DateTime.now());
});

final currentWeekProvider = Provider((ref) {
  final date = ref.watch(selectedPlannerWeekProvider);
  return ref.watch(plannerRepositoryProvider).getOrCreateWeek(date);
});

final weekAnalyticsProvider = Provider<Map<String, dynamic>>((ref) {
  final plan = ref.watch(currentWeekProvider);
  return ref.watch(plannerRepositoryProvider).getWeekAnalytics(plan);
});
