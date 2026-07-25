// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner.dart';

class WeeklyPlanAdapter extends TypeAdapter<WeeklyPlan> {
  @override
  final int typeId = 12;

  @override
  WeeklyPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyPlan(
      id: fields[0] as String,
      weekStart: fields[1] as DateTime,
      goals: (fields[2] as List).cast<WeekGoal>(),
      days: (fields[3] as Map).cast<String, DayPlan>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyPlan obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.weekStart)
      ..writeByte(2)
      ..write(obj.goals)
      ..writeByte(3)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeekGoalAdapter extends TypeAdapter<WeekGoal> {
  @override
  final int typeId = 13;

  @override
  WeekGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeekGoal(
      title: fields[0] as String,
      completed: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WeekGoal obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeekGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayPlanAdapter extends TypeAdapter<DayPlan> {
  @override
  final int typeId = 14;

  @override
  DayPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayPlan(
      tasks: (fields[0] as List).cast<PlannerTask>(),
      note: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DayPlan obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.tasks)
      ..writeByte(1)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlannerTaskAdapter extends TypeAdapter<PlannerTask> {
  @override
  final int typeId = 15;

  @override
  PlannerTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannerTask(
      title: fields[0] as String,
      completed: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlannerTask obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannerTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
