import 'dart:convert';
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

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get muscleGroup => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get timer => integer().nullable()();
  IntColumn get exerciseTypeId =>
      integer().nullable().references(ExerciseTypes, #id)();
}

class ExerciseTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
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
  IntColumn get programId =>
      integer().references(Programs, #id, onDelete: KeyAction.cascade)();
  TextColumn get dayName => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class ProgramExercise extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutDayId =>
      integer().references(WorkoutDays, #id, onDelete: KeyAction.cascade)();
  IntColumn get equipmentId =>
      integer().references(Equipments, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get orderInProgram => integer().withDefault(const Constant(0))();
  // JSON list of reps per set, e.g. "[12,10,8]"
  TextColumn get setsReps => text().withDefault(const Constant('[12]'))();
  IntColumn get restTimer => integer().nullable()();
  IntColumn get seconds => integer().withDefault(const Constant(0))();
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
  IntColumn get workoutId =>
      integer().references(Workouts, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get equipmentId => integer().references(Equipments, #id)();
  IntColumn get reps => integer()();
  RealColumn get weight => real()();
  IntColumn get setNumber => integer()();
  IntColumn get seconds => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
  DateTimeColumn get dateLogged => dateTime().withDefault(currentDate)();
}

@DriftDatabase(
  tables: [
    Exercises,
    ExerciseTypes,
    Equipments,
    MuscleGroups,
    ExerciseMuscleGroup,
    ExerciseEquipment,
    Programs,
    WorkoutDays,
    ProgramExercise,
    Workouts,
    WorkoutSets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await customStatement(
          'ALTER TABLE program_exercise ADD COLUMN seconds INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement(
          'ALTER TABLE workout_sets ADD COLUMN seconds INTEGER NOT NULL DEFAULT 0',
        );
      }
    },
  );

  Future<int> upsertExercise(ExercisesCompanion entry) async {
    return into(exercises).insert(
      entry,
      onConflict: DoUpdate(
        (old) => ExercisesCompanion.custom(
          muscleGroup: Constant(entry.muscleGroup.value),
        ),
        target: [exercises.name],
      ),
    );
  }

  Future<List<Program>> getAllPrograms() => select(programs).get();
  Future<int> addProgram(String name) =>
      into(programs).insert(ProgramsCompanion(name: Value(name)));
  Future<int> deleteProgram(int id) =>
      (delete(programs)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<Exercise>> getAllExercises() => select(exercises).get();

  Future<Exercise?> getExerciseByName(String name) => (select(
    exercises,
  )..where((e) => e.name.lower().equals(name.toLowerCase()))).getSingleOrNull();
  Future<int> addExercise(
    String name, {
    String? muscleGroup,
    String? comment,
    int? timer,
  }) {
    return into(exercises).insert(
      ExercisesCompanion(
        name: Value(name),
        muscleGroup: Value(muscleGroup),
        note: Value(comment),
        timer: Value(timer),
      ),
    );
  }

  Future<int> deleteExercise(int id) =>
      (delete(exercises)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> updateExerciseDetails(
    int id,
    String name,
    String? muscleGroup,
    String? note,
    Set<int> equipmentIds,
  ) async {
    await transaction(() async {
      await (update(exercises)..where((e) => e.id.equals(id))).write(
        ExercisesCompanion(
          name: Value(name),
          muscleGroup: Value(muscleGroup),
          note: Value(note),
        ),
      );
      await (delete(
        exerciseEquipment,
      )..where((e) => e.exerciseId.equals(id))).go();
      for (final equipId in equipmentIds) {
        await into(exerciseEquipment).insert(
          ExerciseEquipmentCompanion(
            exerciseId: Value(id),
            equipmentId: Value(equipId),
          ),
        );
      }
    });
  }

  Future<void> updateExerciseNote(int exerciseId, String? note) {
    return (update(exercises)..where((tbl) => tbl.id.equals(exerciseId))).write(
      ExercisesCompanion(note: Value(note)),
    );
  }

  Future<List<WorkoutDay>> getWorkoutDaysForProgram(int programId) {
    return (select(
      workoutDays,
    )..where((tbl) => tbl.programId.equals(programId))).get();
  }

  Future<int> addWorkoutDay(int programId, String dayName) {
    return into(workoutDays).insert(
      WorkoutDaysCompanion(
        programId: Value(programId),
        dayName: Value(dayName),
      ),
    );
  }

  Future<int> deleteWorkoutDay(int id) =>
      (delete(workoutDays)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<ProgramExerciseData>> getExercisesForDay(int workoutDayId) {
    return (select(
      programExercise,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
  }

  Future<void> deleteExerciseFromWorkoutDay(int dayId, int exerciseId) async {
    await (delete(programExercise)..where(
          (tbl) =>
              tbl.workoutDayId.equals(dayId) &
              tbl.exerciseId.equals(exerciseId),
        ))
        .go();
  }

  Future<int> addExerciseToDay({
    required int workoutDayId,
    required int exerciseId,
    required int equipmentId,
    required List<int> setsReps,
    int? restTimer,
    double weight = 0.0,
  }) async {
    final existing = await (select(
      programExercise,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
    return into(programExercise).insert(
      ProgramExerciseCompanion(
        workoutDayId: Value(workoutDayId),
        exerciseId: Value(exerciseId),
        equipmentId: Value(equipmentId),
        orderInProgram: Value(existing.length),
        setsReps: Value(jsonEncode(setsReps)),
        restTimer: Value(restTimer),
        weight: Value(weight),
      ),
    );
  }

  Future<void> reorderExercisesInDay(List<int> programExerciseIds) async {
    await transaction(() async {
      for (int i = 0; i < programExerciseIds.length; i++) {
        await (update(programExercise)
              ..where((tbl) => tbl.id.equals(programExerciseIds[i])))
            .write(ProgramExerciseCompanion(orderInProgram: Value(i)));
      }
    });
  }

  Future<void> reorderDays(List<int> workoutDayIds) async {
    await transaction(() async {
      for (int i = 0; i < workoutDayIds.length; i++) {
        await (update(workoutDays)
              ..where((tbl) => tbl.id.equals(workoutDayIds[i])))
            .write(WorkoutDaysCompanion(sortOrder: Value(i)));
      }
    });
  }

  Future<int> updateProgramExercise(
    ProgramExerciseCompanion companion,
    int id,
  ) {
    return (update(
      programExercise,
    )..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  Future<int> deleteProgramExercise(int id) =>
      (delete(programExercise)..where((tbl) => tbl.id.equals(id))).go();

  Future<Set<String>> getSecondaryMuscleGroupsForExercises(
    List<int> exerciseIds,
  ) async {
    if (exerciseIds.isEmpty) return {};
    final query =
        select(exerciseMuscleGroup).join([
          innerJoin(
            muscleGroups,
            muscleGroups.id.equalsExp(exerciseMuscleGroup.muscleGroupId),
          ),
        ])..where(
          exerciseMuscleGroup.exerciseId.isIn(exerciseIds) &
              exerciseMuscleGroup.focus.equals('secondary'),
        );
    final rows = await query.get();
    return rows
        .map((r) => r.readTable(muscleGroups).name.toLowerCase())
        .toSet();
  }

  Future<WorkoutSet?> getLastSetForExercise(int exerciseId) {
    return (select(workoutSets)
          ..where((tbl) => tbl.exerciseId.equals(exerciseId))
          ..orderBy([
            (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<Equipment>> getEquipmentForExercise(int exerciseId) async {
    final query = select(equipments).join([
      innerJoin(
        exerciseEquipment,
        exerciseEquipment.equipmentId.equalsExp(equipments.id),
      ),
    ])..where(exerciseEquipment.exerciseId.equals(exerciseId));
    final rows = await query.get();
    return rows.map((row) => row.readTable(equipments)).toList();
  }

  Future<Equipment?> getEquipmentById(int equipmentId) {
    return (select(
      equipments,
    )..where((tbl) => tbl.id.equals(equipmentId))).getSingleOrNull();
  }

  Future<void> deleteWorkoutSet(int workoutId, int exerciseId, int setNumber) {
    return (delete(workoutSets)..where(
          (tbl) =>
              tbl.workoutId.equals(workoutId) &
              tbl.exerciseId.equals(exerciseId) &
              tbl.setNumber.equals(setNumber),
        ))
        .go();
  }

  Future<List<WorkoutSet>> getSetsForExercise(int exerciseId) {
    return (select(workoutSets)
          ..where(
            (tbl) =>
                tbl.exerciseId.equals(exerciseId) &
                tbl.isCompleted.equals(true),
          )
          ..orderBy([
            (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Stream<List<WorkoutDayWithExercises>> watchWorkoutDaysWithExercises(
    int programId,
  ) {
    final dayStream =
        (select(workoutDays)
              ..where((d) => d.programId.equals(programId))
              ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
            .watch();

    return dayStream.switchMap((days) {
      if (days.isEmpty) return Stream.value(<WorkoutDayWithExercises>[]);
      final dayIds = days.map((d) => d.id).toList();

      final query = select(programExercise).join([
        leftOuterJoin(
          exercises,
          exercises.id.equalsExp(programExercise.exerciseId),
        ),
        leftOuterJoin(
          equipments,
          equipments.id.equalsExp(programExercise.equipmentId),
        ),
      ])..where(programExercise.workoutDayId.isIn(dayIds));

      query.orderBy([OrderingTerm(expression: programExercise.orderInProgram)]);

      return query.watch().map((rows) {
        final resultMap = <int, List<ExerciseWithVolume>>{};

        for (final row in rows) {
          final exercise = row.readTableOrNull(exercises);
          final volume = row.readTableOrNull(programExercise);
          final equipment = row.readTableOrNull(equipments);

          if (exercise != null && volume != null && equipment != null) {
            final entry = ExerciseWithVolume(
              exercise: exercise,
              volume: volume,
              equipment: equipment,
            );
            resultMap
                .putIfAbsent(volume.workoutDayId, () => <ExerciseWithVolume>[])
                .add(entry);
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
