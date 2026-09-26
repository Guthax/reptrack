import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/controllers/create_exercise_controller.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/error_handler.dart';
import '../test_helpers.dart';

/// Subclass that skips the async DB setup so we can test pure-logic methods
/// without standing up a full workout session.
class _TestableController extends ActiveWorkoutController {
  _TestableController() : super('test-day-id');
}

/// Builds a strength [ExerciseWithVolume] fixture with 3 planned sets for
/// position [i] in the workout.
ExerciseWithVolume _strengthExercise(int i) => ExerciseWithVolume(
  exercise: Exercise(id: 'ex$i', name: 'Exercise $i', exerciseTypeId: '1'),
  volume: ProgramExerciseVolume.strength(
    ProgramStrengthExercise(
      id: 'se$i',
      workoutDayId: 'test-day-id',
      exerciseId: 'ex$i',
      orderInProgram: i,
      setsReps: '[12,10,8]',
      weight: 100.0,
    ),
  ),
);

/// Marks each set in [setNums] of the exercise at [exerciseIndex] with
/// [equipmentId] as completed on [c].
void _logSets(
  ActiveWorkoutController c,
  int exerciseIndex,
  String equipmentId,
  List<int> setNums,
) {
  for (final n in setNums) {
    c.completedSets.add('$exerciseIndex-$equipmentId-$n');
  }
}

/// Waits until the async workout setup started in `onInit` has finished, so
/// it cannot overwrite fixtures assigned to `exercisesWithVolume` afterwards.
Future<void> _waitForSetup(ActiveWorkoutController c) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (c.isLoading.value) {
    if (DateTime.now().isAfter(deadline)) fail('setup did not finish');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

void main() {
  late _TestableController controller;

  setUpAll(setupTestSqlite);

  setUp(() {
    Get.testMode = true;
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    Get.put<AppDatabase>(db);
    controller = Get.put(_TestableController());
  });

  tearDown(Get.reset);

  group('extra sets', () {
    test('addExtraSet increments count for exercise/equipment key', () {
      controller.addExtraSet(0, 'eq1');
      expect(controller.extraSetsCount['0-eq1'], 1);
    });

    test('addExtraSet accumulates multiple calls', () {
      controller.addExtraSet(0, 'eq1');
      controller.addExtraSet(0, 'eq1');
      expect(controller.extraSetsCount['0-eq1'], 2);
    });

    test('addExtraSet is scoped to its key', () {
      controller.addExtraSet(0, 'eq1');
      controller.addExtraSet(1, 'eq2');
      expect(controller.extraSetsCount['0-eq1'], 1);
      expect(controller.extraSetsCount['1-eq2'], 1);
    });

    test('removeExtraSet decrements count', () {
      controller.addExtraSet(0, 'eq1');
      controller.addExtraSet(0, 'eq1');
      controller.removeExtraSet(0, 'eq1');
      expect(controller.extraSetsCount['0-eq1'], 1);
    });

    test('removeExtraSet does not go below zero', () {
      controller.removeExtraSet(0, 'eq1');
      expect(controller.extraSetsCount['0-eq1'] ?? 0, 0);
    });
  });

  group('getTotalSetsForExercise', () {
    test('returns planned sets when no extras added', () {
      expect(controller.getTotalSetsForExercise(0, 3, 'eq1'), 3);
    });

    test('adds extra sets to planned sets', () {
      controller.addExtraSet(0, 'eq1');
      controller.addExtraSet(0, 'eq1');
      expect(controller.getTotalSetsForExercise(0, 3, 'eq1'), 5);
    });

    test('extra sets on different exercise do not bleed over', () {
      controller.addExtraSet(1, 'eq1');
      expect(controller.getTotalSetsForExercise(0, 3, 'eq1'), 3);
    });
  });

  group('isSetCompleted / isCardioCompleted', () {
    test('set is not completed initially', () {
      expect(controller.isSetCompleted(0, 'eq1', 1), isFalse);
    });

    test('marking a key completed is reflected by isSetCompleted', () {
      controller.completedSets.add('0-eq1-1');
      expect(controller.isSetCompleted(0, 'eq1', 1), isTrue);
    });

    test('cardio is not completed initially', () {
      expect(controller.isCardioCompleted(0), isFalse);
    });

    test('marking cardio key completed is reflected', () {
      controller.completedSets.add('0-cardio-1');
      expect(controller.isCardioCompleted(0), isTrue);
    });

    test('completing one set does not affect sibling sets', () {
      controller.completedSets.add('0-eq1-1');
      expect(controller.isSetCompleted(0, 'eq1', 2), isFalse);
      expect(controller.isSetCompleted(1, 'eq1', 1), isFalse);
    });
  });

  group('getLastLoggedSet', () {
    test('returns null when no sets logged for exercise', () {
      expect(controller.getLastLoggedSet(0, 'eq1'), isNull);
    });

    test('returns the most recently added set for the matching equipment', () {
      final first = WorkoutStrengthSetsCompanion.insert(
        workoutId: 'w1',
        exerciseId: 'ex1',
        reps: 10,
        weight: 100.0,
        setNumber: 1,
      );
      final second = WorkoutStrengthSetsCompanion.insert(
        workoutId: 'w1',
        exerciseId: 'ex1',
        reps: 8,
        weight: 100.0,
        setNumber: 2,
      );
      controller.sessionLoggedSets[0] = [first, second];
      controller.sessionLoggedSets.refresh();

      final result = controller.getLastLoggedSet(0, null);
      expect(result?.reps.value, 8);
    });

    test('returns null when equipment id does not match', () {
      final set = WorkoutStrengthSetsCompanion.insert(
        workoutId: 'w1',
        exerciseId: 'ex1',
        reps: 10,
        weight: 100.0,
        setNumber: 1,
      );
      controller.sessionLoggedSets[0] = [set];
      controller.sessionLoggedSets.refresh();

      // The set has no equipmentId (Value(null)), we query for 'eq-other'
      final result = controller.getLastLoggedSet(0, 'eq-other');
      expect(result, isNull);
    });
  });

  group('rest timer', () {
    test('startRestTimer with 0 seconds does nothing', () {
      controller.startRestTimer(0);
      expect(controller.remainingRestTime.value, 0);
    });

    test('startRestTimer with negative seconds does nothing', () {
      controller.startRestTimer(-1);
      expect(controller.remainingRestTime.value, 0);
    });

    test('startRestTimer sets remainingRestTime to given seconds', () {
      controller.startRestTimer(30);
      expect(controller.remainingRestTime.value, 30);
      controller.skipRestTimer(); // clean up
    });

    test('skipRestTimer resets remainingRestTime to zero', () {
      controller.startRestTimer(60);
      controller.skipRestTimer();
      expect(controller.remainingRestTime.value, 0);
    });

    test('starting a new timer cancels the previous one', () {
      controller.startRestTimer(60);
      controller.startRestTimer(30);
      expect(controller.remainingRestTime.value, 30);
      controller.skipRestTimer();
    });
  });

  group('swapExercise – bounds check', () {
    test('out-of-bounds exerciseIndex is a no-op', () async {
      // No exercises in list, index 0 is out of bounds
      await controller.swapExercise(
        exerciseIndex: 0,
        newExercise: Exercise(id: 'ex-new', name: 'New', exerciseTypeId: '1'),
        newEquipmentId: 'eq1',
      );
      expect(controller.exercisesWithVolume, isEmpty);
    });
  });

  group('updateExerciseInMemory – bounds check', () {
    test('out-of-bounds index is a no-op', () {
      controller.updateExerciseInMemory(
        99,
        Exercise(id: 'ex1', name: 'Bench', exerciseTypeId: '1'),
      );
      expect(controller.exercisesWithVolume, isEmpty);
    });
  });

  group('auto-advance with extra sets', () {
    setUp(() async {
      await _waitForSetup(controller);
      controller.exercisesWithVolume.assignAll([
        _strengthExercise(0),
        _strengthExercise(1),
      ]);
    });

    test('regression: 3 planned + 1 extra, 3 logged does not advance', () {
      controller.addExtraSet(0, 'eq1');
      _logSets(controller, 0, 'eq1', [1, 2, 3]);

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isFalse);
      expect(
        controller.shouldAutoAdvance(
          exerciseIndex: 0,
          plannedSets: 3,
          equipmentId: 'eq1',
        ),
        isFalse,
      );
    });

    test('3 planned + 1 extra, all 4 logged advances', () {
      controller.addExtraSet(0, 'eq1');
      _logSets(controller, 0, 'eq1', [1, 2, 3, 4]);

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isTrue);
      expect(
        controller.shouldAutoAdvance(
          exerciseIndex: 0,
          plannedSets: 3,
          equipmentId: 'eq1',
        ),
        isTrue,
      );
    });

    test('out-of-order logging with a planned set open is incomplete', () {
      controller.addExtraSet(0, 'eq1');
      _logSets(controller, 0, 'eq1', [1, 2, 4]);

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isFalse);
    });

    test('sets logged under other equipment do not count', () {
      _logSets(controller, 0, 'eq2', [1, 2, 3]);

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isFalse);
    });

    test('2 planned + 2 extra completes only after the last extra set', () {
      controller.addExtraSet(0, 'eq1');
      controller.addExtraSet(0, 'eq1');
      _logSets(controller, 0, 'eq1', [1, 2, 3]);

      expect(controller.isExerciseComplete(0, 2, 'eq1'), isFalse);

      _logSets(controller, 0, 'eq1', [4]);

      expect(controller.isExerciseComplete(0, 2, 'eq1'), isTrue);
    });
  });

  group('auto-advance without extra sets', () {
    setUp(() async {
      await _waitForSetup(controller);
      controller.exercisesWithVolume.assignAll([
        _strengthExercise(0),
        _strengthExercise(1),
      ]);
    });

    test('all planned sets logged advances', () {
      _logSets(controller, 0, 'eq1', [1, 2, 3]);

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isTrue);
      expect(
        controller.shouldAutoAdvance(
          exerciseIndex: 0,
          plannedSets: 3,
          equipmentId: 'eq1',
        ),
        isTrue,
      );
    });

    test('a planned set still open does not advance', () {
      _logSets(controller, 0, 'eq1', [1, 2]);

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isFalse);
      expect(
        controller.shouldAutoAdvance(
          exerciseIndex: 0,
          plannedSets: 3,
          equipmentId: 'eq1',
        ),
        isFalse,
      );
    });

    test('last exercise complete does not advance', () {
      _logSets(controller, 1, 'eq1', [1, 2, 3]);

      expect(controller.isExerciseComplete(1, 3, 'eq1'), isTrue);
      expect(
        controller.shouldAutoAdvance(
          exerciseIndex: 1,
          plannedSets: 3,
          equipmentId: 'eq1',
        ),
        isFalse,
      );
    });

    test('adding an extra set to a complete exercise makes it incomplete', () {
      _logSets(controller, 0, 'eq1', [1, 2, 3]);
      controller.addExtraSet(0, 'eq1');

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isFalse);
    });

    test('unlogging a set makes a complete exercise incomplete', () {
      _logSets(controller, 0, 'eq1', [1, 2, 3]);
      controller.completedSets.remove('0-eq1-2');

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isFalse);
    });

    test('removing the open extra set makes the exercise complete', () {
      controller.addExtraSet(0, 'eq1');
      _logSets(controller, 0, 'eq1', [1, 2, 3]);
      controller.removeExtraSet(0, 'eq1');

      expect(controller.isExerciseComplete(0, 3, 'eq1'), isTrue);
    });
  });

  group('timed exercises', () {
    const tag = 'timed';
    late AppDatabase db;
    late ActiveWorkoutController timed;
    late String dayId;
    late String plankId;
    late DateTime now;
    late List<String> snackbarErrors;
    late List<Object> systemErrors;

    setUp(() async {
      snackbarErrors = [];
      systemErrors = [];
      AppSnackbar.overrideErrorForTest(snackbarErrors.add);
      AppErrorHandler.overrideForTest((e, _) => systemErrors.add(e));
      db = Get.find<AppDatabase>();
      final progId = await db.addProgram('Core');
      dayId = await db.addWorkoutDay(progId, 'Day');
      plankId = await db.addExercise('Plank', exerciseTypeId: '4');
      await db.addTimedExerciseToDay(
        workoutDayId: dayId,
        exerciseId: plankId,
        equipmentId: '1',
        setsSeconds: [60, 60, 60],
        restTimer: 60,
      );
      final pastWorkoutId = 'past-workout';
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: d.Value(pastWorkoutId),
              workoutDayId: dayId,
            ),
          );
      Future<void> pastSet(int setNum, int seconds, double? weight, int day) =>
          db
              .into(db.workoutTimedSets)
              .insert(
                WorkoutTimedSetsCompanion.insert(
                  workoutId: pastWorkoutId,
                  exerciseId: plankId,
                  equipmentId: const d.Value('1'),
                  setNumber: setNum,
                  durationSeconds: seconds,
                  weight: d.Value(weight),
                  dateLogged: d.Value(DateTime(2024, 1, day)),
                ),
              );
      await pastSet(1, 50, null, 3);
      await pastSet(2, 0, null, 2);
      await pastSet(3, 40, 12.5, 1);

      now = DateTime(2024, 2, 1, 12);
      timed = Get.put(
        ActiveWorkoutController(dayId, clock: () => now),
        tag: tag,
      );
      await _waitForSetup(timed);
    });

    tearDown(() {
      AppSnackbar.resetForTest();
      AppErrorHandler.resetForTest();
    });

    Future<List<WorkoutTimedSet>> currentSets() => (db.select(
      db.workoutTimedSets,
    )..where((t) => t.workoutId.equals(timed.currentWorkoutId!))).get();

    group('Timed logging', () {
      test('setup loads the timed volume and prefetches lastTimedSets', () {
        expect(timed.exercisesWithVolume, hasLength(1));
        expect(timed.exercisesWithVolume.first.isTimed, isTrue);
        expect(timed.lastTimedSets[plankId], hasLength(3));
      });

      test('logTimedSet inserts the set and starts the rest timer', () async {
        final ok = await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 75,
          setNum: 1,
          restSeconds: 60,
        );
        final sets = await currentSets();
        expect(ok, isTrue);
        expect(sets.single.durationSeconds, 75);
        expect(sets.single.weight, isNull);
        expect(timed.isSetCompleted(0, '1', 1), isTrue);
        expect(timed.remainingRestTime.value, 60);
        timed.skipRestTimer();
      });

      test('logTimedSet stores the weight in kg', () async {
        await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 60,
          weightKg: 10,
          setNum: 1,
        );
        expect((await currentSets()).single.weight, 10.0);
      });

      test('a zero duration is rejected with a snackbar', () async {
        final ok = await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 0,
          setNum: 1,
        );
        expect(ok, isFalse);
        expect(await currentSets(), isEmpty);
        expect(snackbarErrors, ['Enter a duration']);
        expect(timed.isSetCompleted(0, '1', 1), isFalse);
      });

      test('a negative weight is rejected with a snackbar', () async {
        final ok = await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 30,
          weightKg: -5,
          setNum: 1,
        );
        expect(ok, isFalse);
        expect(await currentSets(), isEmpty);
        expect(snackbarErrors, ["Weight can't be negative"]);
      });

      test('unlogTimedSet marks the set incomplete', () async {
        await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 30,
          setNum: 1,
        );
        await timed.unlogTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          setNum: 1,
        );
        expect((await currentSets()).single.isCompleted, isFalse);
        expect(timed.isSetCompleted(0, '1', 1), isFalse);
      });

      test('getPastTimedSetData skips converted 0-second sets', () {
        expect(timed.getPastTimedSetData(plankId, 1, '1')?.durationSeconds, 50);
        expect(timed.getPastTimedSetData(plankId, 2, '1'), isNull);
        expect(timed.getPastTimedSetData(plankId, 3, '1')?.durationSeconds, 40);
      });

      test('getLastTimedWeight returns the newest non-null weight', () {
        expect(timed.getLastTimedWeight(plankId), 12.5);
        expect(timed.getLastTimedWeight('unknown'), isNull);
      });

      test('loadTimedHistory includes sets logged this session', () async {
        await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 90,
          setNum: 1,
        );
        final history = await timed.loadTimedHistory(plankId);
        expect(history, hasLength(4));
        expect(history.first.durationSeconds, 90);
      });

      test('auto-advance waits for the timed extra set', () async {
        timed.exercisesWithVolume.add(_strengthExercise(1));
        timed.addExtraSet(0, '1');
        for (final n in [1, 2, 3]) {
          await timed.logTimedSet(
            exerciseIndex: 0,
            exerciseId: plankId,
            equipmentId: '1',
            durationSeconds: 30,
            setNum: n,
          );
        }
        expect(
          timed.shouldAutoAdvance(
            exerciseIndex: 0,
            plannedSets: 3,
            equipmentId: '1',
          ),
          isFalse,
        );
        await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 30,
          setNum: 4,
        );
        expect(
          timed.shouldAutoAdvance(
            exerciseIndex: 0,
            plannedSets: 3,
            equipmentId: '1',
          ),
          isTrue,
        );
      });
    });

    group('Stopwatch', () {
      test('stop returns whole elapsed seconds and records the result', () {
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(milliseconds: 52900));
        expect(timed.stopStopwatch(), 52);
        expect(timed.runningStopwatchKey.value, isNull);
        expect(timed.timedEntries['0-1-1']?.seconds, 52);
      });

      test('starting another stopwatch stops and reports the first', () {
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(seconds: 10));
        timed.startStopwatch('0-1-2');
        expect(timed.timedEntries['0-1-1']?.seconds, 10);
        expect(timed.runningStopwatchKey.value, '0-1-2');
        expect(timed.stopwatchElapsedSeconds.value, 0);
        timed.discardStopwatch();
      });

      test('elapsed time is based on the clock, not on ticks', () {
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(minutes: 5));
        expect(timed.stopStopwatch(), 300);
      });

      test('stop without a running stopwatch returns 0', () {
        expect(timed.stopStopwatch(), 0);
        expect(timed.timedEntries, isEmpty);
      });

      test('discardStopwatch leaves no result', () {
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(seconds: 20));
        timed.discardStopwatch();
        expect(timed.runningStopwatchKey.value, isNull);
        expect(timed.timedEntries, isEmpty);
      });

      test('logging a set stops its running stopwatch', () async {
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(seconds: 15));
        await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 15,
          setNum: 1,
        );
        expect(timed.runningStopwatchKey.value, isNull);
      });

      test('onClose discards a running stopwatch', () async {
        timed.startStopwatch('0-1-1');
        await Get.delete<ActiveWorkoutController>(tag: tag);
        expect(timed.runningStopwatchKey.value, isNull);
        expect(timed.timedEntries, isEmpty);
      });

      test('swapExercise discards a running stopwatch', () async {
        await db.addExercise('Side Plank', exerciseTypeId: '4');
        timed.startStopwatch('0-1-1');
        await timed.swapExercise(
          exerciseIndex: 0,
          newExercise: (await db.getExerciseByName('Side Plank'))!,
          newEquipmentId: '1',
        );
        expect(timed.runningStopwatchKey.value, isNull);
        expect(timed.timedEntries, isEmpty);
      });
    });

    group('Focus layout stopwatch', () {
      test('resuming adds only the running periods', () {
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(seconds: 30));
        timed.stopStopwatch();
        now = now.add(const Duration(seconds: 60));
        timed.startStopwatch('0-1-1');
        expect(timed.stopwatchElapsedSeconds.value, 30);
        now = now.add(const Duration(seconds: 10));
        expect(timed.stopStopwatch(), 40);
        expect(timed.timedEntries['0-1-1']?.seconds, 40);
      });

      test('starting the stopwatch skips a running rest timer', () {
        timed.startRestTimer(45);
        timed.startStopwatch('0-1-1');
        expect(timed.remainingRestTime.value, 0);
        expect(timed.runningStopwatchKey.value, '0-1-1');
        timed.discardStopwatch();
      });

      test('selectEquipment discards a running stopwatch', () {
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(seconds: 20));
        timed.selectEquipment(0, '2');
        expect(timed.runningStopwatchKey.value, isNull);
        expect(timed.timedEntries, isEmpty);
        expect(timed.selectedEquipments[0], '2');
      });

      test('stopping keeps the weight of an existing entry', () {
        timed.timedEntries['0-1-1'] = const TimedSetEntry(
          seconds: 10,
          weightKg: 5,
        );
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(seconds: 5));
        timed.stopStopwatch();
        expect(timed.timedEntries['0-1-1']?.seconds, 15);
        expect(timed.timedEntries['0-1-1']?.weightKg, 5);
      });
    });

    group('Entries and phases', () {
      const key = '0-1-1';

      test('phase moves idle → running → ready → idle', () {
        expect(timed.timedPhase(key), TimedSetPhase.idle);
        timed.startStopwatch(key);
        expect(timed.timedPhase(key), TimedSetPhase.running);
        now = now.add(const Duration(seconds: 20));
        timed.stopStopwatch();
        expect(timed.timedPhase(key), TimedSetPhase.ready);
        timed.resetTimedEntry(key);
        expect(timed.timedPhase(key), TimedSetPhase.idle);
        expect(timed.timedEntries[key], isNull);
      });

      test('setTimedEntrySeconds sets and clears the entry', () {
        timed.setTimedEntrySeconds(key, 48);
        expect(timed.timedPhase(key), TimedSetPhase.ready);
        expect(timed.timedEntries[key]?.seconds, 48);
        timed.setTimedEntrySeconds(key, 0);
        expect(timed.timedEntries[key], isNull);
      });

      test('logging stores the entry and unlogging keeps it', () async {
        await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 55,
          weightKg: 8,
          setNum: 1,
        );
        expect(timed.timedEntries[key]?.seconds, 55);
        expect(timed.timedEntries[key]?.weightKg, 8);
        expect(timed.timedPhase(key), TimedSetPhase.idle);
        await timed.unlogTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          setNum: 1,
        );
        expect(timed.timedEntries[key]?.seconds, 55);
        expect(timed.timedPhase(key), TimedSetPhase.ready);
      });
    });

    group('Active set', () {
      Future<void> log(int setNum) => timed.logTimedSet(
        exerciseIndex: 0,
        exerciseId: plankId,
        equipmentId: '1',
        durationSeconds: 30,
        setNum: setNum,
      );

      test('defaults to the first set', () {
        expect(timed.activeTimedSetNum(0, '1', 3), 1);
      });

      test('moves to the next unlogged set after logging', () async {
        await log(1);
        expect(timed.activeTimedSetNum(0, '1', 3), 2);
      });

      test('is null when every set is logged', () async {
        for (final n in [1, 2, 3]) {
          await log(n);
        }
        expect(timed.activeTimedSetNum(0, '1', 3), isNull);
      });

      test('a selected unlogged set becomes active', () async {
        await log(1);
        timed.selectTimedSet(0, '1', 3);
        expect(timed.activeTimedSetNum(0, '1', 3), 3);
      });

      test(
        'logging the selected set falls back to the first open set',
        () async {
          timed.selectTimedSet(0, '1', 3);
          await log(3);
          expect(timed.activeTimedSetNum(0, '1', 3), 1);
        },
      );

      test('selecting a logged set has no effect', () async {
        await log(2);
        timed.selectTimedSet(0, '1', 2);
        expect(timed.activeTimedSetNum(0, '1', 3), 1);
      });

      test('selecting another set stops the running stopwatch', () {
        timed.startStopwatch('0-1-1');
        now = now.add(const Duration(seconds: 12));
        timed.selectTimedSet(0, '1', 2);
        expect(timed.runningStopwatchKey.value, isNull);
        expect(timed.timedEntries['0-1-1']?.seconds, 12);
        expect(timed.activeTimedSetNum(0, '1', 3), 2);
      });

      test('unlogging a set makes it active with its entry kept', () async {
        await log(1);
        await log(2);
        await timed.unlogTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          setNum: 1,
        );
        expect(timed.activeTimedSetNum(0, '1', 3), 1);
        expect(timed.timedEntries['0-1-1']?.seconds, 30);
      });

      test('an extra set becomes active once all are logged', () async {
        for (final n in [1, 2, 3]) {
          await log(n);
        }
        timed.addExtraSet(0, '1');
        final total = timed.getTotalSetsForExercise(0, 3, '1');
        expect(timed.activeTimedSetNum(0, '1', total), 4);
      });
    });

    group('Timed weight', () {
      test('setup pre-fills the last weighted set', () {
        expect(timed.timedWeightKg[0], 12.5);
      });

      test('the weight is logged and carried over', () async {
        timed.setTimedWeight(0, 10);
        await timed.logTimedSet(
          exerciseIndex: 0,
          exerciseId: plankId,
          equipmentId: '1',
          durationSeconds: 30,
          weightKg: timed.timedWeightKg[0],
          setNum: 1,
        );
        expect(timed.timedEntries['0-1-1']?.weightKg, 10.0);
        expect((await currentSets()).single.weight, 10.0);
        expect(timed.timedWeightKg[0], 10.0);
      });

      test('setTimedWeight(null) clears the weight', () {
        timed.setTimedWeight(0, null);
        expect(timed.timedWeightKg[0], isNull);
      });

      test('adding a timed exercise initialises its weight', () async {
        await db.addExercise('L-Sit', exerciseTypeId: '4');
        final lSit = (await db.getExerciseByName('L-Sit'))!;
        await timed.addExerciseDuringWorkout(exercise: lSit);
        final index = timed.exercisesWithVolume.length - 1;
        expect(timed.timedWeightKg.containsKey(index), isTrue);
        expect(timed.timedWeightKg[index], isNull);
      });
    });

    group('Swap and add to timed', () {
      test('swapping strength for timed keeps set count and rest', () async {
        timed.exercisesWithVolume.add(
          ExerciseWithVolume(
            exercise: Exercise(id: 'bench', name: 'Bench', exerciseTypeId: '1'),
            volume: ProgramExerciseVolume.strength(
              ProgramStrengthExercise(
                id: 'se-bench',
                workoutDayId: dayId,
                exerciseId: 'bench',
                orderInProgram: 1,
                setsReps: '[12,10,8]',
                restTimer: 90,
                weight: 80.0,
              ),
            ),
          ),
        );
        await db.addExercise('Wall Sit', exerciseTypeId: '4');
        final wallSit = (await db.getExerciseByName('Wall Sit'))!;
        await timed.swapExercise(
          exerciseIndex: 1,
          newExercise: wallSit,
          newEquipmentId: '1',
        );
        final swapped = timed.exercisesWithVolume[1];
        expect(swapped.isTimed, isTrue);
        expect(swapped.exercise.id, wallSit.id);
        expect(swapped.volume.setsSecondsList, [0, 0, 0]);
        expect(swapped.volume.restTimer, 90);
        expect(systemErrors, isEmpty);
      });

      test('addExerciseDuringWorkout appends a timed volume', () async {
        await db.addExercise('Hollow Body Hold', exerciseTypeId: '4');
        final hollow = (await db.getExerciseByName('Hollow Body Hold'))!;
        await timed.addExerciseDuringWorkout(exercise: hollow);
        expect(systemErrors, isEmpty);
        final added = timed.exercisesWithVolume.last;
        expect(added.isTimed, isTrue);
        expect(added.volume.setsSecondsList, [60, 60, 60]);
      });

      /// Builds a strength bench slot with 3 sets and a 90 second rest.
      ExerciseWithVolume benchSlot() => ExerciseWithVolume(
        exercise: Exercise(id: 'bench', name: 'Bench', exerciseTypeId: '1'),
        volume: ProgramExerciseVolume.strength(
          ProgramStrengthExercise(
            id: 'se-bench',
            workoutDayId: dayId,
            exerciseId: 'bench',
            orderInProgram: 1,
            setsReps: '[12,10,8]',
            restTimer: 90,
            weight: 80.0,
          ),
        ),
      );

      /// Inserts equipment rows with [ids], since the test database is empty.
      Future<void> addEquipment(List<String> ids) async {
        for (final id in ids) {
          await db
              .into(db.equipments)
              .insert(
                EquipmentsCompanion.insert(
                  id: d.Value(id),
                  name: 'Equipment $id',
                  iconName: 'equipment_$id',
                ),
              );
        }
      }

      test(
        'swapping without an equipment id picks the first compatible equipment',
        () async {
          timed.exercisesWithVolume.add(benchSlot());
          await addEquipment(['2', '3']);
          final rowId = await db.addExercise(
            'Machine Row',
            exerciseTypeId: '1',
          );
          for (final equipmentId in ['2', '3']) {
            await db
                .into(db.exerciseEquipment)
                .insert(
                  ExerciseEquipmentCompanion(
                    exerciseId: d.Value(rowId),
                    equipmentId: d.Value(equipmentId),
                  ),
                );
          }
          final machineRow = (await db.getExerciseByName('Machine Row'))!;
          await timed.swapExercise(exerciseIndex: 1, newExercise: machineRow);
          final expectedId = (await db.getEquipmentForExercise(rowId)).first.id;
          expect(timed.selectedEquipments[1], expectedId);
          expect(timed.exercisesWithVolume[1].equipment?.id, expectedId);
          expect(timed.exercisesWithVolume[1].exercise.id, rowId);
          expect(systemErrors, isEmpty);
        },
      );

      test(
        'swapping to a newly created timed exercise uses the existing defaults',
        () async {
          timed.exercisesWithVolume.add(benchSlot());
          await addEquipment(['1']);
          final creator = Get.put(CreateExerciseController());
          creator.exerciseTypeSelected('4');
          final created = await creator.createExercise(
            name: 'Dead Hang',
            equipmentIds: {'1'},
          );
          expect(created, isNotNull);
          await timed.swapExercise(exerciseIndex: 1, newExercise: created!);
          final swapped = timed.exercisesWithVolume[1];
          expect(swapped.isTimed, isTrue);
          expect(swapped.exercise.id, created.id);
          expect(swapped.volume.setsSecondsList, [0, 0, 0]);
          expect(swapped.volume.restTimer, 90);
          expect(timed.timedWeightKg[1], isNull);
          expect(swapped.equipment?.id, '1');
          expect(snackbarErrors, isEmpty);
          expect(systemErrors, isEmpty);
          Get.delete<CreateExerciseController>();
        },
      );

      test(
        'adding without an equipment id picks the first compatible equipment',
        () async {
          await addEquipment(['2', '3']);
          final creator = Get.put(CreateExerciseController());
          creator.exerciseTypeSelected('1');
          final created = await creator.createExercise(
            name: 'Cable Fly',
            equipmentIds: {'2', '3'},
          );
          expect(created, isNotNull);
          await timed.addExerciseDuringWorkout(exercise: created!);
          final index = timed.exercisesWithVolume.length - 1;
          final added = timed.exercisesWithVolume[index];
          final expectedId = (await db.getEquipmentForExercise(
            created.id,
          )).first.id;
          expect(added.exercise.id, created.id);
          expect(added.equipment?.id, expectedId);
          expect(added.volume.equipmentId, expectedId);
          expect(timed.selectedEquipments[index], expectedId);
          expect(snackbarErrors, isEmpty);
          expect(systemErrors, isEmpty);
          Get.delete<CreateExerciseController>();
        },
      );
    });
  });

  group('getSwapCandidates', () {
    test('returns every exercise except the excluded one', () async {
      final db = Get.find<AppDatabase>();
      final aId = await db.addExercise('Swap A', exerciseTypeId: '1');
      final bId = await db.addExercise('Swap B', exerciseTypeId: '1');
      final candidates = await controller.getSwapCandidates(aId);
      final ids = candidates.map((e) => e.id).toList();
      expect(ids, contains(bId));
      expect(ids, isNot(contains(aId)));
      expect(candidates.length, (await db.getAllExercises()).length - 1);
    });
  });
}
