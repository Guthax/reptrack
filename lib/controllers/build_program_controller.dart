import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';

class BuildProgramController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final int programId;

  BuildProgramController(this.programId);

  RxList<WorkoutDayWithExercises> daysWithExercises =
      <WorkoutDayWithExercises>[].obs;

  @override
  void onInit() {
    super.onInit();
    daysWithExercises.bindStream(db.watchWorkoutDaysWithExercises(programId));
  }

  Future<List<Exercise>> getAvailableExercises() => db.getAllExercises();

  Future<void> addDay(String name) async {
    if (name.trim().isNotEmpty) {
      await db.addWorkoutDay(programId, name.trim());
    }
  }

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

  Future<void> removeExerciseFromDay(int dayId, int exerciseId) async {
    await db.deleteExerciseFromWorkoutDay(dayId, exerciseId);
  }

  Future<void> reorderExercisesInDay(List<ExerciseWithVolume> exercises) async {
    await db.reorderExercisesInDay(exercises.map((e) => e.volume.id).toList());
  }

  Future<void> reorderDays(List<WorkoutDayWithExercises> days) async {
    await db.reorderDays(days.map((d) => d.workoutDay.id).toList());
  }

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
