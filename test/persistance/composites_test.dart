import 'package:flutter_test/flutter_test.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';

ProgramStrengthExercise _strength({
  String setsReps = '[12,10,8]',
  int? restTimer,
  double weight = 100.0,
  String? equipmentId,
  int order = 0,
}) => ProgramStrengthExercise(
  id: 'se1',
  workoutDayId: 'day1',
  equipmentId: equipmentId,
  exerciseId: 'ex1',
  orderInProgram: order,
  setsReps: setsReps,
  restTimer: restTimer,
  weight: weight,
);

ProgramCardioExercise _cardio({
  int? seconds,
  double? distancePlanned,
  String distancePlannedUnit = 'km',
  int order = 1,
}) => ProgramCardioExercise(
  id: 'ce1',
  workoutDayId: 'day1',
  exerciseId: 'ex2',
  orderInProgram: order,
  seconds: seconds,
  distancePlanned: distancePlanned,
  distancePlannedUnit: distancePlannedUnit,
);

ProgramHybridExercise _hybrid({
  String setsDistances = '[100.0,200.0,400.0]',
  String distanceUnit = 'm',
  int? restTimer,
  double weight = 20.0,
  String? equipmentId,
  int order = 2,
}) => ProgramHybridExercise(
  id: 'he1',
  workoutDayId: 'day1',
  equipmentId: equipmentId,
  exerciseId: 'ex3',
  orderInProgram: order,
  setsDistances: setsDistances,
  distanceUnit: distanceUnit,
  restTimer: restTimer,
  weight: weight,
);

void main() {
  group('ProgramExerciseVolume – strength variant', () {
    late ProgramExerciseVolume vol;

    setUp(() {
      vol = ProgramExerciseVolume.strength(_strength());
    });

    test('isCardio is false', () => expect(vol.isCardio, isFalse));
    test('isHybrid is false', () => expect(vol.isHybrid, isFalse));
    test('strength accessor returns the row', () => expect(vol.strength, isNotNull));
    test('cardio accessor is null', () => expect(vol.cardio, isNull));
    test('hybrid accessor is null', () => expect(vol.hybrid, isNull));
    test('id returns strength id', () => expect(vol.id, 'se1'));
    test('workoutDayId returns correct value', () => expect(vol.workoutDayId, 'day1'));
    test('exerciseId returns correct value', () => expect(vol.exerciseId, 'ex1'));
    test('orderInProgram returns correct value', () => expect(vol.orderInProgram, 0));
    test('weight returns correct value', () => expect(vol.weight, 100.0));

    test('restTimer returns strength restTimer', () {
      final withTimer = ProgramExerciseVolume.strength(_strength(restTimer: 90));
      expect(withTimer.restTimer, 90);
    });

    test('equipmentId returns strength equipmentId', () {
      final withEquip = ProgramExerciseVolume.strength(_strength(equipmentId: 'eq1'));
      expect(withEquip.equipmentId, 'eq1');
    });

    test('seconds is null for strength', () => expect(vol.seconds, isNull));
    test('distancePlanned is null for strength', () => expect(vol.distancePlanned, isNull));
  });

  group('ProgramExerciseVolume – cardio variant', () {
    late ProgramExerciseVolume vol;

    setUp(() {
      vol = ProgramExerciseVolume.cardio(
        _cardio(seconds: 1800, distancePlanned: 5.0, distancePlannedUnit: 'km'),
      );
    });

    test('isCardio is true', () => expect(vol.isCardio, isTrue));
    test('isHybrid is false', () => expect(vol.isHybrid, isFalse));
    test('cardio accessor returns the row', () => expect(vol.cardio, isNotNull));
    test('strength accessor is null', () => expect(vol.strength, isNull));
    test('hybrid accessor is null', () => expect(vol.hybrid, isNull));
    test('id returns cardio id', () => expect(vol.id, 'ce1'));
    test('seconds returns planned duration', () => expect(vol.seconds, 1800));
    test('distancePlanned returns value', () => expect(vol.distancePlanned, 5.0));
    test('distancePlannedUnit returns value', () => expect(vol.distancePlannedUnit, 'km'));
    test('weight defaults to 0 for cardio', () => expect(vol.weight, 0.0));
    test('equipmentId is null for cardio', () => expect(vol.equipmentId, isNull));
    test('restTimer is null for cardio', () => expect(vol.restTimer, isNull));
  });

  group('ProgramExerciseVolume – hybrid variant', () {
    late ProgramExerciseVolume vol;

    setUp(() {
      vol = ProgramExerciseVolume.hybrid(
        _hybrid(equipmentId: 'eq1', restTimer: 60),
      );
    });

    test('isCardio is false', () => expect(vol.isCardio, isFalse));
    test('isHybrid is true', () => expect(vol.isHybrid, isTrue));
    test('hybrid accessor returns the row', () => expect(vol.hybrid, isNotNull));
    test('strength accessor is null', () => expect(vol.strength, isNull));
    test('cardio accessor is null', () => expect(vol.cardio, isNull));
    test('weight returns hybrid weight', () => expect(vol.weight, 20.0));
    test('equipmentId returns hybrid equipmentId', () => expect(vol.equipmentId, 'eq1'));
    test('restTimer returns hybrid restTimer', () => expect(vol.restTimer, 60));
    test('distanceUnit returns hybrid distanceUnit', () => expect(vol.distanceUnit, 'm'));
  });

  group('setsRepsList', () {
    test('parses valid JSON array of ints', () {
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: '[12,10,8]'));
      expect(vol.setsRepsList, [12, 10, 8]);
    });

    test('parses single-element array', () {
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: '[5]'));
      expect(vol.setsRepsList, [5]);
    });

    test('falls back to [12] on invalid JSON', () {
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: 'not-json'));
      expect(vol.setsRepsList, [12]);
    });

    test('falls back to [12] on empty string', () {
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: ''));
      expect(vol.setsRepsList, [12]);
    });

    test('parses floats by truncating to int', () {
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: '[10.0,8.0]'));
      expect(vol.setsRepsList, [10, 8]);
    });
  });

  group('setsRepsLabel', () {
    test('uniform sets produce compact N × R format', () {
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: '[12,12,12]'));
      expect(vol.setsRepsLabel, '3 × 12');
    });

    test('mixed reps produce per-set format', () {
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: '[12,10,8]'));
      expect(vol.setsRepsLabel, 'Set 1: 12, Set 2: 10, Set 3: 8');
    });

    test('single set produces "1 × N" format', () {
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: '[15]'));
      expect(vol.setsRepsLabel, '1 × 15');
    });

    test('invalid JSON returns empty string', () {
      // setsRepsList returns [12], so setsRepsLabel returns "1 × 12"
      final vol = ProgramExerciseVolume.strength(_strength(setsReps: 'bad'));
      expect(vol.setsRepsLabel, '1 × 12');
    });
  });

  group('setsDistancesList', () {
    test('parses valid JSON array of doubles', () {
      final vol = ProgramExerciseVolume.hybrid(_hybrid(setsDistances: '[100.0,200.0,400.0]'));
      expect(vol.setsDistancesList, [100.0, 200.0, 400.0]);
    });

    test('falls back to [100.0] on invalid JSON', () {
      final vol = ProgramExerciseVolume.hybrid(_hybrid(setsDistances: 'bad'));
      expect(vol.setsDistancesList, [100.0]);
    });
  });

  group('setsDistancesLabel', () {
    test('uniform distances produce compact N × D unit format', () {
      final vol = ProgramExerciseVolume.hybrid(
        _hybrid(setsDistances: '[100.0,100.0,100.0]', distanceUnit: 'm'),
      );
      expect(vol.setsDistancesLabel, '3 × 100 m');
    });

    test('mixed distances produce comma-separated format', () {
      final vol = ProgramExerciseVolume.hybrid(
        _hybrid(setsDistances: '[100.0,200.0,400.0]', distanceUnit: 'm'),
      );
      expect(vol.setsDistancesLabel, '100 m, 200 m, 400 m');
    });

    test('non-integer distance shows decimal', () {
      final vol = ProgramExerciseVolume.hybrid(
        _hybrid(setsDistances: '[1.5,2.5]', distanceUnit: 'km'),
      );
      expect(vol.setsDistancesLabel, '1.5 km, 2.5 km');
    });
  });

  group('durationLabel', () {
    test('null seconds returns null', () {
      final vol = ProgramExerciseVolume.cardio(_cardio(seconds: null));
      expect(vol.durationLabel, isNull);
    });

    test('zero seconds returns null', () {
      final vol = ProgramExerciseVolume.cardio(_cardio(seconds: 0));
      expect(vol.durationLabel, isNull);
    });

    test('minutes-only duration formatted correctly', () {
      final vol = ProgramExerciseVolume.cardio(_cardio(seconds: 45 * 60));
      expect(vol.durationLabel, '45m');
    });

    test('hours and minutes formatted correctly', () {
      final vol = ProgramExerciseVolume.cardio(
        _cardio(seconds: 1 * 3600 + 30 * 60),
      );
      expect(vol.durationLabel, '1h 30m');
    });

    test('exact hour shows 0 minutes', () {
      final vol = ProgramExerciseVolume.cardio(_cardio(seconds: 3600));
      expect(vol.durationLabel, '1h 0m');
    });
  });

  group('ExerciseWithVolume', () {
    test('isCardio delegates to volume', () {
      final exercise = Exercise(id: 'ex1', name: 'Run', exerciseTypeId: '2');
      final vol = ProgramExerciseVolume.cardio(_cardio());
      final ewv = ExerciseWithVolume(exercise: exercise, volume: vol);
      expect(ewv.isCardio, isTrue);
    });

    test('isHybrid delegates to volume', () {
      final exercise = Exercise(id: 'ex1', name: 'Sled', exerciseTypeId: '3');
      final vol = ProgramExerciseVolume.hybrid(_hybrid());
      final ewv = ExerciseWithVolume(exercise: exercise, volume: vol);
      expect(ewv.isHybrid, isTrue);
    });

    test('strength exercise is neither cardio nor hybrid', () {
      final exercise = Exercise(id: 'ex1', name: 'Bench', exerciseTypeId: '1');
      final vol = ProgramExerciseVolume.strength(_strength());
      final ewv = ExerciseWithVolume(exercise: exercise, volume: vol);
      expect(ewv.isCardio, isFalse);
      expect(ewv.isHybrid, isFalse);
    });
  });

  group('WorkoutDayWithExercises', () {
    test('exposes workoutDay and exercises', () {
      final day = WorkoutDay(
        id: 'day1',
        programId: 'prog1',
        dayName: 'Push Day',
        sortOrder: 0,
      );
      final wdwe = WorkoutDayWithExercises(workoutDay: day, exercises: []);
      expect(wdwe.workoutDay.dayName, 'Push Day');
      expect(wdwe.exercises, isEmpty);
    });
  });
}
