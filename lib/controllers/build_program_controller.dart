import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/utils/error_handler.dart';

/// Controller for the Build Program screen.
///
/// Manages the reactive list of workout days and their associated exercises
/// for a given [programId]. All database mutations are performed through
/// [AppDatabase], which is resolved from the GetX service locator.
/// The list is kept up-to-date via a Drift stream bound in [onInit].
class BuildProgramController extends GetxController {
  /// The shared database instance, resolved via GetX dependency injection.
  final AppDatabase db = Get.find<AppDatabase>();

  /// The ID of the program being edited.
  final String programId;

  /// Reactive program name, kept in sync with the database.
  late final RxString programName;

  /// Creates a [BuildProgramController] for the program identified by [programId].
  BuildProgramController(this.programId, String initialName)
    : programName = initialName.obs;

  /// Reactive list of workout days with their exercises for [programId].
  ///
  /// Automatically updated via a Drift stream bound in [onInit].
  RxList<WorkoutDayWithExercises> daysWithExercises =
      <WorkoutDayWithExercises>[].obs;

  @override
  void onInit() {
    super.onInit();
    daysWithExercises.bindStream(db.watchWorkoutDaysWithExercises(programId));
  }

  /// Returns all exercises available in the database for the exercise picker.
  Future<List<Exercise>> getAvailableExercises() async {
    try {
      return await db.getAllExercises();
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
      return [];
    }
  }

  /// Renames the current program to [name].
  Future<void> renameProgram(String name) async {
    if (name.trim().isEmpty) return;
    try {
      await db.renameProgram(programId, name.trim());
      programName.value = name.trim();
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Renames the workout day identified by [dayId] to [name].
  Future<void> renameDay(String dayId, String name) async {
    if (name.trim().isEmpty) return;
    try {
      await db.renameWorkoutDay(dayId, name.trim());
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Adds a new workout day named [name] to the current program.
  ///
  /// The name is trimmed before saving; empty names are silently ignored.
  Future<void> addDay(String name) async {
    if (name.trim().isEmpty) return;
    try {
      await db.addWorkoutDay(programId, name.trim());
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Permanently deletes the workout day with [dayId] and all its exercises.
  Future<void> deleteDay(String dayId) async {
    try {
      await db.deleteWorkoutDay(dayId);
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Adds [exercise] to the workout day identified by [dayId].
  ///
  /// Routes to cardio, hybrid, or strength storage based on [exercise.exerciseTypeId].
  /// Cardio exercises ('2') use [durationSeconds]. Hybrid exercises ('3') use
  /// [setsDistances], [distanceUnit], [equipmentId], and [restTimer]. Strength
  /// exercises use [setsReps], [equipmentId], and [restTimer].
  Future<void> addExerciseToDay(
    String dayId,
    Exercise exercise,
    String? equipmentId,
    List<int> setsReps,
    int? restTimer, {
    int? durationSeconds,
    double? distancePlannedCardio,
    String distancePlannedCardioUnit = 'km',
    List<double> setsDistances = const [100.0],
    String distanceUnit = 'm',
  }) async {
    try {
      final isHybrid = exercise.exerciseTypeId == '3';
      final isCardio = exercise.exerciseTypeId == '2';

      if (isCardio) {
        await db.addCardioExerciseToDay(
          workoutDayId: dayId,
          exerciseId: exercise.id,
          seconds: durationSeconds,
          distancePlanned: distancePlannedCardio,
          distancePlannedUnit: distancePlannedCardioUnit,
        );
      } else if (isHybrid) {
        await db.addHybridExerciseToDay(
          workoutDayId: dayId,
          exerciseId: exercise.id,
          equipmentId: equipmentId,
          setsDistances: setsDistances,
          distanceUnit: distanceUnit,
          restTimer: restTimer,
        );
      } else {
        await db.addStrengthExerciseToDay(
          workoutDayId: dayId,
          exerciseId: exercise.id,
          equipmentId: equipmentId,
          setsReps: setsReps,
          restTimer: restTimer,
          weight: 0.0,
        );
      }
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Removes the exercise entry identified by [volume] from its workout day.
  Future<void> removeExerciseFromDay(ProgramExerciseVolume volume) async {
    try {
      if (volume.isCardio) {
        await db.deleteProgramCardioExercise(volume.id);
      } else if (volume.isHybrid) {
        await db.deleteProgramHybridExercise(volume.id);
      } else {
        await db.deleteProgramStrengthExercise(volume.id);
      }
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Persists the display order of [exercises] within their workout day.
  ///
  /// Order is determined by list index (index 0 = first).
  Future<void> reorderExercisesInDay(List<ExerciseWithVolume> exercises) async {
    try {
      await db.reorderExercisesInDay(exercises.map((e) => e.volume).toList());
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Persists the display order of workout [days] within the program.
  ///
  /// Order is determined by list index (index 0 = first).
  Future<void> reorderDays(List<WorkoutDayWithExercises> days) async {
    try {
      await db.reorderDays(days.map((d) => d.workoutDay.id).toList());
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Updates the exercise entry identified by [volume] with new details.
  ///
  /// For cardio: updates [exerciseId] and planned [durationSeconds].
  /// For hybrid: updates [exerciseId], [equipmentId], [setsDistances],
  /// [distanceUnit], and [restTimer].
  /// For strength: updates [exerciseId], [equipmentId], [setsReps], and [restTimer].
  Future<void> updateExerciseInDay(
    ProgramExerciseVolume volume,
    Exercise exercise,
    String? equipmentId,
    List<int> setsReps,
    int? restTimer, {
    int? durationSeconds,
    double? distancePlannedCardio,
    String distancePlannedCardioUnit = 'km',
    List<double> setsDistances = const [100.0],
    String distanceUnit = 'm',
  }) async {
    try {
      if (volume.isCardio) {
        await db.updateProgramCardioExercise(
          ProgramCardioExercisesCompanion(
            exerciseId: drift.Value(exercise.id),
            seconds: drift.Value(durationSeconds),
            distancePlanned: drift.Value(distancePlannedCardio),
            distancePlannedUnit: drift.Value(distancePlannedCardioUnit),
          ),
          volume.id,
        );
      } else if (volume.isHybrid) {
        await db.updateProgramHybridExercise(
          ProgramHybridExercisesCompanion(
            exerciseId: drift.Value(exercise.id),
            equipmentId: drift.Value(equipmentId),
            setsDistances: drift.Value(jsonEncode(setsDistances)),
            distanceUnit: drift.Value(distanceUnit),
            restTimer: drift.Value(restTimer),
          ),
          volume.id,
        );
      } else {
        await db.updateProgramStrengthExercise(
          ProgramStrengthExercisesCompanion(
            exerciseId: drift.Value(exercise.id),
            equipmentId: drift.Value(equipmentId),
            setsReps: drift.Value(jsonEncode(setsReps)),
            restTimer: drift.Value(restTimer),
          ),
          volume.id,
        );
      }
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }
}
