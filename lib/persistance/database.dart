import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:rxdart/rxdart.dart';

part 'database.g.dart';

/// Opens the app's SQLite database file, creating it on first launch.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reptrack.sqlite'));
    return NativeDatabase(file);
  });
}

/// Stores the exercise library — both seeded and user-created entries.
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get muscleGroup => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get timer => integer().nullable()();
  IntColumn get exerciseTypeId =>
      integer().nullable().references(ExerciseTypes, #id)();
}

/// Lookup table for exercise categories (e.g. Strength, Cardio).
class ExerciseTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// Lookup table for muscle groups used to tag exercises.
class MuscleGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// Lookup table for equipment types (e.g. Barbell, Dumbbells).
class Equipments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get icon_name => text().unique()();
}

/// Join table linking exercises to the equipment variants they support.
class ExerciseEquipment extends Table {
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get equipmentId => integer().references(Equipments, #id)();

  @override
  Set<Column> get primaryKey => {exerciseId, equipmentId};
}

/// Join table mapping exercises to muscle groups with a primary/secondary focus.
class ExerciseMuscleGroup extends Table {
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get muscleGroupId => integer().references(MuscleGroups, #id)();
  TextColumn get focus => text()();

  @override
  Set<Column> get primaryKey => {exerciseId, muscleGroupId};
}

/// A user-created training program (e.g. "Push Pull Legs").
class Programs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

/// A named training day belonging to a [Programs] entry (e.g. "Push Day").
class WorkoutDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId =>
      integer().references(Programs, #id, onDelete: KeyAction.cascade)();
  TextColumn get dayName => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// An exercise entry within a workout day, carrying volume and equipment config.
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

/// A logged workout session tied to a specific [WorkoutDays] entry.
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutDayId => integer().references(WorkoutDays, #id)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();
}

/// An individual set logged during a workout session.
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
/// Central Drift database for RepTrack.
///
/// All tables and queries for exercises, programs, workout days, and logged
/// sets live here. Register as a permanent GetX singleton via [Get.put].
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

  /// Inserts [entry] or updates its [muscleGroup] if the name already exists.
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

  /// Returns all programs ordered by insertion.
  Future<List<Program>> getAllPrograms() => select(programs).get();

  /// Emits the full program list whenever a program is added, renamed, or deleted.
  Stream<List<Program>> watchAllPrograms() => select(programs).watch();

  /// Inserts a new program with the given [name] and returns its id.
  Future<int> addProgram(String name) =>
      into(programs).insert(ProgramsCompanion(name: Value(name)));

  /// Permanently deletes the program with [id], its workout days, and their
  /// program exercises. Logged [Workouts] and [WorkoutSets] are preserved.
  Future<void> deleteProgram(int id) async {
    await transaction(() async {
      final days = await (select(
        workoutDays,
      )..where((d) => d.programId.equals(id))).get();

      if (days.isNotEmpty) {
        final dayIds = days.map((d) => d.id).toList();
        await (delete(
          programExercise,
        )..where((pe) => pe.workoutDayId.isIn(dayIds))).go();
      }

      await (delete(workoutDays)..where((d) => d.programId.equals(id))).go();
      await (delete(programs)..where((p) => p.id.equals(id))).go();
    });
  }

  /// Updates the name of program [id].
  Future<void> renameProgram(int id, String name) =>
      (update(programs)..where((tbl) => tbl.id.equals(id))).write(
        ProgramsCompanion(name: Value(name)),
      );

  /// Updates the name of workout day [id].
  Future<void> renameWorkoutDay(int id, String name) =>
      (update(workoutDays)..where((tbl) => tbl.id.equals(id))).write(
        WorkoutDaysCompanion(dayName: Value(name)),
      );

  /// Returns all exercises in the library.
  Future<List<Exercise>> getAllExercises() => select(exercises).get();

  /// Finds an exercise by [name] using a case-insensitive match, or null.
  Future<Exercise?> getExerciseByName(String name) => (select(
    exercises,
  )..where((e) => e.name.lower().equals(name.toLowerCase()))).getSingleOrNull();

  /// Inserts a new exercise and returns its id.
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

  /// Permanently deletes the exercise with [id].
  Future<int> deleteExercise(int id) =>
      (delete(exercises)..where((tbl) => tbl.id.equals(id))).go();

  /// Updates an exercise's name, muscle group, note, and equipment associations
  /// in a single transaction.
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

  /// Updates only the note field of exercise [exerciseId].
  Future<void> updateExerciseNote(int exerciseId, String? note) {
    return (update(exercises)..where((tbl) => tbl.id.equals(exerciseId))).write(
      ExercisesCompanion(note: Value(note)),
    );
  }

  /// Returns all workout days for [programId], unordered.
  Future<List<WorkoutDay>> getWorkoutDaysForProgram(int programId) {
    return (select(
      workoutDays,
    )..where((tbl) => tbl.programId.equals(programId))).get();
  }

  /// Adds a new workout day named [dayName] to program [programId].
  Future<int> addWorkoutDay(int programId, String dayName) {
    return into(workoutDays).insert(
      WorkoutDaysCompanion(
        programId: Value(programId),
        dayName: Value(dayName),
      ),
    );
  }

  /// Deletes workout day [id] and cascades to its exercises.
  Future<int> deleteWorkoutDay(int id) =>
      (delete(workoutDays)..where((tbl) => tbl.id.equals(id))).go();

  /// Returns the raw program exercise rows for [workoutDayId].
  Future<List<ProgramExerciseData>> getExercisesForDay(int workoutDayId) {
    return (select(
      programExercise,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
  }

  /// Removes exercise [exerciseId] from workout day [dayId].
  Future<void> deleteExerciseFromWorkoutDay(int dayId, int exerciseId) async {
    await (delete(programExercise)..where(
          (tbl) =>
              tbl.workoutDayId.equals(dayId) &
              tbl.exerciseId.equals(exerciseId),
        ))
        .go();
  }

  /// Appends an exercise to a workout day, appending it after existing entries.
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

  /// Persists the display order of [programExerciseIds] (index = sort order).
  Future<void> reorderExercisesInDay(List<int> programExerciseIds) async {
    await transaction(() async {
      for (int i = 0; i < programExerciseIds.length; i++) {
        await (update(programExercise)
              ..where((tbl) => tbl.id.equals(programExerciseIds[i])))
            .write(ProgramExerciseCompanion(orderInProgram: Value(i)));
      }
    });
  }

  /// Persists the display order of [workoutDayIds] (index = sort order).
  Future<void> reorderDays(List<int> workoutDayIds) async {
    await transaction(() async {
      for (int i = 0; i < workoutDayIds.length; i++) {
        await (update(workoutDays)
              ..where((tbl) => tbl.id.equals(workoutDayIds[i])))
            .write(WorkoutDaysCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// Applies [companion] fields to the program exercise row with [id].
  Future<int> updateProgramExercise(
    ProgramExerciseCompanion companion,
    int id,
  ) {
    return (update(
      programExercise,
    )..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  /// Deletes the program exercise row with [id].
  Future<int> deleteProgramExercise(int id) =>
      (delete(programExercise)..where((tbl) => tbl.id.equals(id))).go();

  /// Returns the lowercased names of secondary muscle groups for [exerciseIds].
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

  /// Returns the most recently logged set for [exerciseId], or null.
  Future<WorkoutSet?> getLastSetForExercise(int exerciseId) {
    return (select(workoutSets)
          ..where((tbl) => tbl.exerciseId.equals(exerciseId))
          ..orderBy([
            (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Returns the equipment variants supported by [exerciseId].
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

  /// Returns the equipment row for [equipmentId], or null if not found.
  Future<Equipment?> getEquipmentById(int equipmentId) {
    return (select(
      equipments,
    )..where((tbl) => tbl.id.equals(equipmentId))).getSingleOrNull();
  }

  /// Deletes a specific set identified by [workoutId], [exerciseId], and [setNumber].
  Future<void> deleteWorkoutSet(int workoutId, int exerciseId, int setNumber) {
    return (delete(workoutSets)..where(
          (tbl) =>
              tbl.workoutId.equals(workoutId) &
              tbl.exerciseId.equals(exerciseId) &
              tbl.setNumber.equals(setNumber),
        ))
        .go();
  }

  /// Returns all completed sets for [exerciseId], newest first.
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

  /// Emits the ordered list of workout days with their exercises for [programId].
  ///
  /// Reacts to any change in [WorkoutDays] or [ProgramExercise] via Drift
  /// streams combined with [switchMap].
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
