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
  double monthlyTarget;

  @HiveField(4)
  String unit;

  @HiveField(5)
  bool isBoolean;

  @HiveField(6)
  DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    this.icon = '✅',
    this.monthlyTarget = 30,
    this.unit = 'раз',
    this.isBoolean = false,
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
  double value;

  HabitEntry({
    required this.habitId,
    required this.date,
    this.value = 1,
  });

  @override
  String get key => '${habitId}_${date.year}_${date.month}_${date.day}';
}
