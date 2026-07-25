import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';

class WorkoutRepository {
  final _sessions = StorageService.workoutsBox;
  final _templates = StorageService.exerciseTemplatesBox;
  final _workoutTemplates = StorageService.workoutTemplatesBox;
  static const _uuid = Uuid();

  static String generateId() => _uuid.v4();

  // --- Sessions ---
  List<WorkoutSession> getAllSessions() =>
      _sessions.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  List<WorkoutSession> getSessionsForMonth(int year, int month) {
    return _sessions.values
        .where((s) => s.date.year == year && s.date.month == month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  WorkoutSession? getSession(String id) => _sessions.get(id);

  WorkoutSession? getLatestSession() {
    if (_sessions.isEmpty) return null;
    return getAllSessions().first;
  }

  WorkoutSession? getSessionForDate(DateTime date) {
    for (final s in _sessions.values) {
      if (s.date.year == date.year && s.date.month == date.month && s.date.day == date.day) {
        return s;
      }
    }
    return null;
  }

  Future<void> addSession(WorkoutSession session) =>
      _sessions.put(session.id, session);

  Future<void> updateSession(WorkoutSession session) =>
      _sessions.put(session.id, session);

  Future<void> deleteSession(String id) => _sessions.delete(id);

  // --- Workout Templates ---
  List<WorkoutTemplate> getAllWorkoutTemplates() =>
      _workoutTemplates.values.toList();

  WorkoutTemplate? getWorkoutTemplate(String id) => _workoutTemplates.get(id);

  List<WorkoutTemplate> getTemplatesForDay(int dayOfWeek) {
    return _workoutTemplates.values
        .where((t) => t.dayOfWeek == dayOfWeek)
        .toList();
  }

  Future<void> addWorkoutTemplate(WorkoutTemplate t) =>
      _workoutTemplates.put(t.id, t);

  Future<void> updateWorkoutTemplate(WorkoutTemplate t) =>
      _workoutTemplates.put(t.id, t);

  Future<void> deleteWorkoutTemplate(String id) =>
      _workoutTemplates.delete(id);

  // --- Exercise Templates ---
  List<ExerciseTemplate> getAllTemplates() => _templates.values.toList();

  Future<void> addTemplate(ExerciseTemplate t) => _templates.put(t.id, t);

  Future<void> deleteTemplate(String id) => _templates.delete(id);

  // --- Exercise History ---
  List<ExerciseLog> getExerciseHistory(String exerciseName) {
    final history = <ExerciseLog>[];
    for (final session in _sessions.values) {
      for (final ex in session.exercises) {
        if (ex.exerciseName == exerciseName) {
          history.add(ex);
        }
      }
    }
    return history;
  }

  List<double> getWeightProgression(String exerciseName) {
    return getExerciseHistory(exerciseName).map((e) => e.maxWeight).toList();
  }

  // --- Stats ---
  int getSessionsThisMonth(int year, int month) =>
      getSessionsForMonth(year, month).length;

  int get totalSessions => _sessions.length;
}
