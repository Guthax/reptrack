import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:flutter/services.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/error_handler.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Time and weight entered or measured for one timed set.
///
/// [seconds] is always greater than zero; an entry of zero seconds is removed
/// instead of stored. [weightKg] is copied from the exercise's current weight
/// when the set is logged.
class TimedSetEntry {
  /// Entered or measured duration in whole seconds.
  final int seconds;

  /// Weight in kg used for the set, or null when none was used.
  final double? weightKg;

  /// Creates an entry of [seconds] with an optional [weightKg].
  const TimedSetEntry({required this.seconds, this.weightKg});

  /// Returns a copy with the given fields replaced.
  TimedSetEntry copyWith({int? seconds, double? weightKg}) => TimedSetEntry(
    seconds: seconds ?? this.seconds,
    weightKg: weightKg ?? this.weightKg,
  );
}

/// Where a timed set is in its time-then-log flow.
enum TimedSetPhase {
  /// No time entered yet and the stopwatch is not running for the set.
  idle,

  /// The stopwatch is running for the set.
  running,

  /// A time is entered or measured and the set can be logged.
  ready,
}

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

  /// Returns the current time; injectable so the stopwatch can be tested.
  final DateTime Function() _clock;

  /// Creates an [ActiveWorkoutController] for the given [workoutDayId].
  ///
  /// [clock] defaults to [DateTime.now] and is only overridden in tests.
  ActiveWorkoutController(this.workoutDayId, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

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

  /// All past hybrid sets for each hybrid exercise, keyed by exercise ID,
  /// ordered newest first (mirrors [lastWorkoutSets] for strength).
  final lastHybridSets = RxMap<String, List<WorkoutHybridSet>>({});

  /// All past completed timed sets for each timed exercise, keyed by exercise
  /// ID, ordered newest first.
  final lastTimedSets = RxMap<String, List<WorkoutTimedSet>>({});

  /// Key (`"$exerciseIndex-$equipmentId-$setNum"`) of the set row whose
  /// stopwatch is running, or null when no stopwatch runs.
  final runningStopwatchKey = RxnString();

  /// Whole seconds elapsed on the running stopwatch, refreshed every second.
  final stopwatchElapsedSeconds = 0.obs;

  /// Entered, measured and logged timed set entries, keyed like
  /// [runningStopwatchKey]. Entries are kept after logging so logged sets can
  /// show their values and an unlogged set keeps its time.
  final timedEntries = RxMap<String, TimedSetEntry>({});

  /// Seconds already counted for the running set before the current run,
  /// so that resuming continues from the stopped time.
  int _stopwatchOffsetSeconds = 0;

  /// Set number the user selected as active, per timed exercise index.
  final _activeTimedOverride = RxMap<int, int>({});

  /// Current weight in kg per timed exercise index, carried over to the
  /// following sets; null when no weight is used.
  final timedWeightKg = RxMap<int, double?>({});

  DateTime? _stopwatchStartedAt;

  Timer? _stopwatchTicker;

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

  /// Hybrid sets logged during this session, keyed by
  /// `"$exerciseIndex-$equipmentId-$setNum"`.
  final sessionLoggedHybridSets = <String, WorkoutHybridSetsCompanion>{};

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

      final timedQuery = db.select(db.programTimedExercises).join([
        d.innerJoin(
          db.exercises,
          db.exercises.id.equalsExp(db.programTimedExercises.exerciseId),
        ),
        d.leftOuterJoin(
          db.equipments,
          db.equipments.id.equalsExp(db.programTimedExercises.equipmentId),
        ),
        d.leftOuterJoin(
          db.exerciseMuscleGroup,
          db.exerciseMuscleGroup.exerciseId.equalsExp(
                db.programTimedExercises.exerciseId,
              ) &
              db.exerciseMuscleGroup.focus.equals('primary'),
        ),
        d.leftOuterJoin(
          db.muscleGroups,
          db.muscleGroups.id.equalsExp(db.exerciseMuscleGroup.muscleGroupId),
        ),
      ])..where(db.programTimedExercises.workoutDayId.equals(workoutDayId));

      final strengthRows = await strengthQuery.get();
      final cardioRows = await cardioQuery.get();
      final hybridRows = await hybridQuery.get();
      final timedRows = await timedQuery.get();

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
            ...timedRows.map(
              (row) => ExerciseWithVolume(
                exercise: row.readTable(db.exercises),
                volume: ProgramExerciseVolume.timed(
                  row.readTable(db.programTimedExercises),
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
          final sets = await db.getHybridSetsForExercise(item.exercise.id);
          if (sets.isNotEmpty) lastHybridSets[item.exercise.id] = sets;
        } else if (item.isTimed) {
          final sets = await db.getTimedSetsForExercise(item.exercise.id);
          if (sets.isNotEmpty) lastTimedSets[item.exercise.id] = sets;
        } else {
          final sets = await db.getStrengthSetsForExercise(item.exercise.id);
          if (sets.isNotEmpty) lastWorkoutSets[item.exercise.id] = sets;
        }
      }

      for (var i = 0; i < items.length; i++) {
        if (items[i].isTimed) {
          timedWeightKg[i] = getLastTimedWeight(items[i].exercise.id);
        }
      }

      exercisesWithVolume.assignAll(items);
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
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

  /// Returns whether every set of the exercise at [exerciseIndex] with
  /// [equipmentId] has been logged, counting both the [plannedSets] and any
  /// extra sets the user added during this session.
  bool isExerciseComplete(
    int exerciseIndex,
    int plannedSets,
    String equipmentId,
  ) {
    final totalSets = getTotalSetsForExercise(
      exerciseIndex,
      plannedSets,
      equipmentId,
    );
    for (var setNum = 1; setNum <= totalSets; setNum++) {
      if (!isSetCompleted(exerciseIndex, equipmentId, setNum)) return false;
    }
    return true;
  }

  /// Returns whether the workout should move on to the next exercise after a
  /// set is logged for the exercise at [exerciseIndex] with [equipmentId].
  ///
  /// This is true only when [isExerciseComplete] holds and a next exercise
  /// exists, so it is always false for the last exercise.
  bool shouldAutoAdvance({
    required int exerciseIndex,
    required int plannedSets,
    required String equipmentId,
  }) =>
      isExerciseComplete(exerciseIndex, plannedSets, equipmentId) &&
      exerciseIndex < exercisesWithVolume.length - 1;

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

  /// Returns the strength set logged in this session for [setNum] of the
  /// exercise at [exerciseIndex] with [equipmentId], or `null` if none.
  WorkoutStrengthSetsCompanion? getLoggedSet(
    int exerciseIndex,
    String equipmentId,
    int setNum,
  ) {
    final list = sessionLoggedSets[exerciseIndex];
    if (list == null) return null;
    for (var i = list.length - 1; i >= 0; i--) {
      if (list[i].equipmentId.value == equipmentId &&
          list[i].setNumber.value == setNum) {
        return list[i];
      }
    }
    return null;
  }

  /// Returns the hybrid set logged in this session for [setNum] of the
  /// exercise at [exerciseIndex] with [equipmentId], or `null` if none.
  WorkoutHybridSetsCompanion? getLoggedHybridSet(
    int exerciseIndex,
    String equipmentId,
    int setNum,
  ) => sessionLoggedHybridSets["$exerciseIndex-$equipmentId-$setNum"];

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
    try {
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
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
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
    try {
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
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
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
    try {
      final distanceMeters = _unitToMeters(distance, distanceUnit);
      final entry = WorkoutHybridSetsCompanion.insert(
        workoutId: currentWorkoutId!,
        exerciseId: exerciseId,
        equipmentId: d.Value(equipmentId),
        setNumber: setNum,
        weight: weight,
        distance: distance,
        distanceUnit: d.Value(distanceUnit),
        distanceMeters: d.Value(distanceMeters),
        isCompleted: const d.Value(true),
      );
      await db.into(db.workoutHybridSets).insert(entry);

      final key = "$exerciseIndex-$equipmentId-$setNum";
      sessionLoggedHybridSets[key] = entry;
      completedSets.add(key);

      if (restSeconds != null) {
        startRestTimer(restSeconds);
      }
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
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
    try {
      await (db.update(db.workoutCardioSets)..where(
            (tbl) =>
                tbl.workoutId.equals(currentWorkoutId!) &
                tbl.exerciseId.equals(exerciseId),
          ))
          .write(const WorkoutCardioSetsCompanion(isCompleted: d.Value(false)));
      completedSets.remove("$exerciseIndex-cardio-1");
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
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
    try {
      await (db.update(db.workoutStrengthSets)..where(
            (tbl) =>
                tbl.workoutId.equals(currentWorkoutId!) &
                tbl.exerciseId.equals(exerciseId) &
                tbl.equipmentId.equals(equipmentId) &
                tbl.setNumber.equals(setNum),
          ))
          .write(
            const WorkoutStrengthSetsCompanion(isCompleted: d.Value(false)),
          );
      completedSets.remove("$exerciseIndex-$equipmentId-$setNum");
      final list = sessionLoggedSets[exerciseIndex];
      if (list != null) {
        list.removeWhere((s) => s.setNumber.value == setNum);
        sessionLoggedSets.refresh();
      }
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
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
    try {
      await (db.update(db.workoutHybridSets)..where(
            (tbl) =>
                tbl.workoutId.equals(currentWorkoutId!) &
                tbl.exerciseId.equals(exerciseId) &
                tbl.equipmentId.equals(equipmentId) &
                tbl.setNumber.equals(setNum),
          ))
          .write(const WorkoutHybridSetsCompanion(isCompleted: d.Value(false)));
      completedSets.remove("$exerciseIndex-$equipmentId-$setNum");
      sessionLoggedHybridSets.remove("$exerciseIndex-$equipmentId-$setNum");
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
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
    final sets = lastHybridSets[exerciseId];
    if (sets == null) return null;
    return sets.firstWhereOrNull(
      (s) => s.setNumber == setNum && s.equipmentId == equipmentId,
    );
  }

  /// Validates and logs a completed timed set into [workoutTimedSets].
  ///
  /// Rejects a [durationSeconds] below one second or a negative [weightKg]
  /// with a snackbar. Stops this row's stopwatch if it is still running,
  /// marks the set done locally and starts the rest timer when
  /// [restSeconds] is given. Returns whether the set was logged.
  Future<bool> logTimedSet({
    required int exerciseIndex,
    required String exerciseId,
    required String equipmentId,
    required int durationSeconds,
    double? weightKg,
    required int setNum,
    int? restSeconds,
  }) async {
    if (currentWorkoutId == null) return false;
    if (durationSeconds < 1) {
      AppSnackbar.error('Enter a duration');
      return false;
    }
    if (weightKg != null && weightKg < 0) {
      AppSnackbar.error("Weight can't be negative");
      return false;
    }
    final key = "$exerciseIndex-$equipmentId-$setNum";
    if (runningStopwatchKey.value == key) stopStopwatch();
    try {
      await db
          .into(db.workoutTimedSets)
          .insert(
            WorkoutTimedSetsCompanion.insert(
              workoutId: currentWorkoutId!,
              exerciseId: exerciseId,
              equipmentId: d.Value(equipmentId),
              setNumber: setNum,
              durationSeconds: durationSeconds,
              weight: d.Value(weightKg),
              isCompleted: const d.Value(true),
            ),
          );

      completedSets.add(key);
      timedEntries[key] = TimedSetEntry(
        seconds: durationSeconds,
        weightKg: weightKg,
      );
      _activeTimedOverride.remove(exerciseIndex);

      if (restSeconds != null) {
        startRestTimer(restSeconds);
      }
      return true;
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
      return false;
    }
  }

  /// Marks a previously logged timed set as incomplete in the database.
  ///
  /// Does nothing if [currentWorkoutId] is `null`.
  Future<void> unlogTimedSet({
    required int exerciseIndex,
    required String exerciseId,
    required String equipmentId,
    required int setNum,
  }) async {
    if (currentWorkoutId == null) return;
    try {
      await (db.update(db.workoutTimedSets)..where(
            (tbl) =>
                tbl.workoutId.equals(currentWorkoutId!) &
                tbl.exerciseId.equals(exerciseId) &
                tbl.equipmentId.equals(equipmentId) &
                tbl.setNumber.equals(setNum),
          ))
          .write(const WorkoutTimedSetsCompanion(isCompleted: d.Value(false)));
      completedSets.remove("$exerciseIndex-$equipmentId-$setNum");
      selectTimedSet(exerciseIndex, equipmentId, setNum);
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  /// Returns the most recent past [WorkoutTimedSet] for [exerciseId] /
  /// [setNum] / [equipmentId] that has a recorded time, or `null`.
  ///
  /// Converted sets with `durationSeconds == 0` are skipped.
  WorkoutTimedSet? getPastTimedSetData(
    String exerciseId,
    int setNum,
    String? equipmentId,
  ) {
    final sets = lastTimedSets[exerciseId];
    if (sets == null) return null;
    return sets.firstWhereOrNull(
      (s) =>
          s.setNumber == setNum &&
          s.equipmentId == equipmentId &&
          s.durationSeconds > 0,
    );
  }

  /// Loads all completed timed sets of [exerciseId] for the history dialog,
  /// newest first, including sets logged in this session.
  Future<List<WorkoutTimedSet>> loadTimedHistory(String exerciseId) async {
    try {
      return await db.getTimedSetsForExercise(exerciseId);
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
      return [];
    }
  }

  /// Returns the weight in kg of the most recent timed set of [exerciseId]
  /// that had a weight, or `null` when none did.
  double? getLastTimedWeight(String exerciseId) => lastTimedSets[exerciseId]
      ?.firstWhereOrNull((s) => s.weight != null)
      ?.weight;

  /// Returns the whole seconds counted on the running stopwatch, including
  /// the time counted before it was resumed.
  int _stopwatchElapsed() =>
      _stopwatchOffsetSeconds +
      _clock().difference(_stopwatchStartedAt!).inSeconds;

  /// Starts or resumes the stopwatch for the set identified by [key].
  ///
  /// Skips a running rest timer. A stopwatch running for another set is
  /// stopped first and its time is stored in [timedEntries]. Counting
  /// continues from the set's existing entry time, or from zero.
  void startStopwatch(String key) {
    skipRestTimer();
    if (runningStopwatchKey.value != null) stopStopwatch();
    _stopwatchOffsetSeconds = timedEntries[key]?.seconds ?? 0;
    runningStopwatchKey.value = key;
    _stopwatchStartedAt = _clock();
    stopwatchElapsedSeconds.value = _stopwatchOffsetSeconds;
    _stopwatchTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      stopwatchElapsedSeconds.value = _stopwatchElapsed();
    });
  }

  /// Stops the running stopwatch, stores its total whole seconds in the
  /// set's [timedEntries] entry (keeping any weight) and returns them.
  ///
  /// Returns 0 when no stopwatch is running; a total of 0 removes the entry.
  int stopStopwatch() {
    final key = runningStopwatchKey.value;
    if (key == null) return 0;
    final elapsed = _stopwatchElapsed();
    _clearStopwatch();
    setTimedEntrySeconds(key, elapsed);
    return elapsed;
  }

  /// Sets the time of the entry for [key]; zero or less removes the entry.
  ///
  /// An existing weight is kept.
  void setTimedEntrySeconds(String key, int seconds) {
    if (seconds <= 0) {
      timedEntries.remove(key);
      return;
    }
    final existing = timedEntries[key];
    timedEntries[key] = existing == null
        ? TimedSetEntry(seconds: seconds)
        : existing.copyWith(seconds: seconds);
  }

  /// Removes the entry for [key] so the set is idle again.
  void resetTimedEntry(String key) => timedEntries.remove(key);

  /// Returns the phase of the set identified by [key].
  TimedSetPhase timedPhase(String key) {
    if (runningStopwatchKey.value == key) return TimedSetPhase.running;
    if (timedEntries.containsKey(key) && !completedSets.contains(key)) {
      return TimedSetPhase.ready;
    }
    return TimedSetPhase.idle;
  }

  /// Returns the set number the focus panel of the timed exercise at
  /// [exerciseIndex] operates on, or null when all [totalSets] are logged.
  ///
  /// A still-unlogged set selected by the user wins; otherwise the first
  /// unlogged set in order is active.
  int? activeTimedSetNum(int exerciseIndex, String equipmentId, int totalSets) {
    bool isOpen(int setNum) =>
        !completedSets.contains("$exerciseIndex-$equipmentId-$setNum");
    final selected = _activeTimedOverride[exerciseIndex];
    if (selected != null &&
        selected >= 1 &&
        selected <= totalSets &&
        isOpen(selected)) {
      return selected;
    }
    for (var setNum = 1; setNum <= totalSets; setNum++) {
      if (isOpen(setNum)) return setNum;
    }
    return null;
  }

  /// Makes [setNum] the active set of the timed exercise at [exerciseIndex].
  ///
  /// Does nothing for a logged set. A stopwatch running for another set is
  /// stopped and keeps its time as an entry.
  void selectTimedSet(int exerciseIndex, String equipmentId, int setNum) {
    final key = "$exerciseIndex-$equipmentId-$setNum";
    if (completedSets.contains(key)) return;
    final running = runningStopwatchKey.value;
    if (running != null && running != key) stopStopwatch();
    _activeTimedOverride[exerciseIndex] = setNum;
  }

  /// Sets the current weight of the timed exercise at [exerciseIndex], or
  /// clears it when [weightKg] is null.
  void setTimedWeight(int exerciseIndex, double? weightKg) {
    timedWeightKg[exerciseIndex] = weightKg;
  }

  /// Selects [equipmentId] for the exercise at [exerciseIndex], discarding a
  /// running stopwatch because set keys depend on the equipment.
  void selectEquipment(int exerciseIndex, String equipmentId) {
    discardStopwatch();
    selectedEquipments[exerciseIndex] = equipmentId;
  }

  /// Discards a running stopwatch without reporting a result.
  void discardStopwatch() => _clearStopwatch();

  /// Cancels the stopwatch ticker and resets the stopwatch state.
  void _clearStopwatch() {
    _stopwatchTicker?.cancel();
    _stopwatchTicker = null;
    _stopwatchStartedAt = null;
    _stopwatchOffsetSeconds = 0;
    runningStopwatchKey.value = null;
    stopwatchElapsedSeconds.value = 0;
  }

  /// Returns every exercise in the library except the one with
  /// [excludeExerciseId], for the swap dialog's list. Reports errors with
  /// [AppErrorHandler.showSystemError] and returns an empty list.
  Future<List<Exercise>> getSwapCandidates(String excludeExerciseId) async {
    try {
      return (await db.getAllExercises())
          .where((e) => e.id != excludeExerciseId)
          .toList();
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
      return [];
    }
  }

  /// Replaces the exercise at [exerciseIndex] with [newExercise]. Uses
  /// [newEquipmentId] when it is one of the new exercise's compatible
  /// equipment, and otherwise the first compatible equipment (none for cardio).
  Future<void> swapExercise({
    required int exerciseIndex,
    required Exercise newExercise,
    String? newEquipmentId,
  }) async {
    try {
      if (exerciseIndex < 0 || exerciseIndex >= exercisesWithVolume.length) {
        return;
      }
      discardStopwatch();
      final isNewCardio = newExercise.exerciseTypeId == '2';
      final isNewHybrid = newExercise.exerciseTypeId == '3';
      final isNewTimed = newExercise.exerciseTypeId == '4';

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
        final hybridSets = await db.getHybridSetsForExercise(newExercise.id);
        if (hybridSets.isNotEmpty) lastHybridSets[newExercise.id] = hybridSets;
        final lastHybrid = hybridSets.isNotEmpty ? hybridSets.first : null;
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
      } else if (isNewTimed) {
        final timedSets = await db.getTimedSetsForExercise(newExercise.id);
        if (timedSets.isNotEmpty) lastTimedSets[newExercise.id] = timedSets;
        timedWeightKg[exerciseIndex] = getLastTimedWeight(newExercise.id);
        final original = originalItem.volume;
        final setCount = original.isCardio
            ? 1
            : original.isHybrid
            ? original.setsDistancesList.length
            : original.isTimed
            ? original.setsSecondsList.length
            : original.setsRepsList.length;
        newVolume = ProgramExerciseVolume.timed(
          ProgramTimedExercise(
            id: original.id,
            workoutDayId: workoutDayId,
            exerciseId: newExercise.id,
            equipmentId: newEquip?.id,
            orderInProgram: original.orderInProgram,
            setsSeconds: jsonEncode(List.filled(setCount, 0)),
            restTimer: original.restTimer,
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
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
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
  /// Uses [equipmentId] when given, and otherwise the exercise's first
  /// compatible equipment (none for cardio). Pre-populates volume from the
  /// most recent logged session and navigates to the new card after adding.
  Future<void> addExerciseDuringWorkout({
    required Exercise exercise,
    String? equipmentId,
  }) async {
    try {
      final isCardio = exercise.exerciseTypeId == '2';
      final isHybrid = exercise.exerciseTypeId == '3';
      final isTimed = exercise.exerciseTypeId == '4';

      Equipment? equipment;
      if (!isCardio) {
        equipment = equipmentId != null
            ? await db.getEquipmentById(equipmentId)
            : (await db.getEquipmentForExercise(exercise.id)).firstOrNull;
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
        final hybridSets = await db.getHybridSetsForExercise(exercise.id);
        if (hybridSets.isNotEmpty) lastHybridSets[exercise.id] = hybridSets;
        final last = hybridSets.isNotEmpty ? hybridSets.first : null;
        final lastWeight = last?.weight ?? 0.0;
        volume = ProgramExerciseVolume.hybrid(
          ProgramHybridExercise(
            id: _uuid.v4(),
            workoutDayId: workoutDayId,
            exerciseId: exercise.id,
            equipmentId: equipment?.id,
            orderInProgram: newIndex,
            setsDistances: jsonEncode([100.0, 100.0, 100.0]),
            distanceUnit: last?.distanceUnit ?? 'm',
            restTimer: null,
            weight: lastWeight,
          ),
        );
      } else if (isTimed) {
        final timedSets = await db.getTimedSetsForExercise(exercise.id);
        if (timedSets.isNotEmpty) lastTimedSets[exercise.id] = timedSets;
        timedWeightKg[newIndex] = getLastTimedWeight(exercise.id);
        volume = ProgramExerciseVolume.timed(
          ProgramTimedExercise(
            id: _uuid.v4(),
            workoutDayId: workoutDayId,
            exerciseId: exercise.id,
            equipmentId: equipment?.id,
            orderInProgram: newIndex,
            setsSeconds: jsonEncode([60, 60, 60]),
            restTimer: null,
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
            equipmentId: equipment?.id,
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
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    discardStopwatch();
    pageController.dispose();
    super.onClose();
  }
}
