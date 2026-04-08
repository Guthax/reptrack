import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/persistance/database.dart';
import '../test_helpers.dart';

/// Subclass that skips the async DB setup so we can test pure-logic methods
/// without standing up a full workout session.
class _TestableController extends ActiveWorkoutController {
  _TestableController() : super('test-day-id');
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
}
