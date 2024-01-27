// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Exercise extends _Exercise
    with RealmEntity, RealmObjectBase, RealmObject {
  Exercise(
    String? name, {
    String? description,
    String? muscles,
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'muscles', muscles);
  }

  Exercise._();

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get muscles =>
      RealmObjectBase.get<String>(this, 'muscles') as String?;
  @override
  set muscles(String? value) => RealmObjectBase.set(this, 'muscles', value);

  @override
  Stream<RealmObjectChanges<Exercise>> get changes =>
      RealmObjectBase.getChanges<Exercise>(this);

  @override
  Exercise freeze() => RealmObjectBase.freezeObject<Exercise>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Exercise._);
    return const SchemaObject(ObjectType.realmObject, Exercise, 'Exercise', [
      SchemaProperty('name', RealmPropertyType.string,
          optional: true, primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('muscles', RealmPropertyType.string, optional: true),
    ]);
  }
}

class WorkoutExercise extends _WorkoutExercise
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  WorkoutExercise(
    ObjectId workoutExerciseId, {
    Exercise? exercise,
    int sets = 0,
    int? timer,
    Iterable<int> repsPerSet = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<WorkoutExercise>({
        'sets': 0,
      });
    }
    RealmObjectBase.set(this, '_id', workoutExerciseId);
    RealmObjectBase.set(this, 'exercise', exercise);
    RealmObjectBase.set(this, 'sets', sets);
    RealmObjectBase.set(this, 'timer', timer);
    RealmObjectBase.set<RealmList<int>>(
        this, 'repsPerSet', RealmList<int>(repsPerSet));
  }

  WorkoutExercise._();

  @override
  ObjectId get workoutExerciseId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set workoutExerciseId(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  Exercise? get exercise =>
      RealmObjectBase.get<Exercise>(this, 'exercise') as Exercise?;
  @override
  set exercise(covariant Exercise? value) =>
      RealmObjectBase.set(this, 'exercise', value);

  @override
  int get sets => RealmObjectBase.get<int>(this, 'sets') as int;
  @override
  set sets(int value) => RealmObjectBase.set(this, 'sets', value);

  @override
  RealmList<int> get repsPerSet =>
      RealmObjectBase.get<int>(this, 'repsPerSet') as RealmList<int>;
  @override
  set repsPerSet(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  int? get timer => RealmObjectBase.get<int>(this, 'timer') as int?;
  @override
  set timer(int? value) => RealmObjectBase.set(this, 'timer', value);

  @override
  Stream<RealmObjectChanges<WorkoutExercise>> get changes =>
      RealmObjectBase.getChanges<WorkoutExercise>(this);

  @override
  WorkoutExercise freeze() =>
      RealmObjectBase.freezeObject<WorkoutExercise>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(WorkoutExercise._);
    return const SchemaObject(
        ObjectType.realmObject, WorkoutExercise, 'WorkoutExercise', [
      SchemaProperty('workoutExerciseId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('exercise', RealmPropertyType.object,
          optional: true, linkTarget: 'Exercise'),
      SchemaProperty('sets', RealmPropertyType.int),
      SchemaProperty('repsPerSet', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('timer', RealmPropertyType.int, optional: true),
    ]);
  }
}

class Workout extends _Workout with RealmEntity, RealmObjectBase, RealmObject {
  Workout(
    ObjectId workoutId,
    int day, {
    Iterable<WorkoutExercise> exercises = const [],
  }) {
    RealmObjectBase.set(this, '_id', workoutId);
    RealmObjectBase.set(this, 'day', day);
    RealmObjectBase.set<RealmList<WorkoutExercise>>(
        this, 'exercises', RealmList<WorkoutExercise>(exercises));
  }

  Workout._();

  @override
  ObjectId get workoutId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set workoutId(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  int get day => RealmObjectBase.get<int>(this, 'day') as int;
  @override
  set day(int value) => throw RealmUnsupportedSetError();

  @override
  RealmList<WorkoutExercise> get exercises =>
      RealmObjectBase.get<WorkoutExercise>(this, 'exercises')
          as RealmList<WorkoutExercise>;
  @override
  set exercises(covariant RealmList<WorkoutExercise> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Workout>> get changes =>
      RealmObjectBase.getChanges<Workout>(this);

  @override
  Workout freeze() => RealmObjectBase.freezeObject<Workout>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Workout._);
    return const SchemaObject(ObjectType.realmObject, Workout, 'Workout', [
      SchemaProperty('workoutId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('day', RealmPropertyType.int),
      SchemaProperty('exercises', RealmPropertyType.object,
          linkTarget: 'WorkoutExercise',
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class SessionExercise extends _SessionExercise
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SessionExercise({
    Exercise? exercise,
    int sets = 2,
    String? comment,
    Iterable<int> repsPerSet = const [],
    Iterable<int> weightPerSetKg = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SessionExercise>({
        'sets': 2,
      });
    }
    RealmObjectBase.set(this, 'exercise', exercise);
    RealmObjectBase.set(this, 'sets', sets);
    RealmObjectBase.set(this, 'comment', comment);
    RealmObjectBase.set<RealmList<int>>(
        this, 'repsPerSet', RealmList<int>(repsPerSet));
    RealmObjectBase.set<RealmList<int>>(
        this, 'weightPerSetKg', RealmList<int>(weightPerSetKg));
  }

  SessionExercise._();

  @override
  Exercise? get exercise =>
      RealmObjectBase.get<Exercise>(this, 'exercise') as Exercise?;
  @override
  set exercise(covariant Exercise? value) =>
      RealmObjectBase.set(this, 'exercise', value);

  @override
  int get sets => RealmObjectBase.get<int>(this, 'sets') as int;
  @override
  set sets(int value) => RealmObjectBase.set(this, 'sets', value);

  @override
  RealmList<int> get repsPerSet =>
      RealmObjectBase.get<int>(this, 'repsPerSet') as RealmList<int>;
  @override
  set repsPerSet(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get weightPerSetKg =>
      RealmObjectBase.get<int>(this, 'weightPerSetKg') as RealmList<int>;
  @override
  set weightPerSetKg(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  String? get comment =>
      RealmObjectBase.get<String>(this, 'comment') as String?;
  @override
  set comment(String? value) => RealmObjectBase.set(this, 'comment', value);

  @override
  Stream<RealmObjectChanges<SessionExercise>> get changes =>
      RealmObjectBase.getChanges<SessionExercise>(this);

  @override
  SessionExercise freeze() =>
      RealmObjectBase.freezeObject<SessionExercise>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(SessionExercise._);
    return const SchemaObject(
        ObjectType.realmObject, SessionExercise, 'SessionExercise', [
      SchemaProperty('exercise', RealmPropertyType.object,
          optional: true, linkTarget: 'Exercise'),
      SchemaProperty('sets', RealmPropertyType.int),
      SchemaProperty('repsPerSet', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('weightPerSetKg', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('comment', RealmPropertyType.string, optional: true),
    ]);
  }
}

class TrainingSession extends _TrainingSession
    with RealmEntity, RealmObjectBase, RealmObject {
  TrainingSession(
    ObjectId sessionId, {
    DateTime? dateStarted,
    DateTime? dateEnded,
    Iterable<SessionExercise> exercises = const [],
  }) {
    RealmObjectBase.set(this, '_id', sessionId);
    RealmObjectBase.set(this, 'dateStarted', dateStarted);
    RealmObjectBase.set(this, 'dateEnded', dateEnded);
    RealmObjectBase.set<RealmList<SessionExercise>>(
        this, 'exercises', RealmList<SessionExercise>(exercises));
  }

  TrainingSession._();

  @override
  ObjectId get sessionId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set sessionId(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  DateTime? get dateStarted =>
      RealmObjectBase.get<DateTime>(this, 'dateStarted') as DateTime?;
  @override
  set dateStarted(DateTime? value) =>
      RealmObjectBase.set(this, 'dateStarted', value);

  @override
  DateTime? get dateEnded =>
      RealmObjectBase.get<DateTime>(this, 'dateEnded') as DateTime?;
  @override
  set dateEnded(DateTime? value) =>
      RealmObjectBase.set(this, 'dateEnded', value);

  @override
  RealmList<SessionExercise> get exercises =>
      RealmObjectBase.get<SessionExercise>(this, 'exercises')
          as RealmList<SessionExercise>;
  @override
  set exercises(covariant RealmList<SessionExercise> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<TrainingSession>> get changes =>
      RealmObjectBase.getChanges<TrainingSession>(this);

  @override
  TrainingSession freeze() =>
      RealmObjectBase.freezeObject<TrainingSession>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TrainingSession._);
    return const SchemaObject(
        ObjectType.realmObject, TrainingSession, 'TrainingSession', [
      SchemaProperty('sessionId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('dateStarted', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('dateEnded', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('exercises', RealmPropertyType.object,
          linkTarget: 'SessionExercise',
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class WorkoutSchedule extends _WorkoutSchedule
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  WorkoutSchedule(
    ObjectId scheduleId, {
    String name = "Push Pull Legs",
    int numWeeks = 0,
    int startingWeightKg = 0,
    int finishWeightKg = 0,
    DateTime? dateStarted,
    Workout? activeWorkout,
    Iterable<TrainingSession> sessions = const [],
    Iterable<Workout> workouts = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<WorkoutSchedule>({
        'name': "Push Pull Legs",
        'numWeeks': 0,
        'startingWeightKg': 0,
        'finishWeightKg': 0,
      });
    }
    RealmObjectBase.set(this, '_id', scheduleId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'numWeeks', numWeeks);
    RealmObjectBase.set(this, 'startingWeightKg', startingWeightKg);
    RealmObjectBase.set(this, 'finishWeightKg', finishWeightKg);
    RealmObjectBase.set(this, 'dateStarted', dateStarted);
    RealmObjectBase.set(this, 'activeWorkout', activeWorkout);
    RealmObjectBase.set<RealmList<TrainingSession>>(
        this, 'sessions', RealmList<TrainingSession>(sessions));
    RealmObjectBase.set<RealmList<Workout>>(
        this, 'workouts', RealmList<Workout>(workouts));
  }

  WorkoutSchedule._();

  @override
  ObjectId get scheduleId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set scheduleId(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get numWeeks => RealmObjectBase.get<int>(this, 'numWeeks') as int;
  @override
  set numWeeks(int value) => RealmObjectBase.set(this, 'numWeeks', value);

  @override
  int get startingWeightKg =>
      RealmObjectBase.get<int>(this, 'startingWeightKg') as int;
  @override
  set startingWeightKg(int value) =>
      RealmObjectBase.set(this, 'startingWeightKg', value);

  @override
  int get finishWeightKg =>
      RealmObjectBase.get<int>(this, 'finishWeightKg') as int;
  @override
  set finishWeightKg(int value) =>
      RealmObjectBase.set(this, 'finishWeightKg', value);

  @override
  DateTime? get dateStarted =>
      RealmObjectBase.get<DateTime>(this, 'dateStarted') as DateTime?;
  @override
  set dateStarted(DateTime? value) =>
      RealmObjectBase.set(this, 'dateStarted', value);

  @override
  RealmList<TrainingSession> get sessions =>
      RealmObjectBase.get<TrainingSession>(this, 'sessions')
          as RealmList<TrainingSession>;
  @override
  set sessions(covariant RealmList<TrainingSession> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Workout> get workouts =>
      RealmObjectBase.get<Workout>(this, 'workouts') as RealmList<Workout>;
  @override
  set workouts(covariant RealmList<Workout> value) =>
      throw RealmUnsupportedSetError();

  @override
  Workout? get activeWorkout =>
      RealmObjectBase.get<Workout>(this, 'activeWorkout') as Workout?;
  @override
  set activeWorkout(covariant Workout? value) =>
      RealmObjectBase.set(this, 'activeWorkout', value);

  @override
  Stream<RealmObjectChanges<WorkoutSchedule>> get changes =>
      RealmObjectBase.getChanges<WorkoutSchedule>(this);

  @override
  WorkoutSchedule freeze() =>
      RealmObjectBase.freezeObject<WorkoutSchedule>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(WorkoutSchedule._);
    return const SchemaObject(
        ObjectType.realmObject, WorkoutSchedule, 'WorkoutSchedule', [
      SchemaProperty('scheduleId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('numWeeks', RealmPropertyType.int),
      SchemaProperty('startingWeightKg', RealmPropertyType.int),
      SchemaProperty('finishWeightKg', RealmPropertyType.int),
      SchemaProperty('dateStarted', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('sessions', RealmPropertyType.object,
          linkTarget: 'TrainingSession',
          collectionType: RealmCollectionType.list),
      SchemaProperty('workouts', RealmPropertyType.object,
          linkTarget: 'Workout', collectionType: RealmCollectionType.list),
      SchemaProperty('activeWorkout', RealmPropertyType.object,
          optional: true, linkTarget: 'Workout'),
    ]);
  }
}

class User extends _User with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  User(
    ObjectId userId, {
    String name = "Jurriaan",
    WorkoutSchedule? activeSchedule,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<User>({
        'name': "Jurriaan",
      });
    }
    RealmObjectBase.set(this, '_id', userId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'activeSchedule', activeSchedule);
  }

  User._();

  @override
  ObjectId get userId => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set userId(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  @override
  WorkoutSchedule? get activeSchedule =>
      RealmObjectBase.get<WorkoutSchedule>(this, 'activeSchedule')
          as WorkoutSchedule?;
  @override
  set activeSchedule(covariant WorkoutSchedule? value) =>
      RealmObjectBase.set(this, 'activeSchedule', value);

  @override
  Stream<RealmObjectChanges<User>> get changes =>
      RealmObjectBase.getChanges<User>(this);

  @override
  User freeze() => RealmObjectBase.freezeObject<User>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(User._);
    return const SchemaObject(ObjectType.realmObject, User, 'User', [
      SchemaProperty('userId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('activeSchedule', RealmPropertyType.object,
          optional: true, linkTarget: 'WorkoutSchedule'),
    ]);
  }
}

class BodyWeightLog extends _BodyWeightLog
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  BodyWeightLog({
    int bodyWeight = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<BodyWeightLog>({
        'bodyWeight': 0,
      });
    }
    RealmObjectBase.set(this, 'bodyWeight', bodyWeight);
  }

  BodyWeightLog._();

  @override
  int get bodyWeight => RealmObjectBase.get<int>(this, 'bodyWeight') as int;
  @override
  set bodyWeight(int value) => RealmObjectBase.set(this, 'bodyWeight', value);

  @override
  Stream<RealmObjectChanges<BodyWeightLog>> get changes =>
      RealmObjectBase.getChanges<BodyWeightLog>(this);

  @override
  BodyWeightLog freeze() => RealmObjectBase.freezeObject<BodyWeightLog>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(BodyWeightLog._);
    return const SchemaObject(
        ObjectType.realmObject, BodyWeightLog, 'BodyWeightLog', [
      SchemaProperty('bodyWeight', RealmPropertyType.int),
    ]);
  }
}
