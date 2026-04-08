import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reptrack/persistance/database.dart';
import '../test_helpers.dart';

AppDatabase _makeDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;

  setUpAll(setupTestSqlite);

  setUp(() {
    db = _makeDb();
  });

  tearDown(() => db.close());

  // ── Programs ───────────────────────────────────────────────────────────────

  group('Programs', () {
    test('addProgram returns a non-empty id', () async {
      final id = await db.addProgram('Push Pull Legs');
      expect(id, isNotEmpty);
    });

    test('getAllPrograms reflects inserted rows', () async {
      await db.addProgram('A');
      await db.addProgram('B');
      final all = await db.getAllPrograms();
      expect(all.map((p) => p.name), containsAll(['A', 'B']));
    });

    test('renameProgram updates the name', () async {
      final id = await db.addProgram('Old Name');
      await db.renameProgram(id, 'New Name');
      final all = await db.getAllPrograms();
      final prog = all.firstWhere((p) => p.id == id);
      expect(prog.name, 'New Name');
    });

    test('deleteProgram removes the program', () async {
      final id = await db.addProgram('Temp');
      await db.deleteProgram(id);
      final all = await db.getAllPrograms();
      expect(all.where((p) => p.id == id), isEmpty);
    });

    test('deleteProgram cascades to workout days', () async {
      final progId = await db.addProgram('Prog');
      await db.addWorkoutDay(progId, 'Push Day');
      await db.deleteProgram(progId);
      final days = await db.getWorkoutDaysForProgram(progId);
      expect(days, isEmpty);
    });

    test('deleteProgram cascades to strength exercises', () async {
      final progId = await db.addProgram('Prog');
      final dayId = await db.addWorkoutDay(progId, 'Day A');
      final exId = await db.addExercise('Bench Press');
      await db.addStrengthExerciseToDay(
        workoutDayId: dayId,
        exerciseId: exId,
        setsReps: [10, 8],
      );
      await db.deleteProgram(progId);
      final rows = await db.select(db.programStrengthExercises).get();
      expect(rows.where((r) => r.workoutDayId == dayId), isEmpty);
    });
  });

  // ── Workout days ───────────────────────────────────────────────────────────

  group('WorkoutDays', () {
    late String progId;

    setUp(() async {
      progId = await db.addProgram('Test Program');
    });

    test('addWorkoutDay returns a non-empty id', () async {
      final id = await db.addWorkoutDay(progId, 'Leg Day');
      expect(id, isNotEmpty);
    });

    test('getWorkoutDaysForProgram returns inserted days', () async {
      await db.addWorkoutDay(progId, 'Day 1');
      await db.addWorkoutDay(progId, 'Day 2');
      final days = await db.getWorkoutDaysForProgram(progId);
      expect(days.map((d) => d.dayName), containsAll(['Day 1', 'Day 2']));
    });

    test('renameWorkoutDay updates dayName', () async {
      final id = await db.addWorkoutDay(progId, 'Old');
      await db.renameWorkoutDay(id, 'New');
      final days = await db.getWorkoutDaysForProgram(progId);
      expect(days.firstWhere((d) => d.id == id).dayName, 'New');
    });

    test('deleteWorkoutDay removes the day', () async {
      final id = await db.addWorkoutDay(progId, 'Deletable');
      await db.deleteWorkoutDay(id);
      final days = await db.getWorkoutDaysForProgram(progId);
      expect(days.where((d) => d.id == id), isEmpty);
    });

    test('reorderDays persists new sort order', () async {
      final id1 = await db.addWorkoutDay(progId, 'First');
      final id2 = await db.addWorkoutDay(progId, 'Second');
      await db.reorderDays([id2, id1]);
      final days = await db.getWorkoutDaysForProgram(progId);
      final byId = {for (final d in days) d.id: d};
      expect(byId[id2]!.sortOrder, 0);
      expect(byId[id1]!.sortOrder, 1);
    });
  });

  // ── Exercises ──────────────────────────────────────────────────────────────

  group('Exercises', () {
    test('addExercise returns a non-empty id', () async {
      final id = await db.addExercise('Squat');
      expect(id, isNotEmpty);
    });

    test('getAllExercises reflects added entries', () async {
      await db.addExercise('Deadlift');
      await db.addExercise('OHP');
      final all = await db.getAllExercises();
      expect(all.map((e) => e.name), containsAll(['Deadlift', 'OHP']));
    });

    test('getExerciseByName is case-insensitive', () async {
      await db.addExercise('Bench Press');
      final found = await db.getExerciseByName('bench press');
      expect(found, isNotNull);
      expect(found!.name, 'Bench Press');
    });

    test('getExerciseByName returns null for unknown name', () async {
      final found = await db.getExerciseByName('NonExistent');
      expect(found, isNull);
    });

    test('deleteExercise removes the entry', () async {
      final id = await db.addExercise('Curl');
      await db.deleteExercise(id);
      final all = await db.getAllExercises();
      expect(all.where((e) => e.id == id), isEmpty);
    });
  });

  // ── Program exercises ──────────────────────────────────────────────────────

  group('addStrengthExerciseToDay', () {
    late String dayId;
    late String exId;

    setUp(() async {
      final progId = await db.addProgram('Prog');
      dayId = await db.addWorkoutDay(progId, 'Day');
      exId = await db.addExercise('Bench');
    });

    test('inserts a strength row linked to the day', () async {
      await db.addStrengthExerciseToDay(
        workoutDayId: dayId,
        exerciseId: exId,
        setsReps: [12, 10, 8],
      );
      final rows = await (db.select(db.programStrengthExercises)
            ..where((r) => r.workoutDayId.equals(dayId)))
          .get();
      expect(rows, hasLength(1));
      expect(rows.first.setsReps, '[12,10,8]');
    });

    test('orderInProgram increments with each addition', () async {
      await db.addStrengthExerciseToDay(
        workoutDayId: dayId,
        exerciseId: exId,
        setsReps: [10],
      );
      final exId2 = await db.addExercise('Squat');
      await db.addStrengthExerciseToDay(
        workoutDayId: dayId,
        exerciseId: exId2,
        setsReps: [8],
      );
      final rows = await (db.select(db.programStrengthExercises)
            ..where((r) => r.workoutDayId.equals(dayId))
            ..orderBy([(r) => OrderingTerm(expression: r.orderInProgram)]))
          .get();
      expect(rows[0].orderInProgram, 0);
      expect(rows[1].orderInProgram, 1);
    });
  });

  group('addCardioExerciseToDay', () {
    late String dayId;
    late String exId;

    setUp(() async {
      final progId = await db.addProgram('Prog');
      dayId = await db.addWorkoutDay(progId, 'Day');
      exId = await db.addExercise('Run');
    });

    test('inserts a cardio row with duration and distance', () async {
      await db.addCardioExerciseToDay(
        workoutDayId: dayId,
        exerciseId: exId,
        seconds: 1800,
        distancePlanned: 5.0,
        distancePlannedUnit: 'km',
      );
      final rows = await (db.select(db.programCardioExercises)
            ..where((r) => r.workoutDayId.equals(dayId)))
          .get();
      expect(rows, hasLength(1));
      expect(rows.first.seconds, 1800);
      expect(rows.first.distancePlanned, 5.0);
    });
  });

  group('addHybridExerciseToDay', () {
    late String dayId;
    late String exId;

    setUp(() async {
      final progId = await db.addProgram('Prog');
      dayId = await db.addWorkoutDay(progId, 'Day');
      exId = await db.addExercise('Sled Push');
    });

    test('inserts a hybrid row with distances JSON', () async {
      await db.addHybridExerciseToDay(
        workoutDayId: dayId,
        exerciseId: exId,
        setsDistances: [100.0, 200.0],
        distanceUnit: 'm',
        weight: 50.0,
      );
      final rows = await (db.select(db.programHybridExercises)
            ..where((r) => r.workoutDayId.equals(dayId)))
          .get();
      expect(rows, hasLength(1));
      expect(rows.first.setsDistances, '[100.0,200.0]');
      expect(rows.first.weight, 50.0);
    });
  });

  // ── Workout sets ───────────────────────────────────────────────────────────

  group('Workout strength sets', () {
    late String workoutId;
    late String exId;

    setUp(() async {
      final progId = await db.addProgram('Prog');
      final dayId = await db.addWorkoutDay(progId, 'Day');
      exId = await db.addExercise('Bench');
      workoutId = await db
          .into(db.workouts)
          .insert(WorkoutsCompanion.insert(workoutDayId: dayId))
          .then((_) async {
            final row = await db.select(db.workouts).getSingle();
            return row.id;
          });
    });

    test('getStrengthSetsForExercise returns completed sets', () async {
      await db.into(db.workoutStrengthSets).insert(
        WorkoutStrengthSetsCompanion.insert(
          workoutId: workoutId,
          exerciseId: exId,
          reps: 10,
          weight: 100.0,
          setNumber: 1,
        ),
      );
      final sets = await db.getStrengthSetsForExercise(exId);
      expect(sets, hasLength(1));
      expect(sets.first.reps, 10);
    });

    test('getLastStrengthSetForExercise returns null when no sets exist',
        () async {
      final result = await db.getLastStrengthSetForExercise(exId);
      expect(result, isNull);
    });

    test('getLastStrengthSetForExercise returns most recent set', () async {
      final earlier = DateTime(2024, 1, 1);
      final later = DateTime(2024, 1, 2);

      await db.into(db.workoutStrengthSets).insert(
        WorkoutStrengthSetsCompanion(
          workoutId: Value(workoutId),
          exerciseId: Value(exId),
          reps: const Value(8),
          weight: const Value(80.0),
          setNumber: const Value(1),
          dateLogged: Value(earlier),
        ),
      );
      await db.into(db.workoutStrengthSets).insert(
        WorkoutStrengthSetsCompanion(
          workoutId: Value(workoutId),
          exerciseId: Value(exId),
          reps: const Value(10),
          weight: const Value(100.0),
          setNumber: const Value(2),
          dateLogged: Value(later),
        ),
      );

      final result = await db.getLastStrengthSetForExercise(exId);
      expect(result, isNotNull);
      expect(result!.weight, 100.0);
    });
  });

  group('Workout cardio sets', () {
    late String workoutId;
    late String exId;

    setUp(() async {
      final progId = await db.addProgram('Prog');
      final dayId = await db.addWorkoutDay(progId, 'Day');
      exId = await db.addExercise('Run');
      workoutId = await db
          .into(db.workouts)
          .insert(WorkoutsCompanion.insert(workoutDayId: dayId))
          .then((_) async {
            final row = await db.select(db.workouts).getSingle();
            return row.id;
          });
    });

    test('getCardioSetsForExercise returns completed sets', () async {
      await db.into(db.workoutCardioSets).insert(
        WorkoutCardioSetsCompanion.insert(
          workoutId: workoutId,
          exerciseId: exId,
          durationSeconds: 1800,
        ),
      );
      final sets = await db.getCardioSetsForExercise(exId);
      expect(sets, hasLength(1));
      expect(sets.first.durationSeconds, 1800);
    });

    test('getLastCardioSetForExercise returns null when empty', () async {
      final result = await db.getLastCardioSetForExercise(exId);
      expect(result, isNull);
    });
  });

  group('Workout hybrid sets', () {
    late String workoutId;
    late String exId;

    setUp(() async {
      final progId = await db.addProgram('Prog');
      final dayId = await db.addWorkoutDay(progId, 'Day');
      exId = await db.addExercise('Sled');
      workoutId = await db
          .into(db.workouts)
          .insert(WorkoutsCompanion.insert(workoutDayId: dayId))
          .then((_) async {
            final row = await db.select(db.workouts).getSingle();
            return row.id;
          });
    });

    test('getHybridSetsForExercise returns completed sets', () async {
      await db.into(db.workoutHybridSets).insert(
        WorkoutHybridSetsCompanion.insert(
          workoutId: workoutId,
          exerciseId: exId,
          setNumber: 1,
          weight: 40.0,
          distance: 100.0,
        ),
      );
      final sets = await db.getHybridSetsForExercise(exId);
      expect(sets, hasLength(1));
      expect(sets.first.weight, 40.0);
    });

    test('getLastHybridSetForExercise returns null when empty', () async {
      final result = await db.getLastHybridSetForExercise(exId);
      expect(result, isNull);
    });
  });

  // ── Bodyweight ─────────────────────────────────────────────────────────────

  group('BodyweightEntries', () {
    test('watchBodyweightEntries emits inserted entries in date order',
        () async {
      final later = DateTime(2024, 3, 1);
      final earlier = DateTime(2024, 1, 1);
      await db.addBodyweightEntry(later, 85.0);
      await db.addBodyweightEntry(earlier, 82.0);

      final entries = await db.watchBodyweightEntries().first;
      expect(entries, hasLength(2));
      expect(entries[0].date, earlier);
      expect(entries[1].date, later);
    });

    test('deleteBodyweightEntry removes the entry', () async {
      await db.addBodyweightEntry(DateTime(2024, 1, 1), 80.0);
      final before = await db.watchBodyweightEntries().first;
      expect(before, hasLength(1));

      await db.deleteBodyweightEntry(before.first.id);
      final after = await db.watchBodyweightEntries().first;
      expect(after, isEmpty);
    });
  });
}
