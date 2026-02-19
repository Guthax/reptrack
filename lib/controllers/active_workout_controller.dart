import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';

class ActiveWorkoutController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final int workoutDayId;

  var exercisesWithVolume = <ExerciseWithVolume>[].obs;
  var isLoading = true.obs;
  var currentPageIndex = 0.obs;
  int? currentWorkoutId;

  // Key: exerciseId, Value: List of all sets from the last time this exercise was done
  var lastWorkoutSets = <int, List<WorkoutSet>>{}.obs;
  var completedSets = <String>{}.obs;

  final PageController pageController = PageController();

  ActiveWorkoutController(this.workoutDayId);

  @override
  void onInit() {
    super.onInit();
    _setupWorkout();
  }

  Future<void> _setupWorkout() async {
    try {
      currentWorkoutId = await db.into(db.workouts).insert(
        WorkoutsCompanion.insert(
          workoutDayId: workoutDayId,
          date: d.Value(DateTime.now()),
        ),
      );

      final query = db.select(db.programExercise).join([
        d.innerJoin(db.exercises, db.exercises.id.equalsExp(db.programExercise.exerciseId)),
      ])..where(db.programExercise.workoutDayId.equals(workoutDayId));

      final rows = await query.get();
      final items = rows.map((row) => ExerciseWithVolume(
        exercise: row.readTable(db.exercises),
        volume: row.readTable(db.programExercise),
      )).toList();

      // Fetch ALL sets from the most recent workout for each exercise
      for (var item in items) {
        final lastWorkout = await (db.select(db.workoutSets)
              ..where((tbl) => tbl.exerciseId.equals(item.exercise.id))
              ..orderBy([(u) => d.OrderingTerm(expression: u.workoutId, mode: d.OrderingMode.desc)])
              ..limit(1))
            .getSingleOrNull();

        if (lastWorkout != null) {
          final allSetsFromThatWorkout = await (db.select(db.workoutSets)
                ..where((tbl) => tbl.exerciseId.equals(item.exercise.id))
                ..where((tbl) => tbl.workoutId.equals(lastWorkout.workoutId)))
              .get();
          lastWorkoutSets[item.exercise.id] = allSetsFromThatWorkout;
        }
      }

      exercisesWithVolume.value = items;
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to get specific set data (e.g. Set 2 from last time)
  WorkoutSet? getPastSetData(int exerciseId, int setNum) {
    final sets = lastWorkoutSets[exerciseId];
    if (sets == null) return null;
    return sets.firstWhereOrNull((s) => s.setNumber == setNum);
  }

  Future<void> logSet({required int exerciseId, required int reps, required double weight, required int setNum}) async {
    if (currentWorkoutId == null) return;
    await db.into(db.workoutSets).insert(
      WorkoutSetsCompanion.insert(
        workoutId: currentWorkoutId!,
        exerciseId: exerciseId,
        reps: reps,
        weight: weight,
        setNumber: setNum,
        isCompleted: const d.Value(true),
      ),
    );
    completedSets.add("$exerciseId-$setNum");
  }

  bool isSetCompleted(int exerciseId, int setNum) => completedSets.contains("$exerciseId-$setNum");

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}