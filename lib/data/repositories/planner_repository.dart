import 'package:uuid/uuid.dart';
import '../models/planner.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../services/storage_service.dart';

class PlannerRepository {
  final _box = StorageService.weeklyPlansBox;
  static const _uuid = Uuid();

  WeeklyPlan getCurrentWeek() {
    final weekStart = app_date.startOfWeek(DateTime.now());
    final existing = _box.values
        .where((p) => app_date.isSameDay(p.weekStart, weekStart))
        .toList();
    if (existing.isNotEmpty) return existing.first;

    final plan = WeeklyPlan(
      id: generateId(),
      weekStart: weekStart,
      days: {
        for (int i = 0; i < 7; i++)
          _dateKey(weekStart.add(Duration(days: i))): DayPlan(),
      },
    );
    _box.put(plan.id, plan);
    return plan;
  }

  WeeklyPlan? getWeekByDate(DateTime date) {
    final weekStart = app_date.startOfWeek(date);
    final results = _box.values
        .where((p) => app_date.isSameDay(p.weekStart, weekStart))
        .toList();
    return results.isNotEmpty ? results.first : null;
  }

  List<WeeklyPlan> getAllWeeks() =>
      _box.values.toList()..sort((a, b) => b.weekStart.compareTo(a.weekStart));

  Future<void> updatePlan(WeeklyPlan plan) => _box.put(plan.id, plan);

  // Goals
  Future<void> addGoal(String planId, String title) async {
    final plan = _box.get(planId);
    if (plan == null) return;
    plan.goals = [...plan.goals, WeekGoal(title: title)];
    await plan.save();
  }

  Future<void> toggleGoal(String planId, int goalIndex) async {
    final plan = _box.get(planId);
    if (plan == null || goalIndex >= plan.goals.length) return;
    plan.goals[goalIndex].completed = !plan.goals[goalIndex].completed;
    await plan.save();
  }

  Future<void> deleteGoal(String planId, int goalIndex) async {
    final plan = _box.get(planId);
    if (plan == null || goalIndex >= plan.goals.length) return;
    final goals = List<WeekGoal>.from(plan.goals);
    goals.removeAt(goalIndex);
    plan.goals = goals;
    await plan.save();
  }

  // Tasks
  Future<void> addTask(String planId, DateTime date, String title) async {
    final plan = _box.get(planId);
    if (plan == null) return;
    final key = _dateKey(date);
    final dayPlan = plan.days[key] ?? DayPlan();
    dayPlan.tasks = [...dayPlan.tasks, PlannerTask(title: title)];
    plan.days[key] = dayPlan;
    await plan.save();
  }

  Future<void> toggleTask(String planId, DateTime date, int taskIndex) async {
    final plan = _box.get(planId);
    if (plan == null) return;
    final key = _dateKey(date);
    final dayPlan = plan.days[key];
    if (dayPlan == null || taskIndex >= dayPlan.tasks.length) return;
    dayPlan.tasks[taskIndex].completed = !dayPlan.tasks[taskIndex].completed;
    await plan.save();
  }

  Future<void> deleteTask(String planId, DateTime date, int taskIndex) async {
    final plan = _box.get(planId);
    if (plan == null) return;
    final key = _dateKey(date);
    final dayPlan = plan.days[key];
    if (dayPlan == null || taskIndex >= dayPlan.tasks.length) return;
    final tasks = List<PlannerTask>.from(dayPlan.tasks);
    tasks.removeAt(taskIndex);
    dayPlan.tasks = tasks;
    await plan.save();
  }

  Future<void> editTask(String planId, DateTime date, int taskIndex, String newTitle) async {
    final plan = _box.get(planId);
    if (plan == null) return;
    final key = _dateKey(date);
    final dayPlan = plan.days[key];
    if (dayPlan == null || taskIndex >= dayPlan.tasks.length) return;
    dayPlan.tasks[taskIndex].title = newTitle;
    await plan.save();
  }

  Future<void> editGoal(String planId, int goalIndex, String newTitle) async {
    final plan = _box.get(planId);
    if (plan == null || goalIndex >= plan.goals.length) return;
    plan.goals[goalIndex].title = newTitle;
    await plan.save();
  }

  // Notes
  Future<void> updateNote(String planId, DateTime date, String? note) async {
    final plan = _box.get(planId);
    if (plan == null) return;
    final key = _dateKey(date);
    final dayPlan = plan.days[key] ?? DayPlan();
    dayPlan.note = note;
    plan.days[key] = dayPlan;
    await plan.save();
  }

  // Analytics
  Map<String, dynamic> getWeekAnalytics(WeeklyPlan plan) {
    int totalTasks = 0;
    int completedTasks = 0;
    int totalGoals = plan.goals.length;
    int completedGoals = plan.goals.where((g) => g.completed).length;

    for (final dayPlan in plan.days.values) {
      totalTasks += dayPlan.totalCount;
      completedTasks += dayPlan.completedCount;
    }

    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    String mostProductiveDay = '';
    double maxDayProgress = 0;
    for (final entry in plan.days.entries) {
      if (entry.value.progress > maxDayProgress && entry.value.totalCount > 0) {
        maxDayProgress = entry.value.progress;
        mostProductiveDay = entry.key;
      }
    }

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'progress': progress,
      'mostProductiveDay': mostProductiveDay,
    };
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String generateId() => _uuid.v4();
}
