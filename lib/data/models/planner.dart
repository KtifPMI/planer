import 'package:hive/hive.dart';

part 'planner.g.dart';

@HiveType(typeId: 12)
class WeeklyPlan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime weekStart;

  @HiveField(2)
  List<WeekGoal> goals;

  @HiveField(3)
  Map<String, DayPlan> days;

  WeeklyPlan({
    required this.id,
    required this.weekStart,
    this.goals = const [],
    Map<String, DayPlan>? days,
  }) : days = days ?? {};
}

@HiveType(typeId: 13)
class WeekGoal extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool completed;

  WeekGoal({
    required this.title,
    this.completed = false,
  });
}

@HiveType(typeId: 14)
class DayPlan extends HiveObject {
  @HiveField(0)
  List<PlannerTask> tasks;

  @HiveField(1)
  String? note;

  DayPlan({
    this.tasks = const [],
    this.note,
  });

  int get completedCount => tasks.where((t) => t.completed).length;
  int get totalCount => tasks.length;
  double get progress => totalCount > 0 ? completedCount / totalCount : 0;
}

@HiveType(typeId: 15)
class PlannerTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool completed;

  PlannerTask({
    required this.title,
    this.completed = false,
  });
}
