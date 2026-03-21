import 'dart:convert';
import 'package:reptrack/persistance/database.dart';

extension ProgramExerciseDataX on ProgramExerciseData {
  /// Parses the JSON setsReps field into a list of rep counts per set.
  List<int> get setsRepsList {
    try {
      final decoded = jsonDecode(setsReps) as List<dynamic>;
      return decoded.map((e) => (e as num).toInt()).toList();
    } catch (_) {
      return [12];
    }
  }

  /// Human-readable sets/reps summary, e.g. "3 × 12" or "12 / 10 / 8".
  String get setsRepsLabel {
    final list = setsRepsList;
    if (list.isEmpty) return '';
    final allEqual = list.every((r) => r == list.first);
    if (allEqual) return '${list.length} × ${list.first}';
    return list
        .asMap()
        .entries
        .map((e) => 'Set ${e.key + 1}: ${e.value}')
        .join(', ');
  }
}

/// A joined view of an exercise, its program-level volume settings, and the
/// equipment variant selected for that entry.
class ExerciseWithVolume {
  final Exercise exercise;
  final ProgramExerciseData volume;
  final Equipment equipment;

  /// The name of the primary muscle group from [ExerciseMuscleGroup], or null.
  final String? primaryMuscleGroup;

  ExerciseWithVolume({
    required this.exercise,
    required this.volume,
    required this.equipment,
    this.primaryMuscleGroup,
  });
}

/// A workout day paired with its ordered list of exercises.
class WorkoutDayWithExercises {
  final WorkoutDay workoutDay;
  final List<ExerciseWithVolume> exercises;

  WorkoutDayWithExercises({required this.workoutDay, required this.exercises});
}
