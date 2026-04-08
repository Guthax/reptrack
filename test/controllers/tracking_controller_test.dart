import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/tracking_controller.dart';
import 'package:reptrack/persistance/database.dart';
import '../test_helpers.dart';

WorkoutStrengthSet _strengthSet({
  required String id,
  required String exerciseId,
  required double weight,
  required int reps,
  required DateTime date,
  String? equipmentId,
}) => WorkoutStrengthSet(
  id: id,
  workoutId: 'w1',
  exerciseId: exerciseId,
  equipmentId: equipmentId,
  reps: reps,
  weight: weight,
  setNumber: 1,
  isCompleted: true,
  dateLogged: date,
);

WorkoutCardioSet _cardioSet({
  required String id,
  required String exerciseId,
  required int durationSeconds,
  double? distanceMeters,
  required DateTime date,
}) => WorkoutCardioSet(
  id: id,
  workoutId: 'w1',
  exerciseId: exerciseId,
  durationSeconds: durationSeconds,
  distanceMeters: distanceMeters,
  distanceUnit: 'km',
  isCompleted: true,
  dateLogged: date,
);

WorkoutHybridSet _hybridSet({
  required String id,
  required String exerciseId,
  required double weight,
  required double distanceMeters,
  required DateTime date,
  String? equipmentId,
}) => WorkoutHybridSet(
  id: id,
  workoutId: 'w1',
  exerciseId: exerciseId,
  equipmentId: equipmentId,
  setNumber: 1,
  weight: weight,
  distance: distanceMeters,
  distanceUnit: 'm',
  distanceMeters: distanceMeters,
  isCompleted: true,
  dateLogged: date,
);

void main() {
  late TrackingController controller;

  setUpAll(setupTestSqlite);

  setUp(() {
    Get.testMode = true;
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    Get.put<AppDatabase>(db);
    controller = Get.put(TrackingController());
  });

  tearDown(Get.reset);

  final day1 = DateTime(2024, 1, 1);
  final day2 = DateTime(2024, 1, 2);

  // ── weightProgressData ─────────────────────────────────────────────────────

  group('weightProgressData', () {
    test('returns empty list when no sets logged', () {
      expect(controller.weightProgressData, isEmpty);
    });

    test('returns max weight per calendar day', () {
      controller.exerciseSets.assignAll([
        _strengthSet(
          id: 's1',
          exerciseId: 'ex1',
          weight: 80,
          reps: 10,
          date: day1,
        ),
        _strengthSet(
          id: 's2',
          exerciseId: 'ex1',
          weight: 100,
          reps: 8,
          date: day1,
        ),
        _strengthSet(
          id: 's3',
          exerciseId: 'ex1',
          weight: 90,
          reps: 8,
          date: day1,
        ),
      ]);

      final data = controller.weightProgressData;
      expect(data, hasLength(1));
      expect(data.first.value, 100.0);
    });

    test('groups by calendar day and sorts chronologically', () {
      controller.exerciseSets.assignAll([
        _strengthSet(
          id: 's2',
          exerciseId: 'ex1',
          weight: 90,
          reps: 8,
          date: day2,
        ),
        _strengthSet(
          id: 's1',
          exerciseId: 'ex1',
          weight: 80,
          reps: 10,
          date: day1,
        ),
      ]);

      final data = controller.weightProgressData;
      expect(data, hasLength(2));
      expect(data[0].key, day1);
      expect(data[1].key, day2);
    });

    test('filters by selectedEquipment when set', () {
      final eq = Equipment(id: 'eq1', name: 'Barbell', iconName: 'barbell');
      controller.selectedEquipment.value = eq;
      controller.exerciseSets.assignAll([
        _strengthSet(
          id: 's1',
          exerciseId: 'ex1',
          weight: 100,
          reps: 8,
          date: day1,
          equipmentId: 'eq1',
        ),
        _strengthSet(
          id: 's2',
          exerciseId: 'ex1',
          weight: 120,
          reps: 8,
          date: day1,
          equipmentId: 'eq2',
        ),
      ]);

      final data = controller.weightProgressData;
      expect(data, hasLength(1));
      expect(data.first.value, 100.0);
    });

    test('includes all sets when selectedEquipment is null', () {
      controller.selectedEquipment.value = null;
      controller.exerciseSets.assignAll([
        _strengthSet(
          id: 's1',
          exerciseId: 'ex1',
          weight: 100,
          reps: 8,
          date: day1,
          equipmentId: 'eq1',
        ),
        _strengthSet(
          id: 's2',
          exerciseId: 'ex1',
          weight: 120,
          reps: 8,
          date: day1,
          equipmentId: 'eq2',
        ),
      ]);

      final data = controller.weightProgressData;
      expect(data, hasLength(1));
      expect(data.first.value, 120.0);
    });
  });

  // ── volumeProgressData ─────────────────────────────────────────────────────

  group('volumeProgressData', () {
    test('returns empty list when no sets logged', () {
      expect(controller.volumeProgressData, isEmpty);
    });

    test('sums weight × reps across all sets in a day', () {
      controller.exerciseSets.assignAll([
        _strengthSet(
          id: 's1',
          exerciseId: 'ex1',
          weight: 100,
          reps: 5,
          date: day1,
        ),
        _strengthSet(
          id: 's2',
          exerciseId: 'ex1',
          weight: 100,
          reps: 5,
          date: day1,
        ),
      ]);

      final data = controller.volumeProgressData;
      expect(data, hasLength(1));
      expect(data.first.value, 1000.0); // 100×5 + 100×5
    });

    test('groups across multiple days', () {
      controller.exerciseSets.assignAll([
        _strengthSet(
          id: 's1',
          exerciseId: 'ex1',
          weight: 100,
          reps: 5,
          date: day1,
        ),
        _strengthSet(
          id: 's2',
          exerciseId: 'ex1',
          weight: 80,
          reps: 10,
          date: day2,
        ),
      ]);

      final data = controller.volumeProgressData;
      expect(data, hasLength(2));
      expect(data[0].value, 500.0); // day1: 100×5
      expect(data[1].value, 800.0); // day2: 80×10
    });

    test('respects selectedEquipment filter', () {
      final eq = Equipment(id: 'eq1', name: 'Barbell', iconName: 'barbell');
      controller.selectedEquipment.value = eq;
      controller.exerciseSets.assignAll([
        _strengthSet(
          id: 's1',
          exerciseId: 'ex1',
          weight: 100,
          reps: 5,
          date: day1,
          equipmentId: 'eq1',
        ),
        _strengthSet(
          id: 's2',
          exerciseId: 'ex1',
          weight: 100,
          reps: 5,
          date: day1,
          equipmentId: 'eq2',
        ),
      ]);

      final data = controller.volumeProgressData;
      expect(data.first.value, 500.0); // only eq1 set counted
    });
  });

  // ── cardioDurationData ─────────────────────────────────────────────────────

  group('cardioDurationData', () {
    test('returns empty when no cardio sets', () {
      expect(controller.cardioDurationData, isEmpty);
    });

    test('converts total seconds to minutes per day', () {
      controller.cardioSets.assignAll([
        _cardioSet(
          id: 'c1',
          exerciseId: 'ex2',
          durationSeconds: 1800,
          date: day1,
        ),
        _cardioSet(
          id: 'c2',
          exerciseId: 'ex2',
          durationSeconds: 1800,
          date: day1,
        ),
      ]);

      final data = controller.cardioDurationData;
      expect(data, hasLength(1));
      expect(data.first.value, 60.0); // 3600s / 60
    });

    test('produces one entry per day', () {
      controller.cardioSets.assignAll([
        _cardioSet(
          id: 'c1',
          exerciseId: 'ex2',
          durationSeconds: 600,
          date: day1,
        ),
        _cardioSet(
          id: 'c2',
          exerciseId: 'ex2',
          durationSeconds: 600,
          date: day2,
        ),
      ]);

      final data = controller.cardioDurationData;
      expect(data, hasLength(2));
      expect(data[0].key, day1);
      expect(data[1].key, day2);
    });
  });

  // ── cardioDistanceData ─────────────────────────────────────────────────────

  group('cardioDistanceData', () {
    test('excludes sessions without distance data', () {
      controller.cardioSets.assignAll([
        _cardioSet(
          id: 'c1',
          exerciseId: 'ex2',
          durationSeconds: 600,
          date: day1,
        ),
      ]);
      expect(controller.cardioDistanceData, isEmpty);
    });

    test('sums distance in km per day', () {
      controller.cardioSets.assignAll([
        _cardioSet(
          id: 'c1',
          exerciseId: 'ex2',
          durationSeconds: 600,
          distanceMeters: 2500,
          date: day1,
        ),
        _cardioSet(
          id: 'c2',
          exerciseId: 'ex2',
          durationSeconds: 600,
          distanceMeters: 2500,
          date: day1,
        ),
      ]);

      final data = controller.cardioDistanceData;
      expect(data, hasLength(1));
      expect(data.first.value, closeTo(5.0, 0.001)); // 5000m / 1000
    });
  });

  // ── cardioPaceData ─────────────────────────────────────────────────────────

  group('cardioPaceData', () {
    test('returns empty when no sets with distance', () {
      controller.cardioSets.assignAll([
        _cardioSet(
          id: 'c1',
          exerciseId: 'ex2',
          durationSeconds: 600,
          date: day1,
        ),
      ]);
      expect(controller.cardioPaceData, isEmpty);
    });

    test('calculates pace in min/km', () {
      // 10 min over 2 km = 5 min/km
      controller.cardioSets.assignAll([
        _cardioSet(
          id: 'c1',
          exerciseId: 'ex2',
          durationSeconds: 600,
          distanceMeters: 2000,
          date: day1,
        ),
      ]);

      final data = controller.cardioPaceData;
      expect(data, hasLength(1));
      expect(data.first.value, closeTo(5.0, 0.001));
    });
  });

  // ── hybridMaxWeightData ────────────────────────────────────────────────────

  group('hybridMaxWeightData', () {
    test('returns empty when no hybrid sets', () {
      expect(controller.hybridMaxWeightData, isEmpty);
    });

    test('returns max weight per day', () {
      controller.hybridSets.assignAll([
        _hybridSet(
          id: 'h1',
          exerciseId: 'ex3',
          weight: 20,
          distanceMeters: 100,
          date: day1,
        ),
        _hybridSet(
          id: 'h2',
          exerciseId: 'ex3',
          weight: 30,
          distanceMeters: 100,
          date: day1,
        ),
      ]);

      final data = controller.hybridMaxWeightData;
      expect(data, hasLength(1));
      expect(data.first.value, 30.0);
    });

    test('filters by selectedEquipment', () {
      final eq = Equipment(id: 'eq1', name: 'Barbell', iconName: 'barbell');
      controller.selectedEquipment.value = eq;
      controller.hybridSets.assignAll([
        _hybridSet(
          id: 'h1',
          exerciseId: 'ex3',
          weight: 20,
          distanceMeters: 100,
          date: day1,
          equipmentId: 'eq1',
        ),
        _hybridSet(
          id: 'h2',
          exerciseId: 'ex3',
          weight: 50,
          distanceMeters: 100,
          date: day1,
          equipmentId: 'eq2',
        ),
      ]);

      final data = controller.hybridMaxWeightData;
      expect(data.first.value, 20.0);
    });
  });

  // ── hybridTotalDistanceData ────────────────────────────────────────────────

  group('hybridTotalDistanceData', () {
    test('sums distanceMeters per day', () {
      controller.hybridSets.assignAll([
        _hybridSet(
          id: 'h1',
          exerciseId: 'ex3',
          weight: 20,
          distanceMeters: 200,
          date: day1,
        ),
        _hybridSet(
          id: 'h2',
          exerciseId: 'ex3',
          weight: 20,
          distanceMeters: 300,
          date: day1,
        ),
      ]);

      final data = controller.hybridTotalDistanceData;
      expect(data, hasLength(1));
      expect(data.first.value, 500.0);
    });
  });

  // ── hybridVolumeData ───────────────────────────────────────────────────────

  group('hybridVolumeData', () {
    test('sums weight × distanceMeters per day', () {
      controller.hybridSets.assignAll([
        _hybridSet(
          id: 'h1',
          exerciseId: 'ex3',
          weight: 20,
          distanceMeters: 100,
          date: day1,
        ),
        _hybridSet(
          id: 'h2',
          exerciseId: 'ex3',
          weight: 30,
          distanceMeters: 200,
          date: day1,
        ),
      ]);

      final data = controller.hybridVolumeData;
      expect(data, hasLength(1));
      expect(data.first.value, closeTo(8000.0, 0.001)); // 20×100 + 30×200
    });
  });

  // ── filterExercises ────────────────────────────────────────────────────────

  group('filterExercises', () {
    setUp(() {
      controller.allExercises.assignAll([
        Exercise(id: 'ex1', name: 'Bench Press', exerciseTypeId: '1'),
        Exercise(id: 'ex2', name: 'Squat', exerciseTypeId: '1'),
        Exercise(id: 'ex3', name: 'Deadlift', exerciseTypeId: '1'),
      ]);
      controller.filteredExercises.assignAll(controller.allExercises);
    });

    test('empty query shows all exercises', () {
      controller.filterExercises('');
      expect(controller.filteredExercises, hasLength(3));
    });

    test('exact match filters correctly', () {
      controller.filterExercises('squat');
      expect(controller.filteredExercises, hasLength(1));
      expect(controller.filteredExercises.first.name, 'Squat');
    });

    test('no match yields empty list', () {
      controller.filterExercises('zzz');
      expect(controller.filteredExercises, isEmpty);
    });
  });

  // ── clearSelection ─────────────────────────────────────────────────────────

  group('clearSelection', () {
    test('resets all exercise-related state', () {
      controller.selectedExercise.value = Exercise(
        id: 'ex1',
        name: 'Bench',
        exerciseTypeId: '1',
      );
      controller.exerciseSets.add(
        _strengthSet(
          id: 's1',
          exerciseId: 'ex1',
          weight: 100,
          reps: 5,
          date: day1,
        ),
      );

      controller.clearSelection();

      expect(controller.selectedExercise.value, isNull);
      expect(controller.exerciseSets, isEmpty);
      expect(controller.cardioSets, isEmpty);
      expect(controller.hybridSets, isEmpty);
      expect(controller.availableEquipment, isEmpty);
      expect(controller.selectedEquipment.value, isNull);
    });
  });
}
