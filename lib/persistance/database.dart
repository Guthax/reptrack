import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
part 'database.g.dart';

// Tables
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get muscleGroup => text().nullable()();
  TextColumn get comment => text().nullable()();
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

// Database
@DriftDatabase(tables: [Exercises, Programs, WorkoutDays, ProgramExercise])
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
      comment: Value(comment),
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
}

// Lazy database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
