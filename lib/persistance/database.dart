import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reptrack/persistance/composites.dart'; 
import 'package:rxdart/rxdart.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

// --- TABLES ---

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get muscleGroup => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get timer => integer().nullable()();
}

class MuscleGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Equipments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get icon_name => text().unique()();
}

class ExerciseEquipment extends Table {
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get equipmentId => integer().references(Equipments, #id)();

  @override
  Set<Column> get primaryKey => {exerciseId, equipmentId};
}

class ExerciseMuscleGroup extends Table {
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get muscleGroupId => integer().references(MuscleGroups, #id)();
  TextColumn get focus => text()();

  @override
  Set<Column> get primaryKey => {exerciseId, muscleGroupId};
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
  IntColumn get equipmentId => integer().references(Equipments, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get orderInProgram => integer().withDefault(const Constant(0))();
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
  IntColumn get equipmentId => integer().references(Equipments, #id)();
  IntColumn get reps => integer()();
  RealColumn get weight => real()();
  IntColumn get setNumber => integer()(); 
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
  DateTimeColumn get dateLogged => dateTime().withDefault(currentDate)();
}

@DriftDatabase(tables: [Exercises, Equipments, MuscleGroups, ExerciseMuscleGroup, ExerciseEquipment, Programs, WorkoutDays, ProgramExercise, Workouts, WorkoutSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;


  // --- UPSERT FOR SEEDING ---
  Future<int> upsertExercise(ExercisesCompanion entry) async {
    return into(exercises).insert(
      entry,
      onConflict: DoUpdate(
        (old) => ExercisesCompanion.custom(
          // Extract the raw value and wrap it in a Constant expression
          muscleGroup: Constant(entry.muscleGroup.value),
        ),
        target: [exercises.name],
      ),
    );
  }

  // --- PROGRAM CRUD ---
  Future<List<Program>> getAllPrograms() => select(programs).get();
  Future<int> addProgram(String name) => into(programs).insert(ProgramsCompanion(name: Value(name)));
  Future<int> deleteProgram(int id) => (delete(programs)..where((tbl) => tbl.id.equals(id))).go();

  // --- EXERCISE CRUD ---
  Future<List<Exercise>> getAllExercises() => select(exercises).get();
  Future<int> addExercise(String name, {String? muscleGroup, String? comment, int? timer}) {
    return into(exercises).insert(ExercisesCompanion(
      name: Value(name),
      muscleGroup: Value(muscleGroup),
      note: Value(comment),
      timer: Value(timer),
    ));
  }
  Future<int> deleteExercise(int id) => (delete(exercises)..where((tbl) => tbl.id.equals(id))).go();

  // --- WORKOUT DAYS CRUD ---
  Future<List<WorkoutDay>> getWorkoutDaysForProgram(int programId) {
    return (select(workoutDays)..where((tbl) => tbl.programId.equals(programId))).get();
  }
  Future<int> addWorkoutDay(int programId, String dayName) {
    return into(workoutDays).insert(WorkoutDaysCompanion(programId: Value(programId), dayName: Value(dayName)));
  }
  Future<int> deleteWorkoutDay(int id) => (delete(workoutDays)..where((tbl) => tbl.id.equals(id))).go();

  // --- PROGRAM EXERCISES CRUD ---
  Future<List<ProgramExerciseData>> getExercisesForDay(int workoutDayId) {
    return (select(programExercise)..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
  }
  Future<void> deleteExerciseFromWorkoutDay(int dayId, int exerciseId) async {
    await (delete(programExercise)..where((tbl) => tbl.workoutDayId.equals(dayId) & tbl.exerciseId.equals(exerciseId))).go();
  }
  Future<int> addExerciseToDay({
    required int workoutDayId,
    required int exerciseId,
    required int equipmentId,
    required int sets,
    required int reps,
    double weight = 0.0,
  }) {
    return into(programExercise).insert(ProgramExerciseCompanion(
      workoutDayId: Value(workoutDayId),
      exerciseId: Value(exerciseId),
      equipmentId: Value(equipmentId),
      sets: Value(sets),
      reps: Value(reps),
      weight: Value(weight),
    ));
  }
  Future<int> updateProgramExercise(ProgramExerciseCompanion companion, int id) {
    return (update(programExercise)..where((tbl) => tbl.id.equals(id))).write(companion);
  }
  Future<int> deleteProgramExercise(int id) => (delete(programExercise)..where((tbl) => tbl.id.equals(id))).go();

  // --- HISTORY & QUERIES ---
  Future<WorkoutSet?> getLastSetForExercise(int exerciseId) {
    return (select(workoutSets)
          ..where((tbl) => tbl.exerciseId.equals(exerciseId))
          ..orderBy([(u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<Equipment>> getEquipmentForExercise(int exerciseId) async {
    final query = select(equipments).join([
      innerJoin(exerciseEquipment, exerciseEquipment.equipmentId.equalsExp(equipments.id)),
    ])..where(exerciseEquipment.exerciseId.equals(exerciseId));
    final rows = await query.get();
    return rows.map((row) => row.readTable(equipments)).toList();
  }

  Future<List<WorkoutSet>> getSetsForExercise(int exerciseId) {
    return (select(workoutSets)
          ..where((tbl) => tbl.exerciseId.equals(exerciseId))
          ..orderBy([(u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc)]))
        .get();
  }

  // --- THE FIXED STREAM ---
  Stream<List<WorkoutDayWithExercises>> watchWorkoutDaysWithExercises(int programId) {
    final dayStream = (select(workoutDays)
          ..where((d) => d.programId.equals(programId))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .watch();

    return dayStream.switchMap((days) {
      if (days.isEmpty) return Stream.value(<WorkoutDayWithExercises>[]);
      final dayIds = days.map((d) => d.id).toList();

      final query = select(programExercise).join([
        leftOuterJoin(exercises, exercises.id.equalsExp(programExercise.exerciseId)),
        leftOuterJoin(equipments, equipments.id.equalsExp(programExercise.equipmentId)),
      ])..where(programExercise.workoutDayId.isIn(dayIds));

      return query.watch().map((rows) {
        final resultMap = <int, List<ExerciseWithVolume>>{};

        for (final row in rows) {
          final exercise = row.readTableOrNull(exercises);
          final volume = row.readTableOrNull(programExercise);
          final equipment = row.readTableOrNull(equipments);
          
          // Only add to list if all required components exist
          if (exercise != null && volume != null && equipment != null) {
            final entry = ExerciseWithVolume(
              exercise: exercise,
              volume: volume,
              equipment: equipment,
            );
            resultMap.putIfAbsent(volume.workoutDayId, () => <ExerciseWithVolume>[]).add(entry);
          }
        }

        return days.map((day) {
          return WorkoutDayWithExercises(
            workoutDay: day,
            exercises: resultMap[day.id] ?? <ExerciseWithVolume>[],
          );
        }).toList();
      });
    });
  }
}