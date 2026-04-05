import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Controller for an active workout session.
///
/// Manages the list of exercises for [workoutDayId], tracks which sets have
/// been completed, handles the rest timer, and logs sets to the database.
/// A [Workout] record is created in [onInit] and the [pageController] and
/// [_timer] are disposed in [onClose].
double _unitToMeters(double value, String unit) {
  switch (unit) {
    case 'km':
      return value * 1000;
    case 'mi':
      return value * 1609.344;
    case 'ft':
      return value * 0.3048;
    default:
      return value;
  }
}

class ActiveWorkoutController extends GetxController {
  /// The shared database instance, resolved via GetX dependency injection.
  final AppDatabase db = Get.find<AppDatabase>();

  /// The workout day being performed.
  final String workoutDayId;

  /// Creates an [ActiveWorkoutController] for the given [workoutDayId].
  ActiveWorkoutController(this.workoutDayId);

  /// Exercises (with volume/equipment) for this workout day, in program order.
  var exercisesWithVolume = <ExerciseWithVolume>[].obs;

  /// Whether the initial setup query is still running.
  var isLoading = true.obs;

  /// The index of the exercise card currently visible in the page view.
  var currentPageIndex = 0.obs;

  /// The database ID of the [Workout] row created for this session.
  String? currentWorkoutId;

  /// Remaining rest-timer seconds. `0` means the timer is idle.
  var remainingRestTime = 0.obs;

  Timer? _timer;

  /// Historical sets from the most recent previous session, keyed by
  /// exercise ID. Used to pre-fill weight/reps inputs for strength exercises.
  final lastWorkoutSets = RxMap<String, List<WorkoutStrengthSet>>({});

  /// Most recent cardio set for each cardio exercise, keyed by exercise ID.
  final lastCardioSets = RxMap<String, WorkoutCardioSet>({});

  /// Most recent hybrid set for each hybrid exercise, keyed by exercise ID.
  final lastHybridSets = RxMap<String, WorkoutHybridSet>({});

  /// Keys of the form `"exerciseId-equipmentId-setNum"` for every set that
  /// has been logged during this session.
  var completedSets = <String>{}.obs;

  /// Maps each exercise index to the equipment ID the user has selected.
  /// Null for cardio exercises.
  var selectedEquipments = <int, String?>{}.obs;

  /// Extra sets the user has added beyond the program-prescribed count,
  /// keyed by "$exerciseIndex-$equipmentId".
  var extraSetsCount = <String, int>{}.obs;

  /// Sets logged during this session, keyed by exercise index.
  ///
  /// The inner [List] is mutated in place; call `.refresh()` on the map
  /// after mutations so that [Obx] listeners are notified.
  final sessionLoggedSets = RxMap<int, List<WorkoutStrengthSetsCompanion>>({});

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
      final workoutUuid = _uuid.v4();
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion(
              id: d.Value(workoutUuid),
              workoutDayId: d.Value(workoutDayId),
              date: d.Value(DateTime.now()),
            ),
          );
      currentWorkoutId = workoutUuid;

      final strengthQuery = db.select(db.programStrengthExercises).join([
        d.innerJoin(
          db.exercises,
          db.exercises.id.equalsExp(db.programStrengthExercises.exerciseId),
        ),
        d.leftOuterJoin(
          db.equipments,
          db.equipments.id.equalsExp(db.programStrengthExercises.equipmentId),
        ),
        d.leftOuterJoin(
          db.exerciseMuscleGroup,
          db.exerciseMuscleGroup.exerciseId.equalsExp(
                db.programStrengthExercises.exerciseId,
              ) &
              db.exerciseMuscleGroup.focus.equals('primary'),
        ),
        d.leftOuterJoin(
          db.muscleGroups,
          db.muscleGroups.id.equalsExp(db.exerciseMuscleGroup.muscleGroupId),
        ),
      ])..where(db.programStrengthExercises.workoutDayId.equals(workoutDayId));

      final cardioQuery = db.select(db.programCardioExercises).join([
        d.innerJoin(
          db.exercises,
          db.exercises.id.equalsExp(db.programCardioExercises.exerciseId),
        ),
        d.leftOuterJoin(
          db.exerciseMuscleGroup,
          db.exerciseMuscleGroup.exerciseId.equalsExp(
                db.programCardioExercises.exerciseId,
              ) &
              db.exerciseMuscleGroup.focus.equals('primary'),
        ),
        d.leftOuterJoin(
          db.muscleGroups,
          db.muscleGroups.id.equalsExp(db.exerciseMuscleGroup.muscleGroupId),
        ),
      ])..where(db.programCardioExercises.workoutDayId.equals(workoutDayId));

      final hybridQuery = db.select(db.programHybridExercises).join([
        d.innerJoin(
          db.exercises,
          db.exercises.id.equalsExp(db.programHybridExercises.exerciseId),
        ),
        d.leftOuterJoin(
          db.equipments,
          db.equipments.id.equalsExp(db.programHybridExercises.equipmentId),
        ),
        d.leftOuterJoin(
          db.exerciseMuscleGroup,
          db.exerciseMuscleGroup.exerciseId.equalsExp(
                db.programHybridExercises.exerciseId,
              ) &
              db.exerciseMuscleGroup.focus.equals('primary'),
        ),
        d.leftOuterJoin(
          db.muscleGroups,
          db.muscleGroups.id.equalsExp(db.exerciseMuscleGroup.muscleGroupId),
        ),
      ])..where(db.programHybridExercises.workoutDayId.equals(workoutDayId));

      final strengthRows = await strengthQuery.get();
      final cardioRows = await cardioQuery.get();
      final hybridRows = await hybridQuery.get();

      final List<ExerciseWithVolume> items =
          [
            ...strengthRows.map(
              (row) => ExerciseWithVolume(
                exercise: row.readTable(db.exercises),
                volume: ProgramExerciseVolume.strength(
                  row.readTable(db.programStrengthExercises),
                ),
                equipment: row.readTableOrNull(db.equipments),
                primaryMuscleGroup: row.readTableOrNull(db.muscleGroups)?.name,
              ),
            ),
            ...cardioRows.map(
              (row) => ExerciseWithVolume(
                exercise: row.readTable(db.exercises),
                volume: ProgramExerciseVolume.cardio(
                  row.readTable(db.programCardioExercises),
                ),
                equipment: null,
                primaryMuscleGroup: row.readTableOrNull(db.muscleGroups)?.name,
              ),
            ),
            ...hybridRows.map(
              (row) => ExerciseWithVolume(
                exercise: row.readTable(db.exercises),
                volume: ProgramExerciseVolume.hybrid(
                  row.readTable(db.programHybridExercises),
                ),
                equipment: row.readTableOrNull(db.equipments),
                primaryMuscleGroup: row.readTableOrNull(db.muscleGroups)?.name,
              ),
            ),
          ]..sort(
            (a, b) =>
                a.volume.orderInProgram.compareTo(b.volume.orderInProgram),
          );

      for (var i = 0; i < items.length; i++) {
        final equipId = items[i].equipment?.id;
        if (equipId != null) selectedEquipments[i] = equipId;
      }

      for (var item in items) {
        if (item.isCardio) {
          final last = await db.getLastCardioSetForExercise(item.exercise.id);
          if (last != null) lastCardioSets[item.exercise.id] = last;
        } else if (item.isHybrid) {
          final last = await db.getLastHybridSetForExercise(item.exercise.id);
          if (last != null) lastHybridSets[item.exercise.id] = last;
        } else {
          final sets = await db.getStrengthSetsForExercise(item.exercise.id);
          if (sets.isNotEmpty) lastWorkoutSets[item.exercise.id] = sets;
        }
      }

      exercisesWithVolume.assignAll(items);
    } catch (e) {
      Get.snackbar("Error", "Failed to load workout: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Increments the extra-set count for the exercise at [exerciseIndex] with [equipmentId].
  void addExtraSet(int exerciseIndex, String equipmentId) {
    final key = '$exerciseIndex-$equipmentId';
    extraSetsCount[key] = (extraSetsCount[key] ?? 0) + 1;
  }

  /// Decrements the extra-set count for the exercise at [exerciseIndex] with [equipmentId], flooring at zero.
  void removeExtraSet(int exerciseIndex, String equipmentId) {
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
    String equipmentId,
  ) {
    final key = '$exerciseIndex-$equipmentId';
    return plannedSets + (extraSetsCount[key] ?? 0);
  }

  /// Returns the last [WorkoutStrengthSetsCompanion] logged for the exercise at
  /// [exerciseIndex] with [equipmentId] in this session, or `null` if none.
  WorkoutStrengthSetsCompanion? getLastLoggedSet(
    int exerciseIndex,
    String? equipmentId,
  ) {
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

  /// Inserts a completed strength set into the database and marks it as done locally.
  ///
  /// Does nothing if [currentWorkoutId] is `null` (setup not complete).
  Future<void> logSet({
    required int exerciseIndex,
    required String exerciseId,
    required String equipmentId,
    required int reps,
    required double weight,
    required int setNum,
    int? restSeconds,
  }) async {
    if (currentWorkoutId == null) return;

    final entry = WorkoutStrengthSetsCompanion.insert(
      workoutId: currentWorkoutId!,
      exerciseId: exerciseId,
      equipmentId: d.Value(equipmentId),
      reps: reps,
      weight: weight,
      setNumber: setNum,
      isCompleted: const d.Value(true),
    );

    await db.into(db.workoutStrengthSets).insert(entry);

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

  /// Logs a cardio exercise into [workoutCardioSets] with duration and optional distance in meters.
  ///
  /// Does nothing if [currentWorkoutId] is `null`.
  Future<void> logCardio({
    required int exerciseIndex,
    required String exerciseId,
    required int durationSeconds,
    double? distanceMeters,
    String distanceUnit = 'km',
  }) async {
    if (currentWorkoutId == null) return;

    await db
        .into(db.workoutCardioSets)
        .insert(
          WorkoutCardioSetsCompanion.insert(
            workoutId: currentWorkoutId!,
            exerciseId: exerciseId,
            durationSeconds: durationSeconds,
            distanceMeters: d.Value(distanceMeters),
            distanceUnit: d.Value(distanceUnit),
          ),
        );

    completedSets.add("$exerciseIndex-cardio-1");
  }

  /// Logs a hybrid set into [workoutHybridSets] with weight and distance.
  ///
  /// Does nothing if [currentWorkoutId] is `null`.
  Future<void> logHybridSet({
    required int exerciseIndex,
    required String exerciseId,
    required String equipmentId,
    required double weight,
    required double distance,
    required String distanceUnit,
    required int setNum,
    int? restSeconds,
  }) async {
    if (currentWorkoutId == null) return;

    final distanceMeters = _unitToMeters(distance, distanceUnit);
    await db
        .into(db.workoutHybridSets)
        .insert(
          WorkoutHybridSetsCompanion.insert(
            workoutId: currentWorkoutId!,
            exerciseId: exerciseId,
            equipmentId: d.Value(equipmentId),
            setNumber: setNum,
            weight: weight,
            distance: distance,
            distanceUnit: d.Value(distanceUnit),
            distanceMeters: d.Value(distanceMeters),
            isCompleted: const d.Value(true),
          ),
        );

    completedSets.add("$exerciseIndex-$equipmentId-$setNum");

    if (restSeconds != null) {
      startRestTimer(restSeconds);
    }
  }

  /// Returns whether the cardio exercise at [exerciseIndex] has been logged.
  bool isCardioCompleted(int exerciseIndex) =>
      completedSets.contains("$exerciseIndex-cardio-1");

  /// Unmarks a logged cardio exercise by marking the row incomplete in the DB.
  Future<void> unlogCardio({
    required int exerciseIndex,
    required String exerciseId,
  }) async {
    if (currentWorkoutId == null) return;
    await (db.update(db.workoutCardioSets)..where(
          (tbl) =>
              tbl.workoutId.equals(currentWorkoutId!) &
              tbl.exerciseId.equals(exerciseId),
        ))
        .write(const WorkoutCardioSetsCompanion(isCompleted: d.Value(false)));
    completedSets.remove("$exerciseIndex-cardio-1");
  }

  /// Returns whether the set [setNum] for the exercise at [exerciseIndex]
  /// using [equipmentId] has been completed in this session.
  bool isSetCompleted(int exerciseIndex, String equipmentId, int setNum) =>
      completedSets.contains("$exerciseIndex-$equipmentId-$setNum");

  /// Marks a previously logged strength set as incomplete in the database.
  ///
  /// Does nothing if [currentWorkoutId] is `null`.
  Future<void> unlogSet({
    required int exerciseIndex,
    required String exerciseId,
    required String equipmentId,
    required int setNum,
  }) async {
    if (currentWorkoutId == null) return;
    await (db.update(db.workoutStrengthSets)..where(
          (tbl) =>
              tbl.workoutId.equals(currentWorkoutId!) &
              tbl.exerciseId.equals(exerciseId) &
              tbl.equipmentId.equals(equipmentId) &
              tbl.setNumber.equals(setNum),
        ))
        .write(const WorkoutStrengthSetsCompanion(isCompleted: d.Value(false)));
    completedSets.remove("$exerciseIndex-$equipmentId-$setNum");
    final list = sessionLoggedSets[exerciseIndex];
    if (list != null) {
      list.removeWhere((s) => s.setNumber.value == setNum);
      sessionLoggedSets.refresh();
    }
  }

  /// Marks a previously logged hybrid set as incomplete in the database.
  ///
  /// Does nothing if [currentWorkoutId] is `null`.
  Future<void> unlogHybridSet({
    required int exerciseIndex,
    required String exerciseId,
    required String equipmentId,
    required int setNum,
  }) async {
    if (currentWorkoutId == null) return;
    await (db.update(db.workoutHybridSets)..where(
          (tbl) =>
              tbl.workoutId.equals(currentWorkoutId!) &
              tbl.exerciseId.equals(exerciseId) &
              tbl.equipmentId.equals(equipmentId) &
              tbl.setNumber.equals(setNum),
        ))
        .write(const WorkoutHybridSetsCompanion(isCompleted: d.Value(false)));
    completedSets.remove("$exerciseIndex-$equipmentId-$setNum");
  }

  /// Returns the historical [WorkoutStrengthSet] for [exerciseId] / [setNum] /
  /// [equipmentId] from the most recent past session, or `null` if not found.
  WorkoutStrengthSet? getPastSetData(
    String exerciseId,
    int setNum,
    String? equipmentId,
  ) {
    final sets = lastWorkoutSets[exerciseId];
    if (sets == null) return null;
    return sets.firstWhereOrNull(
      (s) => s.setNumber == setNum && s.equipmentId == equipmentId,
    );
  }

  /// Returns the historical [WorkoutHybridSet] for [exerciseId] / [setNum] /
  /// [equipmentId] from the most recent past session, or `null` if not found.
  WorkoutHybridSet? getPastHybridSetData(
    String exerciseId,
    int setNum,
    String? equipmentId,
  ) {
    final last = lastHybridSets[exerciseId];
    if (last == null) return null;
    if (last.setNumber == setNum && last.equipmentId == equipmentId) {
      return last;
    }
    return null;
  }

  /// Replaces the exercise at the position of [oldExerciseId] with
  /// [newExercise] using [newEquipmentId].
  Future<void> swapExercise({
    required int exerciseIndex,
    required Exercise newExercise,
    required String newEquipmentId,
  }) async {
    try {
      if (exerciseIndex < 0 || exerciseIndex >= exercisesWithVolume.length) {
        return;
      }
      final isNewCardio = newExercise.exerciseTypeId == '2';
      final isNewHybrid = newExercise.exerciseTypeId == '3';

      Equipment? newEquip;
      if (!isNewCardio) {
        final equipmentList = await db.getEquipmentForExercise(newExercise.id);
        newEquip =
            equipmentList.firstWhereOrNull((e) => e.id == newEquipmentId) ??
            (equipmentList.isNotEmpty ? equipmentList.first : null);
        if (newEquip != null) selectedEquipments[exerciseIndex] = newEquip.id;
      }

      final primaryMuscleGroup = await db.getPrimaryMuscleGroupForExercise(
        newExercise.id,
      );
      final originalItem = exercisesWithVolume[exerciseIndex];

      ProgramExerciseVolume newVolume;
      if (isNewCardio) {
        final lastCardio = await db.getLastCardioSetForExercise(newExercise.id);
        if (lastCardio != null) lastCardioSets[newExercise.id] = lastCardio;
        newVolume = ProgramExerciseVolume.cardio(
          ProgramCardioExercise(
            id: originalItem.volume.id,
            workoutDayId: workoutDayId,
            exerciseId: newExercise.id,
            orderInProgram: originalItem.volume.orderInProgram,
            seconds: originalItem.volume.seconds,
            distancePlanned: null,
            distancePlannedUnit: 'km',
          ),
        );
      } else if (isNewHybrid) {
        final lastHybrid = await db.getLastHybridSetForExercise(newExercise.id);
        if (lastHybrid != null) lastHybridSets[newExercise.id] = lastHybrid;
        newVolume = ProgramExerciseVolume.hybrid(
          ProgramHybridExercise(
            id: originalItem.volume.id,
            workoutDayId: workoutDayId,
            exerciseId: newExercise.id,
            equipmentId: newEquip?.id,
            orderInProgram: originalItem.volume.orderInProgram,
            setsDistances: jsonEncode([100.0, 100.0, 100.0]),
            distanceUnit: lastHybrid?.distanceUnit ?? 'm',
            restTimer: originalItem.volume.restTimer,
            weight: lastHybrid?.weight ?? 0.0,
          ),
        );
      } else {
        final sets = await db.getStrengthSetsForExercise(newExercise.id);
        if (sets.isNotEmpty) lastWorkoutSets[newExercise.id] = sets;
        newVolume = ProgramExerciseVolume.strength(
          ProgramStrengthExercise(
            id: originalItem.volume.id,
            workoutDayId: workoutDayId,
            exerciseId: newExercise.id,
            equipmentId: newEquip?.id,
            orderInProgram: originalItem.volume.orderInProgram,
            setsReps: originalItem.volume.setsReps,
            restTimer: originalItem.volume.restTimer,
            weight: originalItem.volume.weight,
          ),
        );
      }

      exercisesWithVolume[exerciseIndex] = ExerciseWithVolume(
        exercise: newExercise,
        volume: newVolume,
        equipment: newEquip,
        primaryMuscleGroup: primaryMuscleGroup,
      );

      completedSets.removeWhere((key) => key.startsWith("$exerciseIndex-"));
      exercisesWithVolume.refresh();
    } catch (e) {
      Get.snackbar("Swap Error", "Could not swap exercise: $e");
    }
  }

  /// Replaces the exercise at [exerciseIndex] in-memory with [exercise].
  void updateExerciseInMemory(int exerciseIndex, Exercise exercise) {
    if (exerciseIndex < 0 || exerciseIndex >= exercisesWithVolume.length) {
      return;
    }
    final item = exercisesWithVolume[exerciseIndex];
    exercisesWithVolume[exerciseIndex] = ExerciseWithVolume(
      exercise: exercise,
      volume: item.volume,
      equipment: item.equipment,
      primaryMuscleGroup: item.primaryMuscleGroup,
    );
    exercisesWithVolume.refresh();
  }

  /// Updates the note for [exerciseId] in-memory so the comment icon reflects
  /// the saved note immediately.
  void updateExerciseNoteInMemory(String exerciseId, String? note) {
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

  /// Adds [exercise] to the end of the current workout session.
  ///
  /// Pre-populates volume from the most recent logged session and navigates
  /// to the new card after adding.
  Future<void> addExerciseDuringWorkout({
    required Exercise exercise,
    String? equipmentId,
  }) async {
    final isCardio = exercise.exerciseTypeId == '2';
    final isHybrid = exercise.exerciseTypeId == '3';

    Equipment? equipment;
    if (!isCardio && !isHybrid && equipmentId != null) {
      equipment = await db.getEquipmentById(equipmentId);
    } else if (isHybrid && equipmentId != null) {
      equipment = await db.getEquipmentById(equipmentId);
    }

    final primaryMuscleGroup = await db.getPrimaryMuscleGroupForExercise(
      exercise.id,
    );

    final newIndex = exercisesWithVolume.length;
    ProgramExerciseVolume volume;

    if (isCardio) {
      final last = await db.getLastCardioSetForExercise(exercise.id);
      if (last != null) lastCardioSets[exercise.id] = last;
      volume = ProgramExerciseVolume.cardio(
        ProgramCardioExercise(
          id: _uuid.v4(),
          workoutDayId: workoutDayId,
          exerciseId: exercise.id,
          orderInProgram: newIndex,
          seconds: null,
          distancePlanned: null,
          distancePlannedUnit: 'km',
        ),
      );
    } else if (isHybrid) {
      final last = await db.getLastHybridSetForExercise(exercise.id);
      if (last != null) lastHybridSets[exercise.id] = last;
      final lastWeight = last?.weight ?? 0.0;
      volume = ProgramExerciseVolume.hybrid(
        ProgramHybridExercise(
          id: _uuid.v4(),
          workoutDayId: workoutDayId,
          exerciseId: exercise.id,
          equipmentId: equipmentId,
          orderInProgram: newIndex,
          setsDistances: jsonEncode([100.0, 100.0, 100.0]),
          distanceUnit: last?.distanceUnit ?? 'm',
          restTimer: null,
          weight: lastWeight,
        ),
      );
    } else {
      List<int> setsReps = [12, 12, 12];
      double weight = 0.0;
      final sets = await db.getStrengthSetsForExercise(exercise.id);
      if (sets.isNotEmpty) {
        final lastWorkoutId = sets.first.workoutId;
        final lastSession =
            sets.where((s) => s.workoutId == lastWorkoutId).toList()
              ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
        setsReps = lastSession.map((s) => s.reps).toList();
        weight = lastSession.first.weight;
        lastWorkoutSets[exercise.id] = sets;
      }
      volume = ProgramExerciseVolume.strength(
        ProgramStrengthExercise(
          id: _uuid.v4(),
          workoutDayId: workoutDayId,
          exerciseId: exercise.id,
          equipmentId: equipmentId,
          orderInProgram: newIndex,
          setsReps: jsonEncode(setsReps),
          restTimer: null,
          weight: weight,
        ),
      );
    }

    if (equipment != null) selectedEquipments[newIndex] = equipment.id;

    exercisesWithVolume.add(
      ExerciseWithVolume(
        exercise: exercise,
        volume: volume,
        equipment: equipment,
        primaryMuscleGroup: primaryMuscleGroup,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
