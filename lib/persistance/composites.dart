import 'dart:convert';
import 'package:reptrack/persistance/database.dart';

/// A unified view of a [ProgramStrengthExercise], [ProgramCardioExercise], or
/// [ProgramHybridExercise], exposing a common set of accessors so the rest
/// of the app does not need to branch on exercise type in most places.
class ProgramExerciseVolume {
  final ProgramStrengthExercise? _strength;
  final ProgramCardioExercise? _cardio;
  final ProgramHybridExercise? _hybrid;

  ProgramExerciseVolume.strength(ProgramStrengthExercise data)
    : _strength = data,
      _cardio = null,
      _hybrid = null;

  ProgramExerciseVolume.cardio(ProgramCardioExercise data)
    : _strength = null,
      _cardio = data,
      _hybrid = null;

  ProgramExerciseVolume.hybrid(ProgramHybridExercise data)
    : _strength = null,
      _cardio = null,
      _hybrid = data;

  ProgramStrengthExercise? get strength => _strength;
  ProgramCardioExercise? get cardio => _cardio;
  ProgramHybridExercise? get hybrid => _hybrid;

  bool get isCardio => _cardio != null;
  bool get isHybrid => _hybrid != null;

  String get id => _strength?.id ?? _cardio?.id ?? _hybrid!.id;
  String get workoutDayId =>
      _strength?.workoutDayId ?? _cardio?.workoutDayId ?? _hybrid!.workoutDayId;
  String get exerciseId =>
      _strength?.exerciseId ?? _cardio?.exerciseId ?? _hybrid!.exerciseId;
  int get orderInProgram =>
      _strength?.orderInProgram ??
      _cardio?.orderInProgram ??
      _hybrid!.orderInProgram;

  // Strength and hybrid shared fields (safe defaults for cardio)
  String? get equipmentId => _strength?.equipmentId ?? _hybrid?.equipmentId;
  int? get restTimer => _strength?.restTimer ?? _hybrid?.restTimer;
  double get weight => _strength?.weight ?? _hybrid?.weight ?? 0.0;

  // Strength-only fields
  String get setsReps => _strength?.setsReps ?? '[12]';

  // Cardio-only fields (safe default for strength/hybrid)
  int? get seconds => _cardio?.seconds;
  double? get distancePlanned => _cardio?.distancePlanned;
  String get distancePlannedUnit => _cardio?.distancePlannedUnit ?? 'km';

  // Hybrid-only fields
  String get setsDistances => _hybrid?.setsDistances ?? '[100.0]';
  String get distanceUnit => _hybrid?.distanceUnit ?? 'm';

  /// Parses the JSON setsReps field into a list of rep counts per set.
  List<int> get setsRepsList {
    try {
      final decoded = jsonDecode(setsReps) as List<dynamic>;
      return decoded.map((e) => (e as num).toInt()).toList();
    } catch (_) {
      return [12];
    }
  }

  /// Parses the JSON setsDistances field into a list of planned distances per set.
  List<double> get setsDistancesList {
    try {
      final decoded = jsonDecode(setsDistances) as List<dynamic>;
      return decoded.map((e) => (e as num).toDouble()).toList();
    } catch (_) {
      return [100.0];
    }
  }

  /// Human-readable sets/reps summary, e.g. "3 × 12" or "Set 1: 12, Set 2: 10".
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

  /// Human-readable planned distances summary, e.g. "3 × 100 m" or "100 m, 200 m, 400 m".
  String get setsDistancesLabel {
    final list = setsDistancesList;
    final unit = distanceUnit;
    if (list.isEmpty) return '';
    final allEqual = list.every((d) => d == list.first);
    String fmt(double d) =>
        d == d.truncateToDouble() ? d.toInt().toString() : d.toStringAsFixed(1);
    if (allEqual) return '${list.length} × ${fmt(list.first)} $unit';
    return list.map((d) => '${fmt(d)} $unit').join(', ');
  }

  /// Human-readable planned duration, e.g. "1h 30m" or "45m", or null if not set.
  String? get durationLabel {
    final s = seconds;
    if (s == null || s == 0) return null;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

/// A joined view of an exercise, its program-level volume settings, and the
/// equipment variant selected for that entry.
/// [equipment] is null for cardio exercises.
class ExerciseWithVolume {
  final Exercise exercise;
  final ProgramExerciseVolume volume;
  final Equipment? equipment;

  /// The name of the primary muscle group from [ExerciseMuscleGroup], or null.
  final String? primaryMuscleGroup;

  ExerciseWithVolume({
    required this.exercise,
    required this.volume,
    this.equipment,
    this.primaryMuscleGroup,
  });

  bool get isCardio => volume.isCardio;
  bool get isHybrid => volume.isHybrid;
}

/// A workout day paired with its ordered list of exercises.
class WorkoutDayWithExercises {
  final WorkoutDay workoutDay;
  final List<ExerciseWithVolume> exercises;

  WorkoutDayWithExercises({required this.workoutDay, required this.exercises});
}
