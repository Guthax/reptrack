import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
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
}
