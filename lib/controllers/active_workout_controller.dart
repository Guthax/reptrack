import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class ActiveWorkoutController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final int workoutDayId;

  var exercisesWithVolume = <ExerciseWithVolume>[].obs;
  var isLoading = true.obs;
  var currentPageIndex = 0.obs;
  int? currentWorkoutId;

  // Timer & Audio state
  var remainingRestTime = 0.obs;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  var lastWorkoutSets = <int, List<WorkoutSet>>{}.obs;
  var completedSets = <String>{}.obs;
  var selectedEquipments = <int, int>{}.obs;

  final PageController pageController = PageController();

  ActiveWorkoutController(this.workoutDayId);

  @override
  void onInit() {
    super.onInit();
    _setupWorkout();
    // Pre-cache the sound to avoid delay on first play
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
        d.innerJoin(db.equipments, db.equipments.id.equalsExp(db.programExercise.equipmentId)),
      ])..where(db.programExercise.workoutDayId.equals(workoutDayId));

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
        final sets = await (db.select(db.workoutSets)
              ..where((tbl) => tbl.exerciseId.equals(item.exercise.id))
              ..orderBy([(u) => d.OrderingTerm(expression: u.id, mode: d.OrderingMode.desc)]))
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
  // This triggers the native 'click/beep' sound on Android 
  // and the system 'alert' sound on Linux/Desktop.
  await SystemSound.play(SystemSoundType.alert);
  
  // Optional: Add a haptic bump for mobile users
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

    await db.into(db.workoutSets).insert(
          WorkoutSetsCompanion.insert(
            workoutId: currentWorkoutId!,
            exerciseId: exerciseId,
            equipmentId: equipmentId,
            reps: reps,
            weight: weight,
            setNumber: setNum,
            isCompleted: const d.Value(true),
          ),
        );
    completedSets.add("$exerciseId-$setNum");

    if (restSeconds != null) {
      startRestTimer(restSeconds);
    }
  }

  bool isSetCompleted(int exerciseId, int setNum) => completedSets.contains("$exerciseId-$setNum");

  WorkoutSet? getPastSetData(int exerciseId, int setNum, int equipmentId) {
    final sets = lastWorkoutSets[exerciseId];
    if (sets == null) return null;
    return sets.firstWhereOrNull((s) => s.setNumber == setNum && s.equipmentId == equipmentId);
  }

  Future<void> swapExercise({
    required int oldExerciseId,
    required Exercise newExercise,
    required int newEquipmentId,
  }) async {
    try {
      final index = exercisesWithVolume.indexWhere((item) => item.exercise.id == oldExerciseId);
      if (index != -1) {
        final equipmentList = await db.getEquipmentForExercise(newExercise.id);
        final newEquip = equipmentList.firstWhere(
          (e) => e.id == newEquipmentId,
          orElse: () => equipmentList.isNotEmpty 
            ? equipmentList.first 
            : Equipment(id: newEquipmentId, name: "Default", icon_name: "fitness_center"),
        );

        final originalItem = exercisesWithVolume[index];
        final swappedItem = ExerciseWithVolume(
          exercise: newExercise, 
          volume: originalItem.volume, 
          equipment: newEquip
        );

        selectedEquipments[newExercise.id] = newEquipmentId;
        exercisesWithVolume[index] = swappedItem;

        final sets = await (db.select(db.workoutSets)
              ..where((tbl) => tbl.exerciseId.equals(newExercise.id))
              ..orderBy([(u) => d.OrderingTerm(expression: u.id, mode: d.OrderingMode.desc)]))
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
    _audioPlayer.dispose();
    pageController.dispose();
    super.onClose();
  }
}