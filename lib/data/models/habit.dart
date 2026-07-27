import 'package:hive/hive.dart';

part 'habit.g.dart';

enum HabitFrequency { daily, weekly, interval }

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

  @HiveField(7)
  int frequencyIndex;

  @HiveField(8)
  List<int> weekDays;

  @HiveField(9)
  int intervalDays;

  @HiveField(10)
  DateTime startDate;

  HabitFrequency get frequency => HabitFrequency.values[frequencyIndex];

  Habit({
    required this.id,
    required this.name,
    this.icon = '✅',
    this.monthlyTarget = 30,
    this.unit = 'раз',
    this.isBoolean = false,
    DateTime? createdAt,
    this.frequencyIndex = 0,
    List<int>? weekDays,
    this.intervalDays = 2,
    DateTime? startDate,
  })  : createdAt = createdAt ?? DateTime.now(),
        weekDays = weekDays ?? const [],
        startDate = startDate ?? DateTime.now();

  bool isScheduledForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);

    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return weekDays.contains(date.weekday);
      case HabitFrequency.interval:
        if (normalizedDate.isBefore(normalizedStart)) return false;
        final daysDiff = normalizedDate.difference(normalizedStart).inDays;
        return daysDiff % intervalDays == 0;
    }
  }
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
