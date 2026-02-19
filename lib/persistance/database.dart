import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reptrack/persistance/composites.dart'; // Ensure ExerciseWithVolume & WorkoutDayWithExercises are here
import 'package:rxdart/rxdart.dart';

part 'database.g.dart';


class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get muscleGroup => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get timer => integer().nullable()();
}

class Programs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class WorkoutDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId => integer().references(Programs, #id, onDelete: KeyAction.cascade)();
  TextColumn get dayName => text()();
}

class ProgramExercise extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutDayId => integer().references(WorkoutDays, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get sets => integer()();
  IntColumn get reps => integer()();
  RealColumn get weight => real().withDefault(const Constant(0.0))();
}

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutDayId => integer().references(WorkoutDays, #id)();

  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();
}


class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer().references(Workouts, #id, onDelete: KeyAction.cascade)();

  IntColumn get exerciseId => integer().references(Exercises, #id)();
  
  IntColumn get reps => integer()();
  RealColumn get weight => real()();

  IntColumn get setNumber => integer()(); 
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [Exercises, Programs, WorkoutDays, ProgramExercise, Workouts, WorkoutSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // PROGRAM CRUD
  Future<List<Program>> getAllPrograms() => select(programs).get();
  Future<int> addProgram(String name) =>
      into(programs).insert(ProgramsCompanion(name: Value(name)));
  Future<int> deleteProgram(int id) =>
      (delete(programs)..where((tbl) => tbl.id.equals(id))).go();

  // EXERCISE CRUD
  Future<List<Exercise>> getAllExercises() => select(exercises).get();
  Future<int> addExercise(String name,
      {String? muscleGroup, String? comment, int? timer}) {
    return into(exercises).insert(ExercisesCompanion(
      name: Value(name),
      muscleGroup: Value(muscleGroup),
      note: Value(comment),
      timer: Value(timer),
    ));
  }

  Future<int> deleteExercise(int id) =>
      (delete(exercises)..where((tbl) => tbl.id.equals(id))).go();

  // WORKOUT DAYS CRUD
  Future<List<WorkoutDay>> getWorkoutDaysForProgram(int programId) {
    return (select(workoutDays)..where((tbl) => tbl.programId.equals(programId))).get();
  }

  Future<int> addWorkoutDay(int programId, String dayName) {
    return into(workoutDays).insert(WorkoutDaysCompanion(
      programId: Value(programId),
      dayName: Value(dayName),
    ));
  }

  Future<int> deleteWorkoutDay(int id) =>
      (delete(workoutDays)..where((tbl) => tbl.id.equals(id))).go();

  // PROGRAM EXERCISES CRUD
  Future<List<ProgramExerciseData>> getExercisesForDay(int workoutDayId) {
    return (select(programExercise)..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
  }

  Future<int> addExerciseToDay({
  required int workoutDayId,
  required int exerciseId,
  required int sets,
  required int reps,
  double weight = 0.0,
}) {
  print("Adding exercise to day: workoutDayId=$workoutDayId, exerciseId=$exerciseId, sets=$sets, reps=$reps");
  return into(programExercise).insert(ProgramExerciseCompanion(
    workoutDayId: Value(workoutDayId),
    exerciseId: Value(exerciseId),
    sets: Value(sets),
    reps: Value(reps),
    weight: Value(weight),
  ));
}

  Future<int> updateProgramExercise(ProgramExerciseCompanion companion, int id) {
    return (update(programExercise)..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  Future<int> deleteProgramExercise(int id) =>
      (delete(programExercise)..where((tbl) => tbl.id.equals(id))).go();


// Inside AppDatabase class
Future<WorkoutSet?> getLastSetForExercise(int exerciseId) {
  return (select(workoutSets)
        ..where((tbl) => tbl.exerciseId.equals(exerciseId))
        ..orderBy([(u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc)])
        ..limit(1))
      .getSingleOrNull();
}

Stream<List<WorkoutDayWithExercises>> watchWorkoutDaysWithExercises(int programId) {
  // 1. Watch the days first
  final dayStream = (select(workoutDays)
        ..where((d) => d.programId.equals(programId))
        ..orderBy([(t) => OrderingTerm(expression: t.id)]))
      .watch();

  return dayStream.switchMap((days) {
    if (days.isEmpty) return Stream.value([]);

    final dayIds = days.map((d) => d.id).toList();

    // 2. Create the join query
    final query = select(programExercise).join([
      innerJoin(exercises, exercises.id.equalsExp(programExercise.exerciseId)),
    ])..where(programExercise.workoutDayId.isIn(dayIds));

    // 3. Watch the join query
    return query.watch().map((rows) {
      final resultMap = <int, List<ExerciseWithVolume>>{};

      for (final row in rows) {
        final exercise = row.readTable(exercises);
        final volume = row.readTable(programExercise);
        
        resultMap.putIfAbsent(volume.workoutDayId, () => []).add(
          ExerciseWithVolume(
            exercise: exercise,
            volume: volume,
          ),
        );
      }

      return days.map((day) {
        return WorkoutDayWithExercises(
          workoutDay: day,
          exercises: resultMap[day.id] ?? [],
        );
      }).toList();
    });
  });
}

Future<void> seedDatabase() async {
  await transaction(() async {
    // 1. Clear existing data (Optional - use with caution!)
    // await delete(programExercise).go();
    // await delete(workoutDays).go();
    // await delete(programs).go();
    // await delete(exercises).go();

    // 2. Add Exercises (Global Library)
    final benchPressId = await addExercise("Bench Press", muscleGroup: "Chest", timer: 180);
    final squatId = await addExercise("Back Squat", muscleGroup: "Legs", timer: 240);
    final pullUpId = await addExercise("Pull Ups", muscleGroup: "Back", timer: 120);
    final deadliftId = await addExercise("Deadlift", muscleGroup: "Back/Legs", timer: 300);

    // 3. Create a Program
    final programId = await addProgram("Push/Pull Split");

    // 4. Create Workout Days for that Program
    final pushDayId = await addWorkoutDay(programId, "Push Day");
    final pullDayId = await addWorkoutDay(programId, "Pull Day");

    // 5. Assign Exercises to Days (ProgramExercise)
    // Push Day Exercises
    await addExerciseToDay(
      workoutDayId: pushDayId,
      exerciseId: benchPressId,
      sets: 3,
      reps: 8,
      weight: 60.0,
    );
    await addExerciseToDay(
      workoutDayId: pushDayId,
      exerciseId: squatId, // Adding a leg exercise to push for variety
      sets: 3,
      reps: 5,
      weight: 100.0,
    );

    // Pull Day Exercises
    await addExerciseToDay(
      workoutDayId: pullDayId,
      exerciseId: pullUpId,
      sets: 4,
      reps: 10,
      weight: 0.0,
    );
    await addExerciseToDay(
      workoutDayId: pullDayId,
      exerciseId: deadliftId,
      sets: 3,
      reps: 5,
      weight: 120.0,
    );

    print("Database seeded successfully!");
  });
}


}

// --- Connection Logic ---

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    print(dbFolder.path);
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });


  
}