import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:flutter/services.dart';

class ActiveWorkoutController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final int workoutDayId;

  var exercisesWithVolume = <ExerciseWithVolume>[].obs;
  var isLoading = true.obs;
  var currentPageIndex = 0.obs;
  int? currentWorkoutId;

  var remainingRestTime = 0.obs;
  Timer? _timer;

  var lastWorkoutSets = <int, List<WorkoutSet>>{}.obs;
  var completedSets = <String>{}.obs;
  var selectedEquipments = <int, int>{}.obs;

  var extraSetsCount = <int, int>{}.obs;
  var sessionLoggedSets = <int, List<WorkoutSetsCompanion>>{}.obs;

  final PageController pageController = PageController();

  ActiveWorkoutController(this.workoutDayId);

  @override
  void onInit() {
    super.onInit();
    _setupWorkout();
  }

  Future<void> _setupWorkout() async {
    try {
      currentWorkoutId = await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              workoutDayId: workoutDayId,
              date: d.Value(DateTime.now()),
            ),
          );

      final query = db.select(db.programExercise).join([
        d.innerJoin(
          db.exercises,
          db.exercises.id.equalsExp(db.programExercise.exerciseId),
        ),
        d.innerJoin(
          db.equipments,
          db.equipments.id.equalsExp(db.programExercise.equipmentId),
        ),
      ])..where(db.programExercise.workoutDayId.equals(workoutDayId));

      query.orderBy([
        d.OrderingTerm(expression: db.programExercise.orderInProgram),
      ]);

      final rows = await query.get();

      final List<ExerciseWithVolume> items = rows.map((row) {
        final ex = row.readTable(db.exercises);
        final eq = row.readTable(db.equipments);
        selectedEquipments[ex.id] = eq.id;
        return ExerciseWithVolume(
          exercise: ex,
          volume: row.readTable(db.programExercise),
          equipment: eq,
        );
      }).toList();

      for (var item in items) {
        final sets =
            await (db.select(db.workoutSets)
                  ..where((tbl) => tbl.exerciseId.equals(item.exercise.id))
                  ..orderBy([
                    (u) => d.OrderingTerm(
                      expression: u.id,
                      mode: d.OrderingMode.desc,
                    ),
                  ]))
                .get();
        if (sets.isNotEmpty) lastWorkoutSets[item.exercise.id] = sets;
      }

      exercisesWithVolume.assignAll(items);
    } catch (e) {
      Get.snackbar("Error", "Failed to load workout: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void addExtraSet(int exerciseId) {
    extraSetsCount[exerciseId] = (extraSetsCount[exerciseId] ?? 0) + 1;
  }

  void removeExtraSet(int exerciseId) {
    if ((extraSetsCount[exerciseId] ?? 0) > 0) {
      extraSetsCount[exerciseId] = extraSetsCount[exerciseId]! - 1;
    }
  }

  int getTotalSetsForExercise(int exerciseId, int plannedSets) {
    return plannedSets + (extraSetsCount[exerciseId] ?? 0);
  }

  WorkoutSetsCompanion? getLastLoggedSet(int exerciseId) {
    final list = sessionLoggedSets[exerciseId];
    if (list == null || list.isEmpty) return null;
    return list.last;
  }

  void startRestTimer(int seconds) {
    if (seconds <= 0) return;
    _timer?.cancel();
    remainingRestTime.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingRestTime.value > 0) {
        remainingRestTime.value--;
      } else {
        _playTimerEndSound();
        timer.cancel();
      }
    });
  }

  Future<void> _playTimerEndSound() async {
    await SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
  }

  void skipRestTimer() {
    remainingRestTime.value = 0;
    _timer?.cancel();
  }

  Future<void> logSet({
    required int exerciseId,
    required int equipmentId,
    required int reps,
    required double weight,
    required int setNum,
    int? restSeconds,
  }) async {
    if (currentWorkoutId == null) return;

    final entry = WorkoutSetsCompanion.insert(
      workoutId: currentWorkoutId!,
      exerciseId: exerciseId,
      equipmentId: equipmentId,
      reps: reps,
      weight: weight,
      setNumber: setNum,
      isCompleted: const d.Value(true),
    );

    await db.into(db.workoutSets).insert(entry);

    if (!sessionLoggedSets.containsKey(exerciseId)) {
      sessionLoggedSets[exerciseId] = [];
    }
    sessionLoggedSets[exerciseId]!.add(entry);

    completedSets.add("$exerciseId-$equipmentId-$setNum");

    if (restSeconds != null) {
      startRestTimer(restSeconds);
    }
  }

  bool isSetCompleted(int exerciseId, int equipmentId, int setNum) =>
      completedSets.contains("$exerciseId-$equipmentId-$setNum");

  Future<void> unlogSet({
    required int exerciseId,
    required int equipmentId,
    required int setNum,
  }) async {
    if (currentWorkoutId == null) return;
    // Mark the set as incomplete instead of deleting it
    await (db.update(db.workoutSets)..where(
          (tbl) =>
              tbl.workoutId.equals(currentWorkoutId!) &
              tbl.exerciseId.equals(exerciseId) &
              tbl.equipmentId.equals(equipmentId) &
              tbl.setNumber.equals(setNum),
        ))
        .write(const WorkoutSetsCompanion(isCompleted: d.Value(false)));
    completedSets.remove("$exerciseId-$equipmentId-$setNum");
    final list = sessionLoggedSets[exerciseId];
    if (list != null) {
      list.removeWhere((s) => s.setNumber.value == setNum);
      sessionLoggedSets.refresh();
    }
  }

  WorkoutSet? getPastSetData(int exerciseId, int setNum, int equipmentId) {
    final sets = lastWorkoutSets[exerciseId];
    if (sets == null) return null;
    return sets.firstWhereOrNull(
      (s) => s.setNumber == setNum && s.equipmentId == equipmentId,
    );
  }

  Future<void> swapExercise({
    required int oldExerciseId,
    required Exercise newExercise,
    required int newEquipmentId,
  }) async {
    try {
      final index = exercisesWithVolume.indexWhere(
        (item) => item.exercise.id == oldExerciseId,
      );
      if (index != -1) {
        final equipmentList = await db.getEquipmentForExercise(newExercise.id);
        final newEquip = equipmentList.firstWhere(
          (e) => e.id == newEquipmentId,
          orElse: () => equipmentList.isNotEmpty
              ? equipmentList.first
              : Equipment(
                  id: newEquipmentId,
                  name: "Default",
                  icon_name: "fitness_center",
                ),
        );

        final originalItem = exercisesWithVolume[index];
        final swappedItem = ExerciseWithVolume(
          exercise: newExercise,
          volume: originalItem.volume,
          equipment: newEquip,
        );

        selectedEquipments[newExercise.id] = newEquipmentId;
        exercisesWithVolume[index] = swappedItem;

        final sets =
            await (db.select(db.workoutSets)
                  ..where((tbl) => tbl.exerciseId.equals(newExercise.id))
                  ..orderBy([
                    (u) => d.OrderingTerm(
                      expression: u.id,
                      mode: d.OrderingMode.desc,
                    ),
                  ]))
                .get();
        if (sets.isNotEmpty) lastWorkoutSets[newExercise.id] = sets;

        completedSets.removeWhere((key) => key.startsWith("$oldExerciseId-"));
        exercisesWithVolume.refresh();
      }
    } catch (e) {
      Get.snackbar("Swap Error", "Could not swap exercise: $e");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
