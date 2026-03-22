import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:flutter/services.dart';

/// Controller for an active workout session.
///
/// Manages the list of exercises for [workoutDayId], tracks which sets have
/// been completed, handles the rest timer, and logs sets to the database.
/// A [WorkoutSet] record is created for every call to [logSet].
///
/// The controller creates a [Workout] row in [onInit] and disposes the
/// [_timer] and [pageController] in [onClose].
class ActiveWorkoutController extends GetxController {
  /// The shared database instance, resolved via GetX dependency injection.
  final AppDatabase db = Get.find<AppDatabase>();

  /// The workout day being performed.
  final int workoutDayId;

  /// Creates an [ActiveWorkoutController] for the given [workoutDayId].
  ActiveWorkoutController(this.workoutDayId);

  /// Exercises (with volume/equipment) for this workout day, in program order.
  var exercisesWithVolume = <ExerciseWithVolume>[].obs;

  /// Whether the initial setup query is still running.
  var isLoading = true.obs;

  /// The index of the exercise card currently visible in the page view.
  var currentPageIndex = 0.obs;

  /// The database ID of the [Workout] row created for this session.
  int? currentWorkoutId;

  /// Remaining rest-timer seconds. `0` means the timer is idle.
  var remainingRestTime = 0.obs;

  Timer? _timer;

  /// Historical sets from the most recent previous session, keyed by
  /// exercise ID. Used to pre-fill weight/reps inputs.
  var lastWorkoutSets = <int, List<WorkoutSet>>{}.obs;

  /// Keys of the form `"exerciseId-equipmentId-setNum"` for every set that
  /// has been logged during this session.
  var completedSets = <String>{}.obs;

  /// Maps each exercise ID to the equipment ID the user has selected.
  var selectedEquipments = <int, int>{}.obs;

  /// Extra sets the user has added beyond the program-prescribed count,
  /// keyed by "$exerciseIndex-$equipmentId".
  var extraSetsCount = <String, int>{}.obs;

  /// Sets logged during this session, keyed by exercise ID.
  ///
  /// The inner [List] is mutated in place; call `.refresh()` on the map
  /// after mutations so that [Obx] listeners are notified.
  var sessionLoggedSets = <int, List<WorkoutSetsCompanion>>{}.obs;

  /// Page controller for the horizontal exercise swipe view.
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _setupWorkout();
  }

  /// Creates the [Workout] DB row, loads exercises with equipment, and
  /// pre-fetches historical sets for each exercise.
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
        d.leftOuterJoin(
          db.exerciseMuscleGroup,
          db.exerciseMuscleGroup.exerciseId.equalsExp(
                db.programExercise.exerciseId,
              ) &
              db.exerciseMuscleGroup.focus.equals('primary'),
        ),
        d.leftOuterJoin(
          db.muscleGroups,
          db.muscleGroups.id.equalsExp(db.exerciseMuscleGroup.muscleGroupId),
        ),
      ])..where(db.programExercise.workoutDayId.equals(workoutDayId));

      query.orderBy([
        d.OrderingTerm(expression: db.programExercise.orderInProgram),
      ]);

      final rows = await query.get();
      final List<ExerciseWithVolume> items = rows.map((row) {
        final muscleGroupRow = row.readTableOrNull(db.muscleGroups);
        return ExerciseWithVolume(
          exercise: row.readTable(db.exercises),
          volume: row.readTable(db.programExercise),
          equipment: row.readTable(db.equipments),
          primaryMuscleGroup: muscleGroupRow?.name,
        );
      }).toList();
      for (var i = 0; i < items.length; i++) {
        selectedEquipments[i] = items[i].equipment.id;
      }

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

  /// Increments the extra-set count for the exercise at [exerciseIndex] with [equipmentId].
  void addExtraSet(int exerciseIndex, int equipmentId) {
    final key = '$exerciseIndex-$equipmentId';
    extraSetsCount[key] = (extraSetsCount[key] ?? 0) + 1;
  }

  /// Decrements the extra-set count for the exercise at [exerciseIndex] with [equipmentId], flooring at zero.
  void removeExtraSet(int exerciseIndex, int equipmentId) {
    final key = '$exerciseIndex-$equipmentId';
    if ((extraSetsCount[key] ?? 0) > 0) {
      extraSetsCount[key] = extraSetsCount[key]! - 1;
    }
  }

  /// Returns the total number of sets for the exercise at [exerciseIndex] with [equipmentId],
  /// combining the program-prescribed [plannedSets] with any extra sets added.
  int getTotalSetsForExercise(
    int exerciseIndex,
    int plannedSets,
    int equipmentId,
  ) {
    final key = '$exerciseIndex-$equipmentId';
    return plannedSets + (extraSetsCount[key] ?? 0);
  }

  /// Returns the last [WorkoutSetsCompanion] logged for the exercise at
  /// [exerciseIndex] with [equipmentId] in this session, or `null` if none.
  WorkoutSetsCompanion? getLastLoggedSet(int exerciseIndex, int equipmentId) {
    final list = sessionLoggedSets[exerciseIndex];
    if (list == null || list.isEmpty) return null;
    for (var i = list.length - 1; i >= 0; i--) {
      if (list[i].equipmentId.value == equipmentId) return list[i];
    }
    return null;
  }

  /// Starts a countdown timer for [seconds] and plays an alert when it ends.
  ///
  /// Any previously running timer is cancelled first.
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

  /// Plays the system alert sound and triggers haptic feedback.
  Future<void> _playTimerEndSound() async {
    await SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
  }

  /// Cancels the rest timer and resets [remainingRestTime] to zero.
  void skipRestTimer() {
    remainingRestTime.value = 0;
    _timer?.cancel();
  }

  /// Inserts a completed set into the database and marks it as done locally.
  ///
  /// - [exerciseId]: the exercise being logged.
  /// - [equipmentId]: the equipment variant used.
  /// - [reps]: the number of repetitions performed.
  /// - [weight]: the weight used in kg.
  /// - [setNum]: the 1-based index of this set within the exercise.
  /// - [restSeconds]: if provided, the rest timer is started immediately.
  ///
  /// Does nothing if [currentWorkoutId] is `null` (setup not complete).
  Future<void> logSet({
    required int exerciseIndex,
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

    if (!sessionLoggedSets.containsKey(exerciseIndex)) {
      sessionLoggedSets[exerciseIndex] = [];
    }
    sessionLoggedSets[exerciseIndex]!.add(entry);
    sessionLoggedSets.refresh();

    completedSets.add("$exerciseIndex-$equipmentId-$setNum");

    if (restSeconds != null) {
      startRestTimer(restSeconds);
    }
  }

  /// Returns whether the set [setNum] for the exercise at [exerciseIndex]
  /// using [equipmentId] has been completed in this session.
  bool isSetCompleted(int exerciseIndex, int equipmentId, int setNum) =>
      completedSets.contains("$exerciseIndex-$equipmentId-$setNum");

  /// Marks a previously logged set as incomplete in the database and removes
  /// it from the local completed-sets tracking.
  ///
  /// Does nothing if [currentWorkoutId] is `null`.
  Future<void> unlogSet({
    required int exerciseIndex,
    required int exerciseId,
    required int equipmentId,
    required int setNum,
  }) async {
    if (currentWorkoutId == null) return;
    await (db.update(db.workoutSets)..where(
          (tbl) =>
              tbl.workoutId.equals(currentWorkoutId!) &
              tbl.exerciseId.equals(exerciseId) &
              tbl.equipmentId.equals(equipmentId) &
              tbl.setNumber.equals(setNum),
        ))
        .write(const WorkoutSetsCompanion(isCompleted: d.Value(false)));
    completedSets.remove("$exerciseIndex-$equipmentId-$setNum");
    final list = sessionLoggedSets[exerciseIndex];
    if (list != null) {
      list.removeWhere((s) => s.setNumber.value == setNum);
      sessionLoggedSets.refresh();
    }
  }

  /// Returns the historical [WorkoutSet] for [exerciseId] / [setNum] /
  /// [equipmentId] from the most recent past session, or `null` if not found.
  WorkoutSet? getPastSetData(int exerciseId, int setNum, int equipmentId) {
    final sets = lastWorkoutSets[exerciseId];
    if (sets == null) return null;
    return sets.firstWhereOrNull(
      (s) => s.setNumber == setNum && s.equipmentId == equipmentId,
    );
  }

  /// Replaces the exercise at the position of [oldExerciseId] with
  /// [newExercise] using [newEquipmentId].
  ///
  /// Historical sets for [newExercise] are loaded for reference display, and
  /// any completed-set keys referencing [oldExerciseId] are cleared.
  Future<void> swapExercise({
    required int exerciseIndex,
    required Exercise newExercise,
    required int newEquipmentId,
  }) async {
    try {
      if (exerciseIndex < 0 || exerciseIndex >= exercisesWithVolume.length) {
        return;
      }
      final equipmentList = await db.getEquipmentForExercise(newExercise.id);
      final newEquip = equipmentList.firstWhere(
        (e) => e.id == newEquipmentId,
        orElse: () => equipmentList.isNotEmpty
            ? equipmentList.first
            : Equipment(
                id: newEquipmentId,
                name: "Default",
                iconName: "fitness_center",
              ),
      );

      final originalItem = exercisesWithVolume[exerciseIndex];
      exercisesWithVolume[exerciseIndex] = ExerciseWithVolume(
        exercise: newExercise,
        volume: originalItem.volume,
        equipment: newEquip,
      );

      selectedEquipments[exerciseIndex] = newEquipmentId;

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

      completedSets.removeWhere((key) => key.startsWith("$exerciseIndex-"));
      exercisesWithVolume.refresh();
    } catch (e) {
      Get.snackbar("Swap Error", "Could not swap exercise: $e");
    }
  }

  /// Updates the note for [exerciseId] in the in-memory [exercisesWithVolume]
  /// list so the comment icon reflects the saved note immediately.
  void updateExerciseNoteInMemory(int exerciseId, String? note) {
    for (var i = 0; i < exercisesWithVolume.length; i++) {
      final item = exercisesWithVolume[i];
      if (item.exercise.id == exerciseId) {
        exercisesWithVolume[i] = ExerciseWithVolume(
          exercise: item.exercise.copyWith(note: d.Value(note)),
          volume: item.volume,
          equipment: item.equipment,
          primaryMuscleGroup: item.primaryMuscleGroup,
        );
      }
    }
    exercisesWithVolume.refresh();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
