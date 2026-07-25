import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int targetPerMonth;

  @HiveField(4)
  List<int> daysOfWeek;

  @HiveField(5)
  DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    this.icon = '✅',
    this.targetPerMonth = 20,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

@HiveType(typeId: 1)
class HabitEntry extends HiveObject {
  @HiveField(0)
  String habitId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  bool completed;

  HabitEntry({
    required this.habitId,
    required this.date,
    this.completed = true,
  });

  String get key => '${habitId}_${date.year}_${date.month}_${date.day}';
}
