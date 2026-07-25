import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 7)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<ExerciseLog> exercises;

  @HiveField(4)
  Duration? duration;

  @HiveField(5)
  String? templateId;

  WorkoutSession({
    required this.id,
    required this.date,
    this.name,
    this.exercises = const [],
    this.duration,
    this.templateId,
  });
}

@HiveType(typeId: 8)
class ExerciseLog extends HiveObject {
  @HiveField(0)
  String exerciseName;

  @HiveField(1)
  List<SetLog> sets;

  ExerciseLog({
    required this.exerciseName,
    this.sets = const [],
  });

  double get maxWeight =>
      sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  int get totalVolume =>
      sets.fold(0, (sum, s) => sum + (s.weight * s.reps).toInt());
}

@HiveType(typeId: 9)
class SetLog extends HiveObject {
  @HiveField(0)
  int setNumber;

  @HiveField(1)
  double weight;

  @HiveField(2)
  int reps;

  @HiveField(3)
  bool completed;

  SetLog({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.completed = false,
  });
}

@HiveType(typeId: 10)
class ExerciseTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String muscleGroup;

  @HiveField(3)
  int defaultSets;

  @HiveField(4)
  int defaultReps;

  ExerciseTemplate({
    required this.id,
    required this.name,
    this.muscleGroup = '',
    this.defaultSets = 3,
    this.defaultReps = 10,
  });
}

@HiveType(typeId: 11)
class WorkoutTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> exerciseIds;

  @HiveField(3)
  int dayOfWeek;

  @HiveField(4)
  List<TemplateExercise> exercises;

  WorkoutTemplate({
    required this.id,
    required this.name,
    this.exerciseIds = const [],
    this.dayOfWeek = 0,
    this.exercises = const [],
  });
}

@HiveType(typeId: 16)
class TemplateExercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int targetSets;

  @HiveField(2)
  int targetReps;

  @HiveField(3)
  double targetWeight;

  TemplateExercise({
    required this.name,
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetWeight = 0,
  });
}
