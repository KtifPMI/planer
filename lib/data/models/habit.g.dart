// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      monthlyTarget: fields[3] as double,
      unit: fields[4] as String,
      isBoolean: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      frequencyIndex: fields[7] as int? ?? 0,
      weekDays: (fields[8] as List?)?.cast<int>() ?? const [],
      intervalDays: fields[9] as int? ?? 2,
      startDate: fields[10] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.monthlyTarget)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.isBoolean)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.frequencyIndex)
      ..writeByte(8)
      ..write(obj.weekDays)
      ..writeByte(9)
      ..write(obj.intervalDays)
      ..writeByte(10)
      ..write(obj.startDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitEntryAdapter extends TypeAdapter<HabitEntry> {
  @override
  final int typeId = 1;

  @override
  HabitEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitEntry(
      habitId: fields[0] as String,
      date: fields[1] as DateTime,
      value: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HabitEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.habitId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
