import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

const _uuid = Uuid();

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
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text().unique()();
  TextColumn get note => text().nullable()();
  TextColumn get exerciseTypeId =>
      text().nullable().references(ExerciseTypes, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Lookup table for exercise categories (e.g. Strength, Cardio).
class ExerciseTypes extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Lookup table for muscle groups used to tag exercises.
class MuscleGroups extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Lookup table for equipment types (e.g. Barbell, Dumbbells).
class Equipments extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text().unique()();
  TextColumn get iconName => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Join table linking exercises to the equipment variants they support.
class ExerciseEquipment extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get equipmentId => text().references(Equipments, #id)();

  @override
  Set<Column> get primaryKey => {exerciseId, equipmentId};
}

/// Join table mapping exercises to muscle groups with a primary/secondary focus.
class ExerciseMuscleGroup extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get muscleGroupId => text().references(MuscleGroups, #id)();
  TextColumn get focus => text()();

  @override
  Set<Column> get primaryKey => {exerciseId, muscleGroupId};
}

/// A user-created training program (e.g. "Push Pull Legs").
class Programs extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A named training day belonging to a [Programs] entry (e.g. "Push Day").
class WorkoutDays extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get programId =>
      text().references(Programs, #id, onDelete: KeyAction.cascade)();
  TextColumn get dayName => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A strength exercise entry within a workout day.
class ProgramStrengthExercises extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get workoutDayId =>
      text().references(WorkoutDays, #id, onDelete: KeyAction.cascade)();
  TextColumn get equipmentId => text().nullable().references(
    Equipments,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderInProgram => integer().withDefault(const Constant(0))();
  // JSON list of reps per set, e.g. "[12,10,8]"
  TextColumn get setsReps => text().withDefault(const Constant('[12]'))();
  IntColumn get restTimer => integer().nullable()();
  RealColumn get weight => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A cardio exercise entry within a workout day.
class ProgramCardioExercises extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get workoutDayId =>
      text().references(WorkoutDays, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderInProgram => integer().withDefault(const Constant(0))();
  IntColumn get seconds => integer().nullable()();
  RealColumn get distancePlanned => real().nullable()();
  TextColumn get distancePlannedUnit =>
      text().withDefault(const Constant('km'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A hybrid exercise entry within a workout day, combining weight and distance.
class ProgramHybridExercises extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get workoutDayId =>
      text().references(WorkoutDays, #id, onDelete: KeyAction.cascade)();
  TextColumn get equipmentId => text().nullable().references(
    Equipments,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderInProgram => integer().withDefault(const Constant(0))();
  // JSON list of planned distances per set, e.g. "[100.0, 200.0, 400.0]"
  TextColumn get setsDistances =>
      text().withDefault(const Constant('[100.0]'))();
  TextColumn get distanceUnit => text().withDefault(const Constant('m'))();
  IntColumn get restTimer => integer().nullable()();
  RealColumn get weight => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A bodyweight log entry recorded by the user on a given date.
class BodyweightEntries extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A logged workout session tied to a specific [WorkoutDays] entry.
class Workouts extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get workoutDayId => text().references(WorkoutDays, #id)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// An individual strength set logged during a workout session.
class WorkoutStrengthSets extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get workoutId =>
      text().references(Workouts, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get equipmentId => text().nullable().references(Equipments, #id)();
  IntColumn get reps => integer()();
  RealColumn get weight => real()();
  IntColumn get setNumber => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
  DateTimeColumn get dateLogged => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// A cardio session logged during a workout (e.g. running, cycling).
class WorkoutCardioSets extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get workoutId =>
      text().references(Workouts, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get durationSeconds => integer()();
  RealColumn get distanceMeters => real().nullable()();
  TextColumn get distanceUnit => text().withDefault(const Constant('km'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
  DateTimeColumn get dateLogged => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// An individual hybrid set logged during a workout (weight + distance).
class WorkoutHybridSets extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get workoutId =>
      text().references(Workouts, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get equipmentId => text().nullable().references(Equipments, #id)();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real()();
  RealColumn get distance => real()();
  TextColumn get distanceUnit => text().withDefault(const Constant('m'))();
  RealColumn get distanceMeters => real().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
  DateTimeColumn get dateLogged => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
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
    ProgramStrengthExercises,
    ProgramCardioExercises,
    ProgramHybridExercises,
    Workouts,
    WorkoutStrengthSets,
    WorkoutCardioSets,
    WorkoutHybridSets,
    BodyweightEntries,
  ],
)
/// Central Drift database for RepTrack.
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Opens an in-memory database. Use this in tests only.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ── Programs ──────────────────────────────────────────────────────────────

  Future<List<Program>> getAllPrograms() => select(programs).get();

  Stream<List<Program>> watchAllPrograms() => select(programs).watch();

  Future<String> addProgram(String name) async {
    final id = _uuid.v4();
    await into(
      programs,
    ).insert(ProgramsCompanion(id: Value(id), name: Value(name)));
    return id;
  }

  Future<void> deleteProgram(String id) async {
    await transaction(() async {
      final days = await (select(
        workoutDays,
      )..where((d) => d.programId.equals(id))).get();

      if (days.isNotEmpty) {
        final dayIds = days.map((d) => d.id).toList();
        await (delete(
          programStrengthExercises,
        )..where((pe) => pe.workoutDayId.isIn(dayIds))).go();
        await (delete(
          programCardioExercises,
        )..where((pe) => pe.workoutDayId.isIn(dayIds))).go();
        await (delete(
          programHybridExercises,
        )..where((pe) => pe.workoutDayId.isIn(dayIds))).go();
      }

      await (delete(workoutDays)..where((d) => d.programId.equals(id))).go();
      await (delete(programs)..where((p) => p.id.equals(id))).go();
    });
  }

  Future<void> renameProgram(String id, String name) =>
      (update(programs)..where((tbl) => tbl.id.equals(id))).write(
        ProgramsCompanion(name: Value(name)),
      );

  // ── Workout days ─────────────────────────────────────────────────────────

  Future<void> renameWorkoutDay(String id, String name) =>
      (update(workoutDays)..where((tbl) => tbl.id.equals(id))).write(
        WorkoutDaysCompanion(dayName: Value(name)),
      );

  Future<List<WorkoutDay>> getWorkoutDaysForProgram(String programId) =>
      (select(
        workoutDays,
      )..where((tbl) => tbl.programId.equals(programId))).get();

  Stream<List<WorkoutDay>> watchWorkoutDaysForProgram(String programId) =>
      (select(workoutDays)
            ..where((tbl) => tbl.programId.equals(programId))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.sortOrder)]))
          .watch();

  Future<String> addWorkoutDay(String programId, String dayName) async {
    final id = _uuid.v4();
    await into(workoutDays).insert(
      WorkoutDaysCompanion(
        id: Value(id),
        programId: Value(programId),
        dayName: Value(dayName),
      ),
    );
    return id;
  }

  Future<int> deleteWorkoutDay(String id) =>
      (delete(workoutDays)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> reorderDays(List<String> workoutDayIds) async {
    await transaction(() async {
      for (int i = 0; i < workoutDayIds.length; i++) {
        await (update(workoutDays)
              ..where((tbl) => tbl.id.equals(workoutDayIds[i])))
            .write(WorkoutDaysCompanion(sortOrder: Value(i)));
      }
    });
  }

  // ── Program exercises ─────────────────────────────────────────────────────

  Future<String> addStrengthExerciseToDay({
    required String workoutDayId,
    required String exerciseId,
    String? equipmentId,
    required List<int> setsReps,
    int? restTimer,
    double weight = 0.0,
  }) async {
    final id = _uuid.v4();
    final existing = await (select(
      programStrengthExercises,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
    final cardioCount = await (select(
      programCardioExercises,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
    await into(programStrengthExercises).insert(
      ProgramStrengthExercisesCompanion(
        id: Value(id),
        workoutDayId: Value(workoutDayId),
        exerciseId: Value(exerciseId),
        equipmentId: Value(equipmentId),
        orderInProgram: Value(existing.length + cardioCount.length),
        setsReps: Value(jsonEncode(setsReps)),
        restTimer: Value(restTimer),
        weight: Value(weight),
      ),
    );
    return id;
  }

  Future<String> addCardioExerciseToDay({
    required String workoutDayId,
    required String exerciseId,
    int? seconds,
    double? distancePlanned,
    String distancePlannedUnit = 'km',
  }) async {
    final id = _uuid.v4();
    final strengthCount = await (select(
      programStrengthExercises,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
    final cardioCount = await (select(
      programCardioExercises,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
    await into(programCardioExercises).insert(
      ProgramCardioExercisesCompanion(
        id: Value(id),
        workoutDayId: Value(workoutDayId),
        exerciseId: Value(exerciseId),
        orderInProgram: Value(strengthCount.length + cardioCount.length),
        seconds: Value(seconds),
        distancePlanned: Value(distancePlanned),
        distancePlannedUnit: Value(distancePlannedUnit),
      ),
    );
    return id;
  }

  Future<int> deleteProgramStrengthExercise(String id) => (delete(
    programStrengthExercises,
  )..where((tbl) => tbl.id.equals(id))).go();

  Future<int> deleteProgramCardioExercise(String id) =>
      (delete(programCardioExercises)..where((tbl) => tbl.id.equals(id))).go();

  Future<int> updateProgramStrengthExercise(
    ProgramStrengthExercisesCompanion companion,
    String id,
  ) => (update(
    programStrengthExercises,
  )..where((tbl) => tbl.id.equals(id))).write(companion);

  Future<int> updateProgramCardioExercise(
    ProgramCardioExercisesCompanion companion,
    String id,
  ) => (update(
    programCardioExercises,
  )..where((tbl) => tbl.id.equals(id))).write(companion);

  /// Inserts a new hybrid exercise entry into [programHybridExercises].
  Future<String> addHybridExerciseToDay({
    required String workoutDayId,
    required String exerciseId,
    String? equipmentId,
    List<double> setsDistances = const [100.0],
    String distanceUnit = 'm',
    int? restTimer,
    double weight = 0.0,
  }) async {
    final id = _uuid.v4();
    final strengthCount = await (select(
      programStrengthExercises,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
    final cardioCount = await (select(
      programCardioExercises,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
    final hybridCount = await (select(
      programHybridExercises,
    )..where((tbl) => tbl.workoutDayId.equals(workoutDayId))).get();
    await into(programHybridExercises).insert(
      ProgramHybridExercisesCompanion(
        id: Value(id),
        workoutDayId: Value(workoutDayId),
        exerciseId: Value(exerciseId),
        equipmentId: Value(equipmentId),
        orderInProgram: Value(
          strengthCount.length + cardioCount.length + hybridCount.length,
        ),
        setsDistances: Value(jsonEncode(setsDistances)),
        distanceUnit: Value(distanceUnit),
        restTimer: Value(restTimer),
        weight: Value(weight),
      ),
    );
    return id;
  }

  /// Deletes a hybrid program exercise by its [id].
  Future<int> deleteProgramHybridExercise(String id) =>
      (delete(programHybridExercises)..where((tbl) => tbl.id.equals(id))).go();

  /// Updates a hybrid program exercise identified by [id] with [companion].
  Future<int> updateProgramHybridExercise(
    ProgramHybridExercisesCompanion companion,
    String id,
  ) => (update(
    programHybridExercises,
  )..where((tbl) => tbl.id.equals(id))).write(companion);

  Future<void> reorderExercisesInDay(
    List<ProgramExerciseVolume> volumes,
  ) async {
    await transaction(() async {
      for (int i = 0; i < volumes.length; i++) {
        final vol = volumes[i];
        if (vol.isCardio) {
          await (update(programCardioExercises)
                ..where((tbl) => tbl.id.equals(vol.id)))
              .write(ProgramCardioExercisesCompanion(orderInProgram: Value(i)));
        } else if (vol.isHybrid) {
          await (update(programHybridExercises)
                ..where((tbl) => tbl.id.equals(vol.id)))
              .write(ProgramHybridExercisesCompanion(orderInProgram: Value(i)));
        } else {
          await (update(
            programStrengthExercises,
          )..where((tbl) => tbl.id.equals(vol.id))).write(
            ProgramStrengthExercisesCompanion(orderInProgram: Value(i)),
          );
        }
      }
    });
  }

  // ── Exercises ─────────────────────────────────────────────────────────────

  Future<int> upsertExercise(ExercisesCompanion entry) =>
      into(exercises).insertOnConflictUpdate(entry);

  Future<List<Exercise>> getAllExercises() => select(exercises).get();

  Future<Exercise?> getExerciseByName(String name) => (select(
    exercises,
  )..where((e) => e.name.lower().equals(name.toLowerCase()))).getSingleOrNull();

  Future<String> addExercise(
    String name, {
    String? muscleGroupName,
    String? comment,
  }) async {
    final id = _uuid.v4();
    await into(exercises).insert(
      ExercisesCompanion(
        id: Value(id),
        name: Value(name),
        note: Value(comment),
      ),
    );
    if (muscleGroupName != null && muscleGroupName.isNotEmpty) {
      final group =
          await (select(muscleGroups)..where(
                (g) => g.name.lower().equals(muscleGroupName.toLowerCase()),
              ))
              .getSingleOrNull();
      if (group != null) {
        await into(exerciseMuscleGroup).insertOnConflictUpdate(
          ExerciseMuscleGroupCompanion.insert(
            exerciseId: id,
            muscleGroupId: group.id,
            focus: 'primary',
          ),
        );
      }
    }
    return id;
  }

  Future<int> deleteExercise(String id) =>
      (delete(exercises)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> updateExerciseDetails(
    String id,
    String name,
    String? muscleGroupName,
    String? note,
    Set<String> equipmentIds,
    String? exerciseTypeId,
  ) async {
    await transaction(() async {
      await (update(exercises)..where((e) => e.id.equals(id))).write(
        ExercisesCompanion(
          name: Value(name),
          note: Value(note),
          exerciseTypeId: Value(exerciseTypeId),
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
      await (delete(exerciseMuscleGroup)
            ..where((m) => m.exerciseId.equals(id) & m.focus.equals('primary')))
          .go();
      if (muscleGroupName != null && muscleGroupName.isNotEmpty) {
        final group =
            await (select(muscleGroups)..where(
                  (g) => g.name.lower().equals(muscleGroupName.toLowerCase()),
                ))
                .getSingleOrNull();
        if (group != null) {
          await into(exerciseMuscleGroup).insert(
            ExerciseMuscleGroupCompanion.insert(
              exerciseId: id,
              muscleGroupId: group.id,
              focus: 'primary',
            ),
          );
        }
      }
    });
  }

  Future<void> updateExerciseNote(String exerciseId, String? note) =>
      (update(exercises)..where((tbl) => tbl.id.equals(exerciseId))).write(
        ExercisesCompanion(note: Value(note)),
      );

  Future<String?> getPrimaryMuscleGroupForExercise(String exerciseId) async {
    final query =
        select(exerciseMuscleGroup).join([
          innerJoin(
            muscleGroups,
            muscleGroups.id.equalsExp(exerciseMuscleGroup.muscleGroupId),
          ),
        ])..where(
          exerciseMuscleGroup.exerciseId.equals(exerciseId) &
              exerciseMuscleGroup.focus.equals('primary'),
        );
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return rows.first.readTable(muscleGroups).name;
  }

  Future<Set<String>> getPrimaryMuscleGroupsForExercises(
    List<String> exerciseIds,
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
              exerciseMuscleGroup.focus.equals('primary'),
        );
    final rows = await query.get();
    return rows
        .map((r) => r.readTable(muscleGroups).name.toLowerCase())
        .toSet();
  }

  Future<Set<String>> getSecondaryMuscleGroupsForExercises(
    List<String> exerciseIds,
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

  Future<Map<String, String>> getAllPrimaryMuscleGroups() async {
    final query = select(exerciseMuscleGroup).join([
      innerJoin(
        muscleGroups,
        muscleGroups.id.equalsExp(exerciseMuscleGroup.muscleGroupId),
      ),
    ])..where(exerciseMuscleGroup.focus.equals('primary'));
    final rows = await query.get();
    return {
      for (final row in rows)
        row.readTable(exerciseMuscleGroup).exerciseId: row
            .readTable(muscleGroups)
            .name,
    };
  }

  Future<List<Equipment>> getEquipmentForExercise(String exerciseId) async {
    final query = select(equipments).join([
      innerJoin(
        exerciseEquipment,
        exerciseEquipment.equipmentId.equalsExp(equipments.id),
      ),
    ])..where(exerciseEquipment.exerciseId.equals(exerciseId));
    return (await query.get()).map((row) => row.readTable(equipments)).toList();
  }

  Future<Equipment?> getEquipmentById(String equipmentId) => (select(
    equipments,
  )..where((tbl) => tbl.id.equals(equipmentId))).getSingleOrNull();

  // ── Workout sets ──────────────────────────────────────────────────────────

  Future<void> deleteWorkoutStrengthSet(
    String workoutId,
    String exerciseId,
    int setNumber,
  ) =>
      (delete(workoutStrengthSets)..where(
            (tbl) =>
                tbl.workoutId.equals(workoutId) &
                tbl.exerciseId.equals(exerciseId) &
                tbl.setNumber.equals(setNumber),
          ))
          .go();

  Future<WorkoutStrengthSet?> getLastStrengthSetForExercise(
    String exerciseId,
  ) =>
      (select(workoutStrengthSets)
            ..where((tbl) => tbl.exerciseId.equals(exerciseId))
            ..orderBy([
              (u) => OrderingTerm(
                expression: u.dateLogged,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<List<WorkoutStrengthSet>> getStrengthSetsForExercise(
    String exerciseId,
  ) =>
      (select(workoutStrengthSets)
            ..where(
              (tbl) =>
                  tbl.exerciseId.equals(exerciseId) &
                  tbl.isCompleted.equals(true),
            )
            ..orderBy([
              (u) => OrderingTerm(
                expression: u.dateLogged,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Future<List<WorkoutCardioSet>> getCardioSetsForExercise(String exerciseId) =>
      (select(workoutCardioSets)
            ..where(
              (tbl) =>
                  tbl.exerciseId.equals(exerciseId) &
                  tbl.isCompleted.equals(true),
            )
            ..orderBy([
              (u) => OrderingTerm(
                expression: u.dateLogged,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Future<WorkoutCardioSet?> getLastCardioSetForExercise(String exerciseId) =>
      (select(workoutCardioSets)
            ..where((tbl) => tbl.exerciseId.equals(exerciseId))
            ..orderBy([
              (u) => OrderingTerm(
                expression: u.dateLogged,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  /// Returns all completed hybrid sets for [exerciseId], newest first.
  Future<List<WorkoutHybridSet>> getHybridSetsForExercise(String exerciseId) =>
      (select(workoutHybridSets)
            ..where(
              (tbl) =>
                  tbl.exerciseId.equals(exerciseId) &
                  tbl.isCompleted.equals(true),
            )
            ..orderBy([
              (u) => OrderingTerm(
                expression: u.dateLogged,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Returns the most recent hybrid set logged for [exerciseId], or null.
  Future<WorkoutHybridSet?> getLastHybridSetForExercise(String exerciseId) =>
      (select(workoutHybridSets)
            ..where((tbl) => tbl.exerciseId.equals(exerciseId))
            ..orderBy([
              (u) => OrderingTerm(
                expression: u.dateLogged,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  // ── Bodyweight ────────────────────────────────────────────────────────────

  Future<void> addBodyweightEntry(DateTime date, double weight) =>
      into(bodyweightEntries).insert(
        BodyweightEntriesCompanion(date: Value(date), weight: Value(weight)),
      );

  Future<void> deleteBodyweightEntry(String id) =>
      (delete(bodyweightEntries)..where((t) => t.id.equals(id))).go();

  Stream<List<BodyweightEntry>> watchBodyweightEntries() => (select(
    bodyweightEntries,
  )..orderBy([(t) => OrderingTerm(expression: t.date)])).watch();

  // ── Streams ───────────────────────────────────────────────────────────────

  Stream<List<WorkoutDayWithExercises>> watchWorkoutDaysWithExercises(
    String programId,
  ) {
    final dayStream =
        (select(workoutDays)
              ..where((d) => d.programId.equals(programId))
              ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
            .watch();

    return dayStream.switchMap((days) {
      if (days.isEmpty) return Stream.value(<WorkoutDayWithExercises>[]);
      final dayIds = days.map((d) => d.id).toList();

      final strengthQuery = select(programStrengthExercises).join([
        leftOuterJoin(
          exercises,
          exercises.id.equalsExp(programStrengthExercises.exerciseId),
        ),
        leftOuterJoin(
          equipments,
          equipments.id.equalsExp(programStrengthExercises.equipmentId),
        ),
        leftOuterJoin(
          exerciseMuscleGroup,
          exerciseMuscleGroup.exerciseId.equalsExp(
                programStrengthExercises.exerciseId,
              ) &
              exerciseMuscleGroup.focus.equals('primary'),
        ),
        leftOuterJoin(
          muscleGroups,
          muscleGroups.id.equalsExp(exerciseMuscleGroup.muscleGroupId),
        ),
      ])..where(programStrengthExercises.workoutDayId.isIn(dayIds));

      final cardioQuery = select(programCardioExercises).join([
        leftOuterJoin(
          exercises,
          exercises.id.equalsExp(programCardioExercises.exerciseId),
        ),
        leftOuterJoin(
          exerciseMuscleGroup,
          exerciseMuscleGroup.exerciseId.equalsExp(
                programCardioExercises.exerciseId,
              ) &
              exerciseMuscleGroup.focus.equals('primary'),
        ),
        leftOuterJoin(
          muscleGroups,
          muscleGroups.id.equalsExp(exerciseMuscleGroup.muscleGroupId),
        ),
      ])..where(programCardioExercises.workoutDayId.isIn(dayIds));

      final hybridQuery = select(programHybridExercises).join([
        leftOuterJoin(
          exercises,
          exercises.id.equalsExp(programHybridExercises.exerciseId),
        ),
        leftOuterJoin(
          equipments,
          equipments.id.equalsExp(programHybridExercises.equipmentId),
        ),
        leftOuterJoin(
          exerciseMuscleGroup,
          exerciseMuscleGroup.exerciseId.equalsExp(
                programHybridExercises.exerciseId,
              ) &
              exerciseMuscleGroup.focus.equals('primary'),
        ),
        leftOuterJoin(
          muscleGroups,
          muscleGroups.id.equalsExp(exerciseMuscleGroup.muscleGroupId),
        ),
      ])..where(programHybridExercises.workoutDayId.isIn(dayIds));

      return CombineLatestStream.combine3(
        strengthQuery.watch(),
        cardioQuery.watch(),
        hybridQuery.watch(),
        (strengthRows, cardioRows, hybridRows) {
          final resultMap = <String, List<ExerciseWithVolume>>{};

          for (final row in strengthRows) {
            final exercise = row.readTableOrNull(exercises);
            final volume = row.readTableOrNull(programStrengthExercises);
            final equipment = row.readTableOrNull(equipments);
            final muscleGroupRow = row.readTableOrNull(muscleGroups);
            if (exercise != null && volume != null) {
              resultMap
                  .putIfAbsent(volume.workoutDayId, () => [])
                  .add(
                    ExerciseWithVolume(
                      exercise: exercise,
                      volume: ProgramExerciseVolume.strength(volume),
                      equipment: equipment,
                      primaryMuscleGroup: muscleGroupRow?.name,
                    ),
                  );
            }
          }

          for (final row in cardioRows) {
            final exercise = row.readTableOrNull(exercises);
            final volume = row.readTableOrNull(programCardioExercises);
            final muscleGroupRow = row.readTableOrNull(muscleGroups);
            if (exercise != null && volume != null) {
              resultMap
                  .putIfAbsent(volume.workoutDayId, () => [])
                  .add(
                    ExerciseWithVolume(
                      exercise: exercise,
                      volume: ProgramExerciseVolume.cardio(volume),
                      equipment: null,
                      primaryMuscleGroup: muscleGroupRow?.name,
                    ),
                  );
            }
          }

          for (final row in hybridRows) {
            final exercise = row.readTableOrNull(exercises);
            final volume = row.readTableOrNull(programHybridExercises);
            final equipment = row.readTableOrNull(equipments);
            final muscleGroupRow = row.readTableOrNull(muscleGroups);
            if (exercise != null && volume != null) {
              resultMap
                  .putIfAbsent(volume.workoutDayId, () => [])
                  .add(
                    ExerciseWithVolume(
                      exercise: exercise,
                      volume: ProgramExerciseVolume.hybrid(volume),
                      equipment: equipment,
                      primaryMuscleGroup: muscleGroupRow?.name,
                    ),
                  );
            }
          }

          for (final list in resultMap.values) {
            list.sort(
              (a, b) =>
                  a.volume.orderInProgram.compareTo(b.volume.orderInProgram),
            );
          }

          return days
              .map(
                (day) => WorkoutDayWithExercises(
                  workoutDay: day,
                  exercises: resultMap[day.id] ?? [],
                ),
              )
              .toList();
        },
      );
    });
  }
}
