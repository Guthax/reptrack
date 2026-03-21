import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';

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
  final int programId;

  /// Creates a [BuildProgramController] for the program identified by [programId].
  BuildProgramController(this.programId);

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
  Future<List<Exercise>> getAvailableExercises() => db.getAllExercises();

  /// Adds a new workout day named [name] to the current program.
  ///
  /// The name is trimmed before saving; empty names are silently ignored.
  Future<void> addDay(String name) async {
    if (name.trim().isNotEmpty) {
      await db.addWorkoutDay(programId, name.trim());
    }
  }

  /// Adds [exercise] to the workout day identified by [dayId].
  ///
  /// - [equipmentId]: the equipment variant to use for this exercise.
  /// - [setsReps]: rep count per set, e.g. `[12, 10, 8]`.
  /// - [restTimer]: optional rest duration in seconds between sets.
  Future<void> addExerciseToDay(
    int dayId,
    Exercise exercise,
    int equipmentId,
    List<int> setsReps,
    int? restTimer,
  ) async {
    await db.addExerciseToDay(
      workoutDayId: dayId,
      exerciseId: exercise.id,
      equipmentId: equipmentId,
      setsReps: setsReps,
      restTimer: restTimer,
      weight: 0.0,
    );
  }

  /// Removes the exercise identified by [exerciseId] from workout day [dayId].
  Future<void> removeExerciseFromDay(int dayId, int exerciseId) async {
    await db.deleteExerciseFromWorkoutDay(dayId, exerciseId);
  }

  /// Persists the display order of [exercises] within their workout day.
  ///
  /// Order is determined by list index (index 0 = first).
  Future<void> reorderExercisesInDay(List<ExerciseWithVolume> exercises) async {
    await db.reorderExercisesInDay(exercises.map((e) => e.volume.id).toList());
  }

  /// Persists the display order of workout [days] within the program.
  ///
  /// Order is determined by list index (index 0 = first).
  Future<void> reorderDays(List<WorkoutDayWithExercises> days) async {
    await db.reorderDays(days.map((d) => d.workoutDay.id).toList());
  }

  /// Updates the exercise entry identified by [volumeId] with new details.
  ///
  /// - [exercise]: the (possibly changed) exercise definition.
  /// - [equipmentId]: the new equipment variant.
  /// - [setsReps]: new rep scheme per set.
  /// - [restTimer]: optional rest duration in seconds.
  Future<void> updateExerciseInDay(
    int volumeId,
    Exercise exercise,
    int equipmentId,
    List<int> setsReps,
    int? restTimer,
  ) async {
    await db.updateProgramExercise(
      ProgramExerciseCompanion(
        exerciseId: drift.Value(exercise.id),
        equipmentId: drift.Value(equipmentId),
        setsReps: drift.Value(jsonEncode(setsReps)),
        restTimer: drift.Value(restTimer),
      ),
      volumeId,
    );
  }
}
