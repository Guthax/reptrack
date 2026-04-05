// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExerciseTypesTable extends ExerciseTypes
    with TableInfo<$ExerciseTypesTable, ExerciseType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ExerciseTypesTable createAlias(String alias) {
    return $ExerciseTypesTable(attachedDatabase, alias);
  }
}

class ExerciseType extends DataClass implements Insertable<ExerciseType> {
  final String id;
  final String name;
  const ExerciseType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ExerciseTypesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseTypesCompanion(id: Value(id), name: Value(name));
  }

  factory ExerciseType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseType(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  ExerciseType copyWith({String? id, String? name}) =>
      ExerciseType(id: id ?? this.id, name: name ?? this.name);
  ExerciseType copyWithCompanion(ExerciseTypesCompanion data) {
    return ExerciseType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseType(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseType && other.id == this.id && other.name == this.name);
}

class ExerciseTypesCompanion extends UpdateCompanion<ExerciseType> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const ExerciseTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ExerciseType> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ExerciseTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseTypeIdMeta = const VerificationMeta(
    'exerciseTypeId',
  );
  @override
  late final GeneratedColumn<String> exerciseTypeId = GeneratedColumn<String>(
    'exercise_type_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_types (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, note, exerciseTypeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('exercise_type_id')) {
      context.handle(
        _exerciseTypeIdMeta,
        exerciseTypeId.isAcceptableOrUnknown(
          data['exercise_type_id']!,
          _exerciseTypeIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      exerciseTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_type_id'],
      ),
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String id;
  final String name;
  final String? note;
  final String? exerciseTypeId;
  const Exercise({
    required this.id,
    required this.name,
    this.note,
    this.exerciseTypeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || exerciseTypeId != null) {
      map['exercise_type_id'] = Variable<String>(exerciseTypeId);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      exerciseTypeId: exerciseTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseTypeId),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
      exerciseTypeId: serializer.fromJson<String?>(json['exerciseTypeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String?>(note),
      'exerciseTypeId': serializer.toJson<String?>(exerciseTypeId),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    Value<String?> note = const Value.absent(),
    Value<String?> exerciseTypeId = const Value.absent(),
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
    exerciseTypeId: exerciseTypeId.present
        ? exerciseTypeId.value
        : this.exerciseTypeId,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      exerciseTypeId: data.exerciseTypeId.present
          ? data.exerciseTypeId.value
          : this.exerciseTypeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('exerciseTypeId: $exerciseTypeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, note, exerciseTypeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note &&
          other.exerciseTypeId == this.exerciseTypeId);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> note;
  final Value<String?> exerciseTypeId;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.exerciseTypeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.note = const Value.absent(),
    this.exerciseTypeId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? note,
    Expression<String>? exerciseTypeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (exerciseTypeId != null) 'exercise_type_id': exerciseTypeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? note,
    Value<String?>? exerciseTypeId,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      exerciseTypeId: exerciseTypeId ?? this.exerciseTypeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (exerciseTypeId.present) {
      map['exercise_type_id'] = Variable<String>(exerciseTypeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('exerciseTypeId: $exerciseTypeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EquipmentsTable extends Equipments
    with TableInfo<$EquipmentsTable, Equipment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, iconName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Equipment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Equipment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Equipment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
    );
  }

  @override
  $EquipmentsTable createAlias(String alias) {
    return $EquipmentsTable(attachedDatabase, alias);
  }
}

class Equipment extends DataClass implements Insertable<Equipment> {
  final String id;
  final String name;
  final String iconName;
  const Equipment({
    required this.id,
    required this.name,
    required this.iconName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    return map;
  }

  EquipmentsCompanion toCompanion(bool nullToAbsent) {
    return EquipmentsCompanion(
      id: Value(id),
      name: Value(name),
      iconName: Value(iconName),
    );
  }

  factory Equipment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Equipment(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
    };
  }

  Equipment copyWith({String? id, String? name, String? iconName}) => Equipment(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
  );
  Equipment copyWithCompanion(EquipmentsCompanion data) {
    return Equipment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Equipment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Equipment &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName);
}

class EquipmentsCompanion extends UpdateCompanion<Equipment> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconName;
  final Value<int> rowid;
  const EquipmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EquipmentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String iconName,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       iconName = Value(iconName);
  static Insertable<Equipment> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EquipmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconName,
    Value<int>? rowid,
  }) {
    return EquipmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MuscleGroupsTable extends MuscleGroups
    with TableInfo<$MuscleGroupsTable, MuscleGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuscleGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muscle_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<MuscleGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MuscleGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MuscleGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $MuscleGroupsTable createAlias(String alias) {
    return $MuscleGroupsTable(attachedDatabase, alias);
  }
}

class MuscleGroup extends DataClass implements Insertable<MuscleGroup> {
  final String id;
  final String name;
  const MuscleGroup({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  MuscleGroupsCompanion toCompanion(bool nullToAbsent) {
    return MuscleGroupsCompanion(id: Value(id), name: Value(name));
  }

  factory MuscleGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MuscleGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  MuscleGroup copyWith({String? id, String? name}) =>
      MuscleGroup(id: id ?? this.id, name: name ?? this.name);
  MuscleGroup copyWithCompanion(MuscleGroupsCompanion data) {
    return MuscleGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroup(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MuscleGroup && other.id == this.id && other.name == this.name);
}

class MuscleGroupsCompanion extends UpdateCompanion<MuscleGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const MuscleGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MuscleGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MuscleGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MuscleGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return MuscleGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMuscleGroupTable extends ExerciseMuscleGroup
    with TableInfo<$ExerciseMuscleGroupTable, ExerciseMuscleGroupData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMuscleGroupTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _muscleGroupIdMeta = const VerificationMeta(
    'muscleGroupId',
  );
  @override
  late final GeneratedColumn<String> muscleGroupId = GeneratedColumn<String>(
    'muscle_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES muscle_groups (id)',
    ),
  );
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<String> focus = GeneratedColumn<String>(
    'focus',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscleGroupId, focus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_muscle_group';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMuscleGroupData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle_group_id')) {
      context.handle(
        _muscleGroupIdMeta,
        muscleGroupId.isAcceptableOrUnknown(
          data['muscle_group_id']!,
          _muscleGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupIdMeta);
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    } else if (isInserting) {
      context.missing(_focusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscleGroupId};
  @override
  ExerciseMuscleGroupData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscleGroupData(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      muscleGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group_id'],
      )!,
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus'],
      )!,
    );
  }

  @override
  $ExerciseMuscleGroupTable createAlias(String alias) {
    return $ExerciseMuscleGroupTable(attachedDatabase, alias);
  }
}

class ExerciseMuscleGroupData extends DataClass
    implements Insertable<ExerciseMuscleGroupData> {
  final String exerciseId;
  final String muscleGroupId;
  final String focus;
  const ExerciseMuscleGroupData({
    required this.exerciseId,
    required this.muscleGroupId,
    required this.focus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['muscle_group_id'] = Variable<String>(muscleGroupId);
    map['focus'] = Variable<String>(focus);
    return map;
  }

  ExerciseMuscleGroupCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMuscleGroupCompanion(
      exerciseId: Value(exerciseId),
      muscleGroupId: Value(muscleGroupId),
      focus: Value(focus),
    );
  }

  factory ExerciseMuscleGroupData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscleGroupData(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      muscleGroupId: serializer.fromJson<String>(json['muscleGroupId']),
      focus: serializer.fromJson<String>(json['focus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'muscleGroupId': serializer.toJson<String>(muscleGroupId),
      'focus': serializer.toJson<String>(focus),
    };
  }

  ExerciseMuscleGroupData copyWith({
    String? exerciseId,
    String? muscleGroupId,
    String? focus,
  }) => ExerciseMuscleGroupData(
    exerciseId: exerciseId ?? this.exerciseId,
    muscleGroupId: muscleGroupId ?? this.muscleGroupId,
    focus: focus ?? this.focus,
  );
  ExerciseMuscleGroupData copyWithCompanion(ExerciseMuscleGroupCompanion data) {
    return ExerciseMuscleGroupData(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      muscleGroupId: data.muscleGroupId.present
          ? data.muscleGroupId.value
          : this.muscleGroupId,
      focus: data.focus.present ? data.focus.value : this.focus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscleGroupData(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleGroupId: $muscleGroupId, ')
          ..write('focus: $focus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscleGroupId, focus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMuscleGroupData &&
          other.exerciseId == this.exerciseId &&
          other.muscleGroupId == this.muscleGroupId &&
          other.focus == this.focus);
}

class ExerciseMuscleGroupCompanion
    extends UpdateCompanion<ExerciseMuscleGroupData> {
  final Value<String> exerciseId;
  final Value<String> muscleGroupId;
  final Value<String> focus;
  final Value<int> rowid;
  const ExerciseMuscleGroupCompanion({
    this.exerciseId = const Value.absent(),
    this.muscleGroupId = const Value.absent(),
    this.focus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMuscleGroupCompanion.insert({
    required String exerciseId,
    required String muscleGroupId,
    required String focus,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       muscleGroupId = Value(muscleGroupId),
       focus = Value(focus);
  static Insertable<ExerciseMuscleGroupData> custom({
    Expression<String>? exerciseId,
    Expression<String>? muscleGroupId,
    Expression<String>? focus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscleGroupId != null) 'muscle_group_id': muscleGroupId,
      if (focus != null) 'focus': focus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMuscleGroupCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? muscleGroupId,
    Value<String>? focus,
    Value<int>? rowid,
  }) {
    return ExerciseMuscleGroupCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      focus: focus ?? this.focus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (muscleGroupId.present) {
      map['muscle_group_id'] = Variable<String>(muscleGroupId.value);
    }
    if (focus.present) {
      map['focus'] = Variable<String>(focus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscleGroupCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleGroupId: $muscleGroupId, ')
          ..write('focus: $focus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseEquipmentTable extends ExerciseEquipment
    with TableInfo<$ExerciseEquipmentTable, ExerciseEquipmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseEquipmentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<String> equipmentId = GeneratedColumn<String>(
    'equipment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipments (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, equipmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseEquipmentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipment_id']!,
          _equipmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, equipmentId};
  @override
  ExerciseEquipmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseEquipmentData(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      equipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_id'],
      )!,
    );
  }

  @override
  $ExerciseEquipmentTable createAlias(String alias) {
    return $ExerciseEquipmentTable(attachedDatabase, alias);
  }
}

class ExerciseEquipmentData extends DataClass
    implements Insertable<ExerciseEquipmentData> {
  final String exerciseId;
  final String equipmentId;
  const ExerciseEquipmentData({
    required this.exerciseId,
    required this.equipmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['equipment_id'] = Variable<String>(equipmentId);
    return map;
  }

  ExerciseEquipmentCompanion toCompanion(bool nullToAbsent) {
    return ExerciseEquipmentCompanion(
      exerciseId: Value(exerciseId),
      equipmentId: Value(equipmentId),
    );
  }

  factory ExerciseEquipmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseEquipmentData(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      equipmentId: serializer.fromJson<String>(json['equipmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'equipmentId': serializer.toJson<String>(equipmentId),
    };
  }

  ExerciseEquipmentData copyWith({String? exerciseId, String? equipmentId}) =>
      ExerciseEquipmentData(
        exerciseId: exerciseId ?? this.exerciseId,
        equipmentId: equipmentId ?? this.equipmentId,
      );
  ExerciseEquipmentData copyWithCompanion(ExerciseEquipmentCompanion data) {
    return ExerciseEquipmentData(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      equipmentId: data.equipmentId.present
          ? data.equipmentId.value
          : this.equipmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEquipmentData(')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, equipmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseEquipmentData &&
          other.exerciseId == this.exerciseId &&
          other.equipmentId == this.equipmentId);
}

class ExerciseEquipmentCompanion
    extends UpdateCompanion<ExerciseEquipmentData> {
  final Value<String> exerciseId;
  final Value<String> equipmentId;
  final Value<int> rowid;
  const ExerciseEquipmentCompanion({
    this.exerciseId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseEquipmentCompanion.insert({
    required String exerciseId,
    required String equipmentId,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       equipmentId = Value(equipmentId);
  static Insertable<ExerciseEquipmentData> custom({
    Expression<String>? exerciseId,
    Expression<String>? equipmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseEquipmentCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? equipmentId,
    Value<int>? rowid,
  }) {
    return ExerciseEquipmentCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      equipmentId: equipmentId ?? this.equipmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<String>(equipmentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEquipmentCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramsTable extends Programs with TableInfo<$ProgramsTable, Program> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Program> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Program map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Program(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ProgramsTable createAlias(String alias) {
    return $ProgramsTable(attachedDatabase, alias);
  }
}

class Program extends DataClass implements Insertable<Program> {
  final String id;
  final String name;
  const Program({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ProgramsCompanion toCompanion(bool nullToAbsent) {
    return ProgramsCompanion(id: Value(id), name: Value(name));
  }

  factory Program.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Program(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Program copyWith({String? id, String? name}) =>
      Program(id: id ?? this.id, name: name ?? this.name);
  Program copyWithCompanion(ProgramsCompanion data) {
    return Program(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Program(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Program && other.id == this.id && other.name == this.name);
}

class ProgramsCompanion extends UpdateCompanion<Program> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const ProgramsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Program> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ProgramsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutDaysTable extends WorkoutDays
    with TableInfo<$WorkoutDaysTable, WorkoutDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES programs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dayNameMeta = const VerificationMeta(
    'dayName',
  );
  @override
  late final GeneratedColumn<String> dayName = GeneratedColumn<String>(
    'day_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, programId, dayName, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('day_name')) {
      context.handle(
        _dayNameMeta,
        dayName.isAcceptableOrUnknown(data['day_name']!, _dayNameMeta),
      );
    } else if (isInserting) {
      context.missing(_dayNameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_id'],
      )!,
      dayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WorkoutDaysTable createAlias(String alias) {
    return $WorkoutDaysTable(attachedDatabase, alias);
  }
}

class WorkoutDay extends DataClass implements Insertable<WorkoutDay> {
  final String id;
  final String programId;
  final String dayName;
  final int sortOrder;
  const WorkoutDay({
    required this.id,
    required this.programId,
    required this.dayName,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['program_id'] = Variable<String>(programId);
    map['day_name'] = Variable<String>(dayName);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WorkoutDaysCompanion toCompanion(bool nullToAbsent) {
    return WorkoutDaysCompanion(
      id: Value(id),
      programId: Value(programId),
      dayName: Value(dayName),
      sortOrder: Value(sortOrder),
    );
  }

  factory WorkoutDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutDay(
      id: serializer.fromJson<String>(json['id']),
      programId: serializer.fromJson<String>(json['programId']),
      dayName: serializer.fromJson<String>(json['dayName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'programId': serializer.toJson<String>(programId),
      'dayName': serializer.toJson<String>(dayName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WorkoutDay copyWith({
    String? id,
    String? programId,
    String? dayName,
    int? sortOrder,
  }) => WorkoutDay(
    id: id ?? this.id,
    programId: programId ?? this.programId,
    dayName: dayName ?? this.dayName,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WorkoutDay copyWithCompanion(WorkoutDaysCompanion data) {
    return WorkoutDay(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      dayName: data.dayName.present ? data.dayName.value : this.dayName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutDay(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('dayName: $dayName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, programId, dayName, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutDay &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.dayName == this.dayName &&
          other.sortOrder == this.sortOrder);
}

class WorkoutDaysCompanion extends UpdateCompanion<WorkoutDay> {
  final Value<String> id;
  final Value<String> programId;
  final Value<String> dayName;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const WorkoutDaysCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.dayName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutDaysCompanion.insert({
    this.id = const Value.absent(),
    required String programId,
    required String dayName,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : programId = Value(programId),
       dayName = Value(dayName);
  static Insertable<WorkoutDay> custom({
    Expression<String>? id,
    Expression<String>? programId,
    Expression<String>? dayName,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (dayName != null) 'day_name': dayName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutDaysCompanion copyWith({
    Value<String>? id,
    Value<String>? programId,
    Value<String>? dayName,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return WorkoutDaysCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      dayName: dayName ?? this.dayName,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (dayName.present) {
      map['day_name'] = Variable<String>(dayName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutDaysCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('dayName: $dayName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramStrengthExercisesTable extends ProgramStrengthExercises
    with TableInfo<$ProgramStrengthExercisesTable, ProgramStrengthExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramStrengthExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _workoutDayIdMeta = const VerificationMeta(
    'workoutDayId',
  );
  @override
  late final GeneratedColumn<String> workoutDayId = GeneratedColumn<String>(
    'workout_day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<String> equipmentId = GeneratedColumn<String>(
    'equipment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _orderInProgramMeta = const VerificationMeta(
    'orderInProgram',
  );
  @override
  late final GeneratedColumn<int> orderInProgram = GeneratedColumn<int>(
    'order_in_program',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _setsRepsMeta = const VerificationMeta(
    'setsReps',
  );
  @override
  late final GeneratedColumn<String> setsReps = GeneratedColumn<String>(
    'sets_reps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[12]'),
  );
  static const VerificationMeta _restTimerMeta = const VerificationMeta(
    'restTimer',
  );
  @override
  late final GeneratedColumn<int> restTimer = GeneratedColumn<int>(
    'rest_timer',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutDayId,
    equipmentId,
    exerciseId,
    orderInProgram,
    setsReps,
    restTimer,
    weight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_strength_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramStrengthExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_day_id')) {
      context.handle(
        _workoutDayIdMeta,
        workoutDayId.isAcceptableOrUnknown(
          data['workout_day_id']!,
          _workoutDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutDayIdMeta);
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipment_id']!,
          _equipmentIdMeta,
        ),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_in_program')) {
      context.handle(
        _orderInProgramMeta,
        orderInProgram.isAcceptableOrUnknown(
          data['order_in_program']!,
          _orderInProgramMeta,
        ),
      );
    }
    if (data.containsKey('sets_reps')) {
      context.handle(
        _setsRepsMeta,
        setsReps.isAcceptableOrUnknown(data['sets_reps']!, _setsRepsMeta),
      );
    }
    if (data.containsKey('rest_timer')) {
      context.handle(
        _restTimerMeta,
        restTimer.isAcceptableOrUnknown(data['rest_timer']!, _restTimerMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramStrengthExercise map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramStrengthExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_day_id'],
      )!,
      equipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_id'],
      ),
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      orderInProgram: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_in_program'],
      )!,
      setsReps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sets_reps'],
      )!,
      restTimer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_timer'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
    );
  }

  @override
  $ProgramStrengthExercisesTable createAlias(String alias) {
    return $ProgramStrengthExercisesTable(attachedDatabase, alias);
  }
}

class ProgramStrengthExercise extends DataClass
    implements Insertable<ProgramStrengthExercise> {
  final String id;
  final String workoutDayId;
  final String? equipmentId;
  final String exerciseId;
  final int orderInProgram;
  final String setsReps;
  final int? restTimer;
  final double weight;
  const ProgramStrengthExercise({
    required this.id,
    required this.workoutDayId,
    this.equipmentId,
    required this.exerciseId,
    required this.orderInProgram,
    required this.setsReps,
    this.restTimer,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_day_id'] = Variable<String>(workoutDayId);
    if (!nullToAbsent || equipmentId != null) {
      map['equipment_id'] = Variable<String>(equipmentId);
    }
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_in_program'] = Variable<int>(orderInProgram);
    map['sets_reps'] = Variable<String>(setsReps);
    if (!nullToAbsent || restTimer != null) {
      map['rest_timer'] = Variable<int>(restTimer);
    }
    map['weight'] = Variable<double>(weight);
    return map;
  }

  ProgramStrengthExercisesCompanion toCompanion(bool nullToAbsent) {
    return ProgramStrengthExercisesCompanion(
      id: Value(id),
      workoutDayId: Value(workoutDayId),
      equipmentId: equipmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentId),
      exerciseId: Value(exerciseId),
      orderInProgram: Value(orderInProgram),
      setsReps: Value(setsReps),
      restTimer: restTimer == null && nullToAbsent
          ? const Value.absent()
          : Value(restTimer),
      weight: Value(weight),
    );
  }

  factory ProgramStrengthExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramStrengthExercise(
      id: serializer.fromJson<String>(json['id']),
      workoutDayId: serializer.fromJson<String>(json['workoutDayId']),
      equipmentId: serializer.fromJson<String?>(json['equipmentId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderInProgram: serializer.fromJson<int>(json['orderInProgram']),
      setsReps: serializer.fromJson<String>(json['setsReps']),
      restTimer: serializer.fromJson<int?>(json['restTimer']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutDayId': serializer.toJson<String>(workoutDayId),
      'equipmentId': serializer.toJson<String?>(equipmentId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderInProgram': serializer.toJson<int>(orderInProgram),
      'setsReps': serializer.toJson<String>(setsReps),
      'restTimer': serializer.toJson<int?>(restTimer),
      'weight': serializer.toJson<double>(weight),
    };
  }

  ProgramStrengthExercise copyWith({
    String? id,
    String? workoutDayId,
    Value<String?> equipmentId = const Value.absent(),
    String? exerciseId,
    int? orderInProgram,
    String? setsReps,
    Value<int?> restTimer = const Value.absent(),
    double? weight,
  }) => ProgramStrengthExercise(
    id: id ?? this.id,
    workoutDayId: workoutDayId ?? this.workoutDayId,
    equipmentId: equipmentId.present ? equipmentId.value : this.equipmentId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderInProgram: orderInProgram ?? this.orderInProgram,
    setsReps: setsReps ?? this.setsReps,
    restTimer: restTimer.present ? restTimer.value : this.restTimer,
    weight: weight ?? this.weight,
  );
  ProgramStrengthExercise copyWithCompanion(
    ProgramStrengthExercisesCompanion data,
  ) {
    return ProgramStrengthExercise(
      id: data.id.present ? data.id.value : this.id,
      workoutDayId: data.workoutDayId.present
          ? data.workoutDayId.value
          : this.workoutDayId,
      equipmentId: data.equipmentId.present
          ? data.equipmentId.value
          : this.equipmentId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      orderInProgram: data.orderInProgram.present
          ? data.orderInProgram.value
          : this.orderInProgram,
      setsReps: data.setsReps.present ? data.setsReps.value : this.setsReps,
      restTimer: data.restTimer.present ? data.restTimer.value : this.restTimer,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramStrengthExercise(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderInProgram: $orderInProgram, ')
          ..write('setsReps: $setsReps, ')
          ..write('restTimer: $restTimer, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutDayId,
    equipmentId,
    exerciseId,
    orderInProgram,
    setsReps,
    restTimer,
    weight,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramStrengthExercise &&
          other.id == this.id &&
          other.workoutDayId == this.workoutDayId &&
          other.equipmentId == this.equipmentId &&
          other.exerciseId == this.exerciseId &&
          other.orderInProgram == this.orderInProgram &&
          other.setsReps == this.setsReps &&
          other.restTimer == this.restTimer &&
          other.weight == this.weight);
}

class ProgramStrengthExercisesCompanion
    extends UpdateCompanion<ProgramStrengthExercise> {
  final Value<String> id;
  final Value<String> workoutDayId;
  final Value<String?> equipmentId;
  final Value<String> exerciseId;
  final Value<int> orderInProgram;
  final Value<String> setsReps;
  final Value<int?> restTimer;
  final Value<double> weight;
  final Value<int> rowid;
  const ProgramStrengthExercisesCompanion({
    this.id = const Value.absent(),
    this.workoutDayId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderInProgram = const Value.absent(),
    this.setsReps = const Value.absent(),
    this.restTimer = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramStrengthExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String workoutDayId,
    this.equipmentId = const Value.absent(),
    required String exerciseId,
    this.orderInProgram = const Value.absent(),
    this.setsReps = const Value.absent(),
    this.restTimer = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutDayId = Value(workoutDayId),
       exerciseId = Value(exerciseId);
  static Insertable<ProgramStrengthExercise> custom({
    Expression<String>? id,
    Expression<String>? workoutDayId,
    Expression<String>? equipmentId,
    Expression<String>? exerciseId,
    Expression<int>? orderInProgram,
    Expression<String>? setsReps,
    Expression<int>? restTimer,
    Expression<double>? weight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutDayId != null) 'workout_day_id': workoutDayId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderInProgram != null) 'order_in_program': orderInProgram,
      if (setsReps != null) 'sets_reps': setsReps,
      if (restTimer != null) 'rest_timer': restTimer,
      if (weight != null) 'weight': weight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramStrengthExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutDayId,
    Value<String?>? equipmentId,
    Value<String>? exerciseId,
    Value<int>? orderInProgram,
    Value<String>? setsReps,
    Value<int?>? restTimer,
    Value<double>? weight,
    Value<int>? rowid,
  }) {
    return ProgramStrengthExercisesCompanion(
      id: id ?? this.id,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      equipmentId: equipmentId ?? this.equipmentId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderInProgram: orderInProgram ?? this.orderInProgram,
      setsReps: setsReps ?? this.setsReps,
      restTimer: restTimer ?? this.restTimer,
      weight: weight ?? this.weight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutDayId.present) {
      map['workout_day_id'] = Variable<String>(workoutDayId.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<String>(equipmentId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderInProgram.present) {
      map['order_in_program'] = Variable<int>(orderInProgram.value);
    }
    if (setsReps.present) {
      map['sets_reps'] = Variable<String>(setsReps.value);
    }
    if (restTimer.present) {
      map['rest_timer'] = Variable<int>(restTimer.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramStrengthExercisesCompanion(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderInProgram: $orderInProgram, ')
          ..write('setsReps: $setsReps, ')
          ..write('restTimer: $restTimer, ')
          ..write('weight: $weight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramCardioExercisesTable extends ProgramCardioExercises
    with TableInfo<$ProgramCardioExercisesTable, ProgramCardioExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramCardioExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _workoutDayIdMeta = const VerificationMeta(
    'workoutDayId',
  );
  @override
  late final GeneratedColumn<String> workoutDayId = GeneratedColumn<String>(
    'workout_day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _orderInProgramMeta = const VerificationMeta(
    'orderInProgram',
  );
  @override
  late final GeneratedColumn<int> orderInProgram = GeneratedColumn<int>(
    'order_in_program',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta(
    'seconds',
  );
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distancePlannedMeta = const VerificationMeta(
    'distancePlanned',
  );
  @override
  late final GeneratedColumn<double> distancePlanned = GeneratedColumn<double>(
    'distance_planned',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distancePlannedUnitMeta =
      const VerificationMeta('distancePlannedUnit');
  @override
  late final GeneratedColumn<String> distancePlannedUnit =
      GeneratedColumn<String>(
        'distance_planned_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('km'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutDayId,
    exerciseId,
    orderInProgram,
    seconds,
    distancePlanned,
    distancePlannedUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_cardio_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramCardioExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_day_id')) {
      context.handle(
        _workoutDayIdMeta,
        workoutDayId.isAcceptableOrUnknown(
          data['workout_day_id']!,
          _workoutDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutDayIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_in_program')) {
      context.handle(
        _orderInProgramMeta,
        orderInProgram.isAcceptableOrUnknown(
          data['order_in_program']!,
          _orderInProgramMeta,
        ),
      );
    }
    if (data.containsKey('seconds')) {
      context.handle(
        _secondsMeta,
        seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta),
      );
    }
    if (data.containsKey('distance_planned')) {
      context.handle(
        _distancePlannedMeta,
        distancePlanned.isAcceptableOrUnknown(
          data['distance_planned']!,
          _distancePlannedMeta,
        ),
      );
    }
    if (data.containsKey('distance_planned_unit')) {
      context.handle(
        _distancePlannedUnitMeta,
        distancePlannedUnit.isAcceptableOrUnknown(
          data['distance_planned_unit']!,
          _distancePlannedUnitMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramCardioExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramCardioExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_day_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      orderInProgram: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_in_program'],
      )!,
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      ),
      distancePlanned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_planned'],
      ),
      distancePlannedUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_planned_unit'],
      )!,
    );
  }

  @override
  $ProgramCardioExercisesTable createAlias(String alias) {
    return $ProgramCardioExercisesTable(attachedDatabase, alias);
  }
}

class ProgramCardioExercise extends DataClass
    implements Insertable<ProgramCardioExercise> {
  final String id;
  final String workoutDayId;
  final String exerciseId;
  final int orderInProgram;
  final int? seconds;
  final double? distancePlanned;
  final String distancePlannedUnit;
  const ProgramCardioExercise({
    required this.id,
    required this.workoutDayId,
    required this.exerciseId,
    required this.orderInProgram,
    this.seconds,
    this.distancePlanned,
    required this.distancePlannedUnit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_day_id'] = Variable<String>(workoutDayId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_in_program'] = Variable<int>(orderInProgram);
    if (!nullToAbsent || seconds != null) {
      map['seconds'] = Variable<int>(seconds);
    }
    if (!nullToAbsent || distancePlanned != null) {
      map['distance_planned'] = Variable<double>(distancePlanned);
    }
    map['distance_planned_unit'] = Variable<String>(distancePlannedUnit);
    return map;
  }

  ProgramCardioExercisesCompanion toCompanion(bool nullToAbsent) {
    return ProgramCardioExercisesCompanion(
      id: Value(id),
      workoutDayId: Value(workoutDayId),
      exerciseId: Value(exerciseId),
      orderInProgram: Value(orderInProgram),
      seconds: seconds == null && nullToAbsent
          ? const Value.absent()
          : Value(seconds),
      distancePlanned: distancePlanned == null && nullToAbsent
          ? const Value.absent()
          : Value(distancePlanned),
      distancePlannedUnit: Value(distancePlannedUnit),
    );
  }

  factory ProgramCardioExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramCardioExercise(
      id: serializer.fromJson<String>(json['id']),
      workoutDayId: serializer.fromJson<String>(json['workoutDayId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderInProgram: serializer.fromJson<int>(json['orderInProgram']),
      seconds: serializer.fromJson<int?>(json['seconds']),
      distancePlanned: serializer.fromJson<double?>(json['distancePlanned']),
      distancePlannedUnit: serializer.fromJson<String>(
        json['distancePlannedUnit'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutDayId': serializer.toJson<String>(workoutDayId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderInProgram': serializer.toJson<int>(orderInProgram),
      'seconds': serializer.toJson<int?>(seconds),
      'distancePlanned': serializer.toJson<double?>(distancePlanned),
      'distancePlannedUnit': serializer.toJson<String>(distancePlannedUnit),
    };
  }

  ProgramCardioExercise copyWith({
    String? id,
    String? workoutDayId,
    String? exerciseId,
    int? orderInProgram,
    Value<int?> seconds = const Value.absent(),
    Value<double?> distancePlanned = const Value.absent(),
    String? distancePlannedUnit,
  }) => ProgramCardioExercise(
    id: id ?? this.id,
    workoutDayId: workoutDayId ?? this.workoutDayId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderInProgram: orderInProgram ?? this.orderInProgram,
    seconds: seconds.present ? seconds.value : this.seconds,
    distancePlanned: distancePlanned.present
        ? distancePlanned.value
        : this.distancePlanned,
    distancePlannedUnit: distancePlannedUnit ?? this.distancePlannedUnit,
  );
  ProgramCardioExercise copyWithCompanion(
    ProgramCardioExercisesCompanion data,
  ) {
    return ProgramCardioExercise(
      id: data.id.present ? data.id.value : this.id,
      workoutDayId: data.workoutDayId.present
          ? data.workoutDayId.value
          : this.workoutDayId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      orderInProgram: data.orderInProgram.present
          ? data.orderInProgram.value
          : this.orderInProgram,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
      distancePlanned: data.distancePlanned.present
          ? data.distancePlanned.value
          : this.distancePlanned,
      distancePlannedUnit: data.distancePlannedUnit.present
          ? data.distancePlannedUnit.value
          : this.distancePlannedUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramCardioExercise(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderInProgram: $orderInProgram, ')
          ..write('seconds: $seconds, ')
          ..write('distancePlanned: $distancePlanned, ')
          ..write('distancePlannedUnit: $distancePlannedUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutDayId,
    exerciseId,
    orderInProgram,
    seconds,
    distancePlanned,
    distancePlannedUnit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramCardioExercise &&
          other.id == this.id &&
          other.workoutDayId == this.workoutDayId &&
          other.exerciseId == this.exerciseId &&
          other.orderInProgram == this.orderInProgram &&
          other.seconds == this.seconds &&
          other.distancePlanned == this.distancePlanned &&
          other.distancePlannedUnit == this.distancePlannedUnit);
}

class ProgramCardioExercisesCompanion
    extends UpdateCompanion<ProgramCardioExercise> {
  final Value<String> id;
  final Value<String> workoutDayId;
  final Value<String> exerciseId;
  final Value<int> orderInProgram;
  final Value<int?> seconds;
  final Value<double?> distancePlanned;
  final Value<String> distancePlannedUnit;
  final Value<int> rowid;
  const ProgramCardioExercisesCompanion({
    this.id = const Value.absent(),
    this.workoutDayId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderInProgram = const Value.absent(),
    this.seconds = const Value.absent(),
    this.distancePlanned = const Value.absent(),
    this.distancePlannedUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramCardioExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String workoutDayId,
    required String exerciseId,
    this.orderInProgram = const Value.absent(),
    this.seconds = const Value.absent(),
    this.distancePlanned = const Value.absent(),
    this.distancePlannedUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutDayId = Value(workoutDayId),
       exerciseId = Value(exerciseId);
  static Insertable<ProgramCardioExercise> custom({
    Expression<String>? id,
    Expression<String>? workoutDayId,
    Expression<String>? exerciseId,
    Expression<int>? orderInProgram,
    Expression<int>? seconds,
    Expression<double>? distancePlanned,
    Expression<String>? distancePlannedUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutDayId != null) 'workout_day_id': workoutDayId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderInProgram != null) 'order_in_program': orderInProgram,
      if (seconds != null) 'seconds': seconds,
      if (distancePlanned != null) 'distance_planned': distancePlanned,
      if (distancePlannedUnit != null)
        'distance_planned_unit': distancePlannedUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramCardioExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutDayId,
    Value<String>? exerciseId,
    Value<int>? orderInProgram,
    Value<int?>? seconds,
    Value<double?>? distancePlanned,
    Value<String>? distancePlannedUnit,
    Value<int>? rowid,
  }) {
    return ProgramCardioExercisesCompanion(
      id: id ?? this.id,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderInProgram: orderInProgram ?? this.orderInProgram,
      seconds: seconds ?? this.seconds,
      distancePlanned: distancePlanned ?? this.distancePlanned,
      distancePlannedUnit: distancePlannedUnit ?? this.distancePlannedUnit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutDayId.present) {
      map['workout_day_id'] = Variable<String>(workoutDayId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderInProgram.present) {
      map['order_in_program'] = Variable<int>(orderInProgram.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (distancePlanned.present) {
      map['distance_planned'] = Variable<double>(distancePlanned.value);
    }
    if (distancePlannedUnit.present) {
      map['distance_planned_unit'] = Variable<String>(
        distancePlannedUnit.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramCardioExercisesCompanion(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderInProgram: $orderInProgram, ')
          ..write('seconds: $seconds, ')
          ..write('distancePlanned: $distancePlanned, ')
          ..write('distancePlannedUnit: $distancePlannedUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramHybridExercisesTable extends ProgramHybridExercises
    with TableInfo<$ProgramHybridExercisesTable, ProgramHybridExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramHybridExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _workoutDayIdMeta = const VerificationMeta(
    'workoutDayId',
  );
  @override
  late final GeneratedColumn<String> workoutDayId = GeneratedColumn<String>(
    'workout_day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<String> equipmentId = GeneratedColumn<String>(
    'equipment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _orderInProgramMeta = const VerificationMeta(
    'orderInProgram',
  );
  @override
  late final GeneratedColumn<int> orderInProgram = GeneratedColumn<int>(
    'order_in_program',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _setsDistancesMeta = const VerificationMeta(
    'setsDistances',
  );
  @override
  late final GeneratedColumn<String> setsDistances = GeneratedColumn<String>(
    'sets_distances',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[100.0]'),
  );
  static const VerificationMeta _distanceUnitMeta = const VerificationMeta(
    'distanceUnit',
  );
  @override
  late final GeneratedColumn<String> distanceUnit = GeneratedColumn<String>(
    'distance_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('m'),
  );
  static const VerificationMeta _restTimerMeta = const VerificationMeta(
    'restTimer',
  );
  @override
  late final GeneratedColumn<int> restTimer = GeneratedColumn<int>(
    'rest_timer',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutDayId,
    equipmentId,
    exerciseId,
    orderInProgram,
    setsDistances,
    distanceUnit,
    restTimer,
    weight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_hybrid_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramHybridExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_day_id')) {
      context.handle(
        _workoutDayIdMeta,
        workoutDayId.isAcceptableOrUnknown(
          data['workout_day_id']!,
          _workoutDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutDayIdMeta);
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipment_id']!,
          _equipmentIdMeta,
        ),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_in_program')) {
      context.handle(
        _orderInProgramMeta,
        orderInProgram.isAcceptableOrUnknown(
          data['order_in_program']!,
          _orderInProgramMeta,
        ),
      );
    }
    if (data.containsKey('sets_distances')) {
      context.handle(
        _setsDistancesMeta,
        setsDistances.isAcceptableOrUnknown(
          data['sets_distances']!,
          _setsDistancesMeta,
        ),
      );
    }
    if (data.containsKey('distance_unit')) {
      context.handle(
        _distanceUnitMeta,
        distanceUnit.isAcceptableOrUnknown(
          data['distance_unit']!,
          _distanceUnitMeta,
        ),
      );
    }
    if (data.containsKey('rest_timer')) {
      context.handle(
        _restTimerMeta,
        restTimer.isAcceptableOrUnknown(data['rest_timer']!, _restTimerMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramHybridExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramHybridExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_day_id'],
      )!,
      equipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_id'],
      ),
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      orderInProgram: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_in_program'],
      )!,
      setsDistances: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sets_distances'],
      )!,
      distanceUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_unit'],
      )!,
      restTimer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_timer'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
    );
  }

  @override
  $ProgramHybridExercisesTable createAlias(String alias) {
    return $ProgramHybridExercisesTable(attachedDatabase, alias);
  }
}

class ProgramHybridExercise extends DataClass
    implements Insertable<ProgramHybridExercise> {
  final String id;
  final String workoutDayId;
  final String? equipmentId;
  final String exerciseId;
  final int orderInProgram;
  final String setsDistances;
  final String distanceUnit;
  final int? restTimer;
  final double weight;
  const ProgramHybridExercise({
    required this.id,
    required this.workoutDayId,
    this.equipmentId,
    required this.exerciseId,
    required this.orderInProgram,
    required this.setsDistances,
    required this.distanceUnit,
    this.restTimer,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_day_id'] = Variable<String>(workoutDayId);
    if (!nullToAbsent || equipmentId != null) {
      map['equipment_id'] = Variable<String>(equipmentId);
    }
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_in_program'] = Variable<int>(orderInProgram);
    map['sets_distances'] = Variable<String>(setsDistances);
    map['distance_unit'] = Variable<String>(distanceUnit);
    if (!nullToAbsent || restTimer != null) {
      map['rest_timer'] = Variable<int>(restTimer);
    }
    map['weight'] = Variable<double>(weight);
    return map;
  }

  ProgramHybridExercisesCompanion toCompanion(bool nullToAbsent) {
    return ProgramHybridExercisesCompanion(
      id: Value(id),
      workoutDayId: Value(workoutDayId),
      equipmentId: equipmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentId),
      exerciseId: Value(exerciseId),
      orderInProgram: Value(orderInProgram),
      setsDistances: Value(setsDistances),
      distanceUnit: Value(distanceUnit),
      restTimer: restTimer == null && nullToAbsent
          ? const Value.absent()
          : Value(restTimer),
      weight: Value(weight),
    );
  }

  factory ProgramHybridExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramHybridExercise(
      id: serializer.fromJson<String>(json['id']),
      workoutDayId: serializer.fromJson<String>(json['workoutDayId']),
      equipmentId: serializer.fromJson<String?>(json['equipmentId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderInProgram: serializer.fromJson<int>(json['orderInProgram']),
      setsDistances: serializer.fromJson<String>(json['setsDistances']),
      distanceUnit: serializer.fromJson<String>(json['distanceUnit']),
      restTimer: serializer.fromJson<int?>(json['restTimer']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutDayId': serializer.toJson<String>(workoutDayId),
      'equipmentId': serializer.toJson<String?>(equipmentId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderInProgram': serializer.toJson<int>(orderInProgram),
      'setsDistances': serializer.toJson<String>(setsDistances),
      'distanceUnit': serializer.toJson<String>(distanceUnit),
      'restTimer': serializer.toJson<int?>(restTimer),
      'weight': serializer.toJson<double>(weight),
    };
  }

  ProgramHybridExercise copyWith({
    String? id,
    String? workoutDayId,
    Value<String?> equipmentId = const Value.absent(),
    String? exerciseId,
    int? orderInProgram,
    String? setsDistances,
    String? distanceUnit,
    Value<int?> restTimer = const Value.absent(),
    double? weight,
  }) => ProgramHybridExercise(
    id: id ?? this.id,
    workoutDayId: workoutDayId ?? this.workoutDayId,
    equipmentId: equipmentId.present ? equipmentId.value : this.equipmentId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderInProgram: orderInProgram ?? this.orderInProgram,
    setsDistances: setsDistances ?? this.setsDistances,
    distanceUnit: distanceUnit ?? this.distanceUnit,
    restTimer: restTimer.present ? restTimer.value : this.restTimer,
    weight: weight ?? this.weight,
  );
  ProgramHybridExercise copyWithCompanion(
    ProgramHybridExercisesCompanion data,
  ) {
    return ProgramHybridExercise(
      id: data.id.present ? data.id.value : this.id,
      workoutDayId: data.workoutDayId.present
          ? data.workoutDayId.value
          : this.workoutDayId,
      equipmentId: data.equipmentId.present
          ? data.equipmentId.value
          : this.equipmentId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      orderInProgram: data.orderInProgram.present
          ? data.orderInProgram.value
          : this.orderInProgram,
      setsDistances: data.setsDistances.present
          ? data.setsDistances.value
          : this.setsDistances,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      restTimer: data.restTimer.present ? data.restTimer.value : this.restTimer,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramHybridExercise(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderInProgram: $orderInProgram, ')
          ..write('setsDistances: $setsDistances, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('restTimer: $restTimer, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutDayId,
    equipmentId,
    exerciseId,
    orderInProgram,
    setsDistances,
    distanceUnit,
    restTimer,
    weight,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramHybridExercise &&
          other.id == this.id &&
          other.workoutDayId == this.workoutDayId &&
          other.equipmentId == this.equipmentId &&
          other.exerciseId == this.exerciseId &&
          other.orderInProgram == this.orderInProgram &&
          other.setsDistances == this.setsDistances &&
          other.distanceUnit == this.distanceUnit &&
          other.restTimer == this.restTimer &&
          other.weight == this.weight);
}

class ProgramHybridExercisesCompanion
    extends UpdateCompanion<ProgramHybridExercise> {
  final Value<String> id;
  final Value<String> workoutDayId;
  final Value<String?> equipmentId;
  final Value<String> exerciseId;
  final Value<int> orderInProgram;
  final Value<String> setsDistances;
  final Value<String> distanceUnit;
  final Value<int?> restTimer;
  final Value<double> weight;
  final Value<int> rowid;
  const ProgramHybridExercisesCompanion({
    this.id = const Value.absent(),
    this.workoutDayId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderInProgram = const Value.absent(),
    this.setsDistances = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.restTimer = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramHybridExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String workoutDayId,
    this.equipmentId = const Value.absent(),
    required String exerciseId,
    this.orderInProgram = const Value.absent(),
    this.setsDistances = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.restTimer = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutDayId = Value(workoutDayId),
       exerciseId = Value(exerciseId);
  static Insertable<ProgramHybridExercise> custom({
    Expression<String>? id,
    Expression<String>? workoutDayId,
    Expression<String>? equipmentId,
    Expression<String>? exerciseId,
    Expression<int>? orderInProgram,
    Expression<String>? setsDistances,
    Expression<String>? distanceUnit,
    Expression<int>? restTimer,
    Expression<double>? weight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutDayId != null) 'workout_day_id': workoutDayId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderInProgram != null) 'order_in_program': orderInProgram,
      if (setsDistances != null) 'sets_distances': setsDistances,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (restTimer != null) 'rest_timer': restTimer,
      if (weight != null) 'weight': weight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramHybridExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutDayId,
    Value<String?>? equipmentId,
    Value<String>? exerciseId,
    Value<int>? orderInProgram,
    Value<String>? setsDistances,
    Value<String>? distanceUnit,
    Value<int?>? restTimer,
    Value<double>? weight,
    Value<int>? rowid,
  }) {
    return ProgramHybridExercisesCompanion(
      id: id ?? this.id,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      equipmentId: equipmentId ?? this.equipmentId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderInProgram: orderInProgram ?? this.orderInProgram,
      setsDistances: setsDistances ?? this.setsDistances,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      restTimer: restTimer ?? this.restTimer,
      weight: weight ?? this.weight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutDayId.present) {
      map['workout_day_id'] = Variable<String>(workoutDayId.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<String>(equipmentId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderInProgram.present) {
      map['order_in_program'] = Variable<int>(orderInProgram.value);
    }
    if (setsDistances.present) {
      map['sets_distances'] = Variable<String>(setsDistances.value);
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(distanceUnit.value);
    }
    if (restTimer.present) {
      map['rest_timer'] = Variable<int>(restTimer.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramHybridExercisesCompanion(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderInProgram: $orderInProgram, ')
          ..write('setsDistances: $setsDistances, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('restTimer: $restTimer, ')
          ..write('weight: $weight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _workoutDayIdMeta = const VerificationMeta(
    'workoutDayId',
  );
  @override
  late final GeneratedColumn<String> workoutDayId = GeneratedColumn<String>(
    'workout_day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_days (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, workoutDayId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_day_id')) {
      context.handle(
        _workoutDayIdMeta,
        workoutDayId.isAcceptableOrUnknown(
          data['workout_day_id']!,
          _workoutDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutDayIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_day_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final String id;
  final String workoutDayId;
  final DateTime date;
  const Workout({
    required this.id,
    required this.workoutDayId,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_day_id'] = Variable<String>(workoutDayId);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      workoutDayId: Value(workoutDayId),
      date: Value(date),
    );
  }

  factory Workout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<String>(json['id']),
      workoutDayId: serializer.fromJson<String>(json['workoutDayId']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutDayId': serializer.toJson<String>(workoutDayId),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  Workout copyWith({String? id, String? workoutDayId, DateTime? date}) =>
      Workout(
        id: id ?? this.id,
        workoutDayId: workoutDayId ?? this.workoutDayId,
        date: date ?? this.date,
      );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      workoutDayId: data.workoutDayId.present
          ? data.workoutDayId.value
          : this.workoutDayId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, workoutDayId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.workoutDayId == this.workoutDayId &&
          other.date == this.date);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<String> id;
  final Value<String> workoutDayId;
  final Value<DateTime> date;
  final Value<int> rowid;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.workoutDayId = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required String workoutDayId,
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutDayId = Value(workoutDayId);
  static Insertable<Workout> custom({
    Expression<String>? id,
    Expression<String>? workoutDayId,
    Expression<DateTime>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutDayId != null) 'workout_day_id': workoutDayId,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutDayId,
    Value<DateTime>? date,
    Value<int>? rowid,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutDayId.present) {
      map['workout_day_id'] = Variable<String>(workoutDayId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutStrengthSetsTable extends WorkoutStrengthSets
    with TableInfo<$WorkoutStrengthSetsTable, WorkoutStrengthSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutStrengthSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<String> equipmentId = GeneratedColumn<String>(
    'equipment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipments (id)',
    ),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dateLoggedMeta = const VerificationMeta(
    'dateLogged',
  );
  @override
  late final GeneratedColumn<DateTime> dateLogged = GeneratedColumn<DateTime>(
    'date_logged',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    exerciseId,
    equipmentId,
    reps,
    weight,
    setNumber,
    isCompleted,
    dateLogged,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_strength_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutStrengthSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipment_id']!,
          _equipmentIdMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('date_logged')) {
      context.handle(
        _dateLoggedMeta,
        dateLogged.isAcceptableOrUnknown(data['date_logged']!, _dateLoggedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutStrengthSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutStrengthSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      equipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_id'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      dateLogged: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_logged'],
      )!,
    );
  }

  @override
  $WorkoutStrengthSetsTable createAlias(String alias) {
    return $WorkoutStrengthSetsTable(attachedDatabase, alias);
  }
}

class WorkoutStrengthSet extends DataClass
    implements Insertable<WorkoutStrengthSet> {
  final String id;
  final String workoutId;
  final String exerciseId;
  final String? equipmentId;
  final int reps;
  final double weight;
  final int setNumber;
  final bool isCompleted;
  final DateTime dateLogged;
  const WorkoutStrengthSet({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    this.equipmentId,
    required this.reps,
    required this.weight,
    required this.setNumber,
    required this.isCompleted,
    required this.dateLogged,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_id'] = Variable<String>(workoutId);
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || equipmentId != null) {
      map['equipment_id'] = Variable<String>(equipmentId);
    }
    map['reps'] = Variable<int>(reps);
    map['weight'] = Variable<double>(weight);
    map['set_number'] = Variable<int>(setNumber);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['date_logged'] = Variable<DateTime>(dateLogged);
    return map;
  }

  WorkoutStrengthSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutStrengthSetsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      exerciseId: Value(exerciseId),
      equipmentId: equipmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentId),
      reps: Value(reps),
      weight: Value(weight),
      setNumber: Value(setNumber),
      isCompleted: Value(isCompleted),
      dateLogged: Value(dateLogged),
    );
  }

  factory WorkoutStrengthSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutStrengthSet(
      id: serializer.fromJson<String>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      equipmentId: serializer.fromJson<String?>(json['equipmentId']),
      reps: serializer.fromJson<int>(json['reps']),
      weight: serializer.fromJson<double>(json['weight']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      dateLogged: serializer.fromJson<DateTime>(json['dateLogged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'equipmentId': serializer.toJson<String?>(equipmentId),
      'reps': serializer.toJson<int>(reps),
      'weight': serializer.toJson<double>(weight),
      'setNumber': serializer.toJson<int>(setNumber),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'dateLogged': serializer.toJson<DateTime>(dateLogged),
    };
  }

  WorkoutStrengthSet copyWith({
    String? id,
    String? workoutId,
    String? exerciseId,
    Value<String?> equipmentId = const Value.absent(),
    int? reps,
    double? weight,
    int? setNumber,
    bool? isCompleted,
    DateTime? dateLogged,
  }) => WorkoutStrengthSet(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    exerciseId: exerciseId ?? this.exerciseId,
    equipmentId: equipmentId.present ? equipmentId.value : this.equipmentId,
    reps: reps ?? this.reps,
    weight: weight ?? this.weight,
    setNumber: setNumber ?? this.setNumber,
    isCompleted: isCompleted ?? this.isCompleted,
    dateLogged: dateLogged ?? this.dateLogged,
  );
  WorkoutStrengthSet copyWithCompanion(WorkoutStrengthSetsCompanion data) {
    return WorkoutStrengthSet(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      equipmentId: data.equipmentId.present
          ? data.equipmentId.value
          : this.equipmentId,
      reps: data.reps.present ? data.reps.value : this.reps,
      weight: data.weight.present ? data.weight.value : this.weight,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      dateLogged: data.dateLogged.present
          ? data.dateLogged.value
          : this.dateLogged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutStrengthSet(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('setNumber: $setNumber, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dateLogged: $dateLogged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    exerciseId,
    equipmentId,
    reps,
    weight,
    setNumber,
    isCompleted,
    dateLogged,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutStrengthSet &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.exerciseId == this.exerciseId &&
          other.equipmentId == this.equipmentId &&
          other.reps == this.reps &&
          other.weight == this.weight &&
          other.setNumber == this.setNumber &&
          other.isCompleted == this.isCompleted &&
          other.dateLogged == this.dateLogged);
}

class WorkoutStrengthSetsCompanion extends UpdateCompanion<WorkoutStrengthSet> {
  final Value<String> id;
  final Value<String> workoutId;
  final Value<String> exerciseId;
  final Value<String?> equipmentId;
  final Value<int> reps;
  final Value<double> weight;
  final Value<int> setNumber;
  final Value<bool> isCompleted;
  final Value<DateTime> dateLogged;
  final Value<int> rowid;
  const WorkoutStrengthSetsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.reps = const Value.absent(),
    this.weight = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dateLogged = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutStrengthSetsCompanion.insert({
    this.id = const Value.absent(),
    required String workoutId,
    required String exerciseId,
    this.equipmentId = const Value.absent(),
    required int reps,
    required double weight,
    required int setNumber,
    this.isCompleted = const Value.absent(),
    this.dateLogged = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutId = Value(workoutId),
       exerciseId = Value(exerciseId),
       reps = Value(reps),
       weight = Value(weight),
       setNumber = Value(setNumber);
  static Insertable<WorkoutStrengthSet> custom({
    Expression<String>? id,
    Expression<String>? workoutId,
    Expression<String>? exerciseId,
    Expression<String>? equipmentId,
    Expression<int>? reps,
    Expression<double>? weight,
    Expression<int>? setNumber,
    Expression<bool>? isCompleted,
    Expression<DateTime>? dateLogged,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
      if (setNumber != null) 'set_number': setNumber,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (dateLogged != null) 'date_logged': dateLogged,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutStrengthSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutId,
    Value<String>? exerciseId,
    Value<String?>? equipmentId,
    Value<int>? reps,
    Value<double>? weight,
    Value<int>? setNumber,
    Value<bool>? isCompleted,
    Value<DateTime>? dateLogged,
    Value<int>? rowid,
  }) {
    return WorkoutStrengthSetsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      equipmentId: equipmentId ?? this.equipmentId,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      setNumber: setNumber ?? this.setNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      dateLogged: dateLogged ?? this.dateLogged,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<String>(equipmentId.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (dateLogged.present) {
      map['date_logged'] = Variable<DateTime>(dateLogged.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutStrengthSetsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('setNumber: $setNumber, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dateLogged: $dateLogged, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutCardioSetsTable extends WorkoutCardioSets
    with TableInfo<$WorkoutCardioSetsTable, WorkoutCardioSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutCardioSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceUnitMeta = const VerificationMeta(
    'distanceUnit',
  );
  @override
  late final GeneratedColumn<String> distanceUnit = GeneratedColumn<String>(
    'distance_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('km'),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dateLoggedMeta = const VerificationMeta(
    'dateLogged',
  );
  @override
  late final GeneratedColumn<DateTime> dateLogged = GeneratedColumn<DateTime>(
    'date_logged',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    exerciseId,
    durationSeconds,
    distanceMeters,
    distanceUnit,
    isCompleted,
    dateLogged,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_cardio_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutCardioSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('distance_unit')) {
      context.handle(
        _distanceUnitMeta,
        distanceUnit.isAcceptableOrUnknown(
          data['distance_unit']!,
          _distanceUnitMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('date_logged')) {
      context.handle(
        _dateLoggedMeta,
        dateLogged.isAcceptableOrUnknown(data['date_logged']!, _dateLoggedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutCardioSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutCardioSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      distanceUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_unit'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      dateLogged: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_logged'],
      )!,
    );
  }

  @override
  $WorkoutCardioSetsTable createAlias(String alias) {
    return $WorkoutCardioSetsTable(attachedDatabase, alias);
  }
}

class WorkoutCardioSet extends DataClass
    implements Insertable<WorkoutCardioSet> {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int durationSeconds;
  final double? distanceMeters;
  final String distanceUnit;
  final bool isCompleted;
  final DateTime dateLogged;
  const WorkoutCardioSet({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.durationSeconds,
    this.distanceMeters,
    required this.distanceUnit,
    required this.isCompleted,
    required this.dateLogged,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_id'] = Variable<String>(workoutId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    map['distance_unit'] = Variable<String>(distanceUnit);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['date_logged'] = Variable<DateTime>(dateLogged);
    return map;
  }

  WorkoutCardioSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutCardioSetsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      exerciseId: Value(exerciseId),
      durationSeconds: Value(durationSeconds),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      distanceUnit: Value(distanceUnit),
      isCompleted: Value(isCompleted),
      dateLogged: Value(dateLogged),
    );
  }

  factory WorkoutCardioSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutCardioSet(
      id: serializer.fromJson<String>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      distanceUnit: serializer.fromJson<String>(json['distanceUnit']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      dateLogged: serializer.fromJson<DateTime>(json['dateLogged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'distanceUnit': serializer.toJson<String>(distanceUnit),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'dateLogged': serializer.toJson<DateTime>(dateLogged),
    };
  }

  WorkoutCardioSet copyWith({
    String? id,
    String? workoutId,
    String? exerciseId,
    int? durationSeconds,
    Value<double?> distanceMeters = const Value.absent(),
    String? distanceUnit,
    bool? isCompleted,
    DateTime? dateLogged,
  }) => WorkoutCardioSet(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    exerciseId: exerciseId ?? this.exerciseId,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    distanceUnit: distanceUnit ?? this.distanceUnit,
    isCompleted: isCompleted ?? this.isCompleted,
    dateLogged: dateLogged ?? this.dateLogged,
  );
  WorkoutCardioSet copyWithCompanion(WorkoutCardioSetsCompanion data) {
    return WorkoutCardioSet(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      dateLogged: data.dateLogged.present
          ? data.dateLogged.value
          : this.dateLogged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutCardioSet(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dateLogged: $dateLogged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    exerciseId,
    durationSeconds,
    distanceMeters,
    distanceUnit,
    isCompleted,
    dateLogged,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutCardioSet &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.exerciseId == this.exerciseId &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceMeters == this.distanceMeters &&
          other.distanceUnit == this.distanceUnit &&
          other.isCompleted == this.isCompleted &&
          other.dateLogged == this.dateLogged);
}

class WorkoutCardioSetsCompanion extends UpdateCompanion<WorkoutCardioSet> {
  final Value<String> id;
  final Value<String> workoutId;
  final Value<String> exerciseId;
  final Value<int> durationSeconds;
  final Value<double?> distanceMeters;
  final Value<String> distanceUnit;
  final Value<bool> isCompleted;
  final Value<DateTime> dateLogged;
  final Value<int> rowid;
  const WorkoutCardioSetsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dateLogged = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutCardioSetsCompanion.insert({
    this.id = const Value.absent(),
    required String workoutId,
    required String exerciseId,
    required int durationSeconds,
    this.distanceMeters = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dateLogged = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutId = Value(workoutId),
       exerciseId = Value(exerciseId),
       durationSeconds = Value(durationSeconds);
  static Insertable<WorkoutCardioSet> custom({
    Expression<String>? id,
    Expression<String>? workoutId,
    Expression<String>? exerciseId,
    Expression<int>? durationSeconds,
    Expression<double>? distanceMeters,
    Expression<String>? distanceUnit,
    Expression<bool>? isCompleted,
    Expression<DateTime>? dateLogged,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (dateLogged != null) 'date_logged': dateLogged,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutCardioSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutId,
    Value<String>? exerciseId,
    Value<int>? durationSeconds,
    Value<double?>? distanceMeters,
    Value<String>? distanceUnit,
    Value<bool>? isCompleted,
    Value<DateTime>? dateLogged,
    Value<int>? rowid,
  }) {
    return WorkoutCardioSetsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      isCompleted: isCompleted ?? this.isCompleted,
      dateLogged: dateLogged ?? this.dateLogged,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(distanceUnit.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (dateLogged.present) {
      map['date_logged'] = Variable<DateTime>(dateLogged.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutCardioSetsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dateLogged: $dateLogged, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutHybridSetsTable extends WorkoutHybridSets
    with TableInfo<$WorkoutHybridSetsTable, WorkoutHybridSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutHybridSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<String> equipmentId = GeneratedColumn<String>(
    'equipment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipments (id)',
    ),
  );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
    'distance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceUnitMeta = const VerificationMeta(
    'distanceUnit',
  );
  @override
  late final GeneratedColumn<String> distanceUnit = GeneratedColumn<String>(
    'distance_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('m'),
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dateLoggedMeta = const VerificationMeta(
    'dateLogged',
  );
  @override
  late final GeneratedColumn<DateTime> dateLogged = GeneratedColumn<DateTime>(
    'date_logged',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    exerciseId,
    equipmentId,
    setNumber,
    weight,
    distance,
    distanceUnit,
    distanceMeters,
    isCompleted,
    dateLogged,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_hybrid_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutHybridSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipment_id']!,
          _equipmentIdMeta,
        ),
      );
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMeta);
    }
    if (data.containsKey('distance_unit')) {
      context.handle(
        _distanceUnitMeta,
        distanceUnit.isAcceptableOrUnknown(
          data['distance_unit']!,
          _distanceUnitMeta,
        ),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('date_logged')) {
      context.handle(
        _dateLoggedMeta,
        dateLogged.isAcceptableOrUnknown(data['date_logged']!, _dateLoggedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutHybridSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutHybridSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      equipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_id'],
      ),
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance'],
      )!,
      distanceUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_unit'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      dateLogged: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_logged'],
      )!,
    );
  }

  @override
  $WorkoutHybridSetsTable createAlias(String alias) {
    return $WorkoutHybridSetsTable(attachedDatabase, alias);
  }
}

class WorkoutHybridSet extends DataClass
    implements Insertable<WorkoutHybridSet> {
  final String id;
  final String workoutId;
  final String exerciseId;
  final String? equipmentId;
  final int setNumber;
  final double weight;
  final double distance;
  final String distanceUnit;
  final double? distanceMeters;
  final bool isCompleted;
  final DateTime dateLogged;
  const WorkoutHybridSet({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    this.equipmentId,
    required this.setNumber,
    required this.weight,
    required this.distance,
    required this.distanceUnit,
    this.distanceMeters,
    required this.isCompleted,
    required this.dateLogged,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_id'] = Variable<String>(workoutId);
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || equipmentId != null) {
      map['equipment_id'] = Variable<String>(equipmentId);
    }
    map['set_number'] = Variable<int>(setNumber);
    map['weight'] = Variable<double>(weight);
    map['distance'] = Variable<double>(distance);
    map['distance_unit'] = Variable<String>(distanceUnit);
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['date_logged'] = Variable<DateTime>(dateLogged);
    return map;
  }

  WorkoutHybridSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutHybridSetsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      exerciseId: Value(exerciseId),
      equipmentId: equipmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentId),
      setNumber: Value(setNumber),
      weight: Value(weight),
      distance: Value(distance),
      distanceUnit: Value(distanceUnit),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      isCompleted: Value(isCompleted),
      dateLogged: Value(dateLogged),
    );
  }

  factory WorkoutHybridSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutHybridSet(
      id: serializer.fromJson<String>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      equipmentId: serializer.fromJson<String?>(json['equipmentId']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      weight: serializer.fromJson<double>(json['weight']),
      distance: serializer.fromJson<double>(json['distance']),
      distanceUnit: serializer.fromJson<String>(json['distanceUnit']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      dateLogged: serializer.fromJson<DateTime>(json['dateLogged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'equipmentId': serializer.toJson<String?>(equipmentId),
      'setNumber': serializer.toJson<int>(setNumber),
      'weight': serializer.toJson<double>(weight),
      'distance': serializer.toJson<double>(distance),
      'distanceUnit': serializer.toJson<String>(distanceUnit),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'dateLogged': serializer.toJson<DateTime>(dateLogged),
    };
  }

  WorkoutHybridSet copyWith({
    String? id,
    String? workoutId,
    String? exerciseId,
    Value<String?> equipmentId = const Value.absent(),
    int? setNumber,
    double? weight,
    double? distance,
    String? distanceUnit,
    Value<double?> distanceMeters = const Value.absent(),
    bool? isCompleted,
    DateTime? dateLogged,
  }) => WorkoutHybridSet(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    exerciseId: exerciseId ?? this.exerciseId,
    equipmentId: equipmentId.present ? equipmentId.value : this.equipmentId,
    setNumber: setNumber ?? this.setNumber,
    weight: weight ?? this.weight,
    distance: distance ?? this.distance,
    distanceUnit: distanceUnit ?? this.distanceUnit,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    isCompleted: isCompleted ?? this.isCompleted,
    dateLogged: dateLogged ?? this.dateLogged,
  );
  WorkoutHybridSet copyWithCompanion(WorkoutHybridSetsCompanion data) {
    return WorkoutHybridSet(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      equipmentId: data.equipmentId.present
          ? data.equipmentId.value
          : this.equipmentId,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      weight: data.weight.present ? data.weight.value : this.weight,
      distance: data.distance.present ? data.distance.value : this.distance,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      dateLogged: data.dateLogged.present
          ? data.dateLogged.value
          : this.dateLogged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutHybridSet(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('setNumber: $setNumber, ')
          ..write('weight: $weight, ')
          ..write('distance: $distance, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dateLogged: $dateLogged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    exerciseId,
    equipmentId,
    setNumber,
    weight,
    distance,
    distanceUnit,
    distanceMeters,
    isCompleted,
    dateLogged,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutHybridSet &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.exerciseId == this.exerciseId &&
          other.equipmentId == this.equipmentId &&
          other.setNumber == this.setNumber &&
          other.weight == this.weight &&
          other.distance == this.distance &&
          other.distanceUnit == this.distanceUnit &&
          other.distanceMeters == this.distanceMeters &&
          other.isCompleted == this.isCompleted &&
          other.dateLogged == this.dateLogged);
}

class WorkoutHybridSetsCompanion extends UpdateCompanion<WorkoutHybridSet> {
  final Value<String> id;
  final Value<String> workoutId;
  final Value<String> exerciseId;
  final Value<String?> equipmentId;
  final Value<int> setNumber;
  final Value<double> weight;
  final Value<double> distance;
  final Value<String> distanceUnit;
  final Value<double?> distanceMeters;
  final Value<bool> isCompleted;
  final Value<DateTime> dateLogged;
  final Value<int> rowid;
  const WorkoutHybridSetsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.weight = const Value.absent(),
    this.distance = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dateLogged = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutHybridSetsCompanion.insert({
    this.id = const Value.absent(),
    required String workoutId,
    required String exerciseId,
    this.equipmentId = const Value.absent(),
    required int setNumber,
    required double weight,
    required double distance,
    this.distanceUnit = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dateLogged = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutId = Value(workoutId),
       exerciseId = Value(exerciseId),
       setNumber = Value(setNumber),
       weight = Value(weight),
       distance = Value(distance);
  static Insertable<WorkoutHybridSet> custom({
    Expression<String>? id,
    Expression<String>? workoutId,
    Expression<String>? exerciseId,
    Expression<String>? equipmentId,
    Expression<int>? setNumber,
    Expression<double>? weight,
    Expression<double>? distance,
    Expression<String>? distanceUnit,
    Expression<double>? distanceMeters,
    Expression<bool>? isCompleted,
    Expression<DateTime>? dateLogged,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (setNumber != null) 'set_number': setNumber,
      if (weight != null) 'weight': weight,
      if (distance != null) 'distance': distance,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (dateLogged != null) 'date_logged': dateLogged,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutHybridSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutId,
    Value<String>? exerciseId,
    Value<String?>? equipmentId,
    Value<int>? setNumber,
    Value<double>? weight,
    Value<double>? distance,
    Value<String>? distanceUnit,
    Value<double?>? distanceMeters,
    Value<bool>? isCompleted,
    Value<DateTime>? dateLogged,
    Value<int>? rowid,
  }) {
    return WorkoutHybridSetsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      equipmentId: equipmentId ?? this.equipmentId,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      distance: distance ?? this.distance,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isCompleted: isCompleted ?? this.isCompleted,
      dateLogged: dateLogged ?? this.dateLogged,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<String>(equipmentId.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(distanceUnit.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (dateLogged.present) {
      map['date_logged'] = Variable<DateTime>(dateLogged.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutHybridSetsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('setNumber: $setNumber, ')
          ..write('weight: $weight, ')
          ..write('distance: $distance, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dateLogged: $dateLogged, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyweightEntriesTable extends BodyweightEntries
    with TableInfo<$BodyweightEntriesTable, BodyweightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyweightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, weight];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bodyweight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyweightEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyweightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyweightEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
    );
  }

  @override
  $BodyweightEntriesTable createAlias(String alias) {
    return $BodyweightEntriesTable(attachedDatabase, alias);
  }
}

class BodyweightEntry extends DataClass implements Insertable<BodyweightEntry> {
  final String id;
  final DateTime date;
  final double weight;
  const BodyweightEntry({
    required this.id,
    required this.date,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['weight'] = Variable<double>(weight);
    return map;
  }

  BodyweightEntriesCompanion toCompanion(bool nullToAbsent) {
    return BodyweightEntriesCompanion(
      id: Value(id),
      date: Value(date),
      weight: Value(weight),
    );
  }

  factory BodyweightEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyweightEntry(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'weight': serializer.toJson<double>(weight),
    };
  }

  BodyweightEntry copyWith({String? id, DateTime? date, double? weight}) =>
      BodyweightEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        weight: weight ?? this.weight,
      );
  BodyweightEntry copyWithCompanion(BodyweightEntriesCompanion data) {
    return BodyweightEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyweightEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, weight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyweightEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.weight == this.weight);
}

class BodyweightEntriesCompanion extends UpdateCompanion<BodyweightEntry> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<double> weight;
  final Value<int> rowid;
  const BodyweightEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyweightEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double weight,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       weight = Value(weight);
  static Insertable<BodyweightEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<double>? weight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weight != null) 'weight': weight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyweightEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<double>? weight,
    Value<int>? rowid,
  }) {
    return BodyweightEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyweightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExerciseTypesTable exerciseTypes = $ExerciseTypesTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $EquipmentsTable equipments = $EquipmentsTable(this);
  late final $MuscleGroupsTable muscleGroups = $MuscleGroupsTable(this);
  late final $ExerciseMuscleGroupTable exerciseMuscleGroup =
      $ExerciseMuscleGroupTable(this);
  late final $ExerciseEquipmentTable exerciseEquipment =
      $ExerciseEquipmentTable(this);
  late final $ProgramsTable programs = $ProgramsTable(this);
  late final $WorkoutDaysTable workoutDays = $WorkoutDaysTable(this);
  late final $ProgramStrengthExercisesTable programStrengthExercises =
      $ProgramStrengthExercisesTable(this);
  late final $ProgramCardioExercisesTable programCardioExercises =
      $ProgramCardioExercisesTable(this);
  late final $ProgramHybridExercisesTable programHybridExercises =
      $ProgramHybridExercisesTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutStrengthSetsTable workoutStrengthSets =
      $WorkoutStrengthSetsTable(this);
  late final $WorkoutCardioSetsTable workoutCardioSets =
      $WorkoutCardioSetsTable(this);
  late final $WorkoutHybridSetsTable workoutHybridSets =
      $WorkoutHybridSetsTable(this);
  late final $BodyweightEntriesTable bodyweightEntries =
      $BodyweightEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exerciseTypes,
    exercises,
    equipments,
    muscleGroups,
    exerciseMuscleGroup,
    exerciseEquipment,
    programs,
    workoutDays,
    programStrengthExercises,
    programCardioExercises,
    programHybridExercises,
    workouts,
    workoutStrengthSets,
    workoutCardioSets,
    workoutHybridSets,
    bodyweightEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'programs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_days', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('program_strength_exercises', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'equipments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('program_strength_exercises', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('program_cardio_exercises', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('program_hybrid_exercises', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'equipments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('program_hybrid_exercises', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_strength_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_cardio_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_hybrid_sets', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ExerciseTypesTableCreateCompanionBuilder =
    ExerciseTypesCompanion Function({
      Value<String> id,
      required String name,
      Value<int> rowid,
    });
typedef $$ExerciseTypesTableUpdateCompanionBuilder =
    ExerciseTypesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$ExerciseTypesTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseTypesTable, ExerciseType> {
  $$ExerciseTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
  _exercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exercises,
    aliasName: $_aliasNameGenerator(
      db.exerciseTypes.id,
      db.exercises.exerciseTypeId,
    ),
  );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.exerciseTypeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciseTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseTypesTable> {
  $$ExerciseTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exercisesRefs(
    Expression<bool> Function($$ExercisesTableFilterComposer f) f,
  ) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.exerciseTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseTypesTable> {
  $$ExerciseTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseTypesTable> {
  $$ExerciseTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> exercisesRefs<T extends Object>(
    Expression<T> Function($$ExercisesTableAnnotationComposer a) f,
  ) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.exerciseTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseTypesTable,
          ExerciseType,
          $$ExerciseTypesTableFilterComposer,
          $$ExerciseTypesTableOrderingComposer,
          $$ExerciseTypesTableAnnotationComposer,
          $$ExerciseTypesTableCreateCompanionBuilder,
          $$ExerciseTypesTableUpdateCompanionBuilder,
          (ExerciseType, $$ExerciseTypesTableReferences),
          ExerciseType,
          PrefetchHooks Function({bool exercisesRefs})
        > {
  $$ExerciseTypesTableTableManager(_$AppDatabase db, $ExerciseTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTypesCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTypesCompanion.insert(
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (exercisesRefs) db.exercises],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exercisesRefs)
                    await $_getPrefetchedData<
                      ExerciseType,
                      $ExerciseTypesTable,
                      Exercise
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTypesTableReferences
                          ._exercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExerciseTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).exercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.exerciseTypeId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseTypesTable,
      ExerciseType,
      $$ExerciseTypesTableFilterComposer,
      $$ExerciseTypesTableOrderingComposer,
      $$ExerciseTypesTableAnnotationComposer,
      $$ExerciseTypesTableCreateCompanionBuilder,
      $$ExerciseTypesTableUpdateCompanionBuilder,
      (ExerciseType, $$ExerciseTypesTableReferences),
      ExerciseType,
      PrefetchHooks Function({bool exercisesRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> id,
      required String name,
      Value<String?> note,
      Value<String?> exerciseTypeId,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> note,
      Value<String?> exerciseTypeId,
      Value<int> rowid,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseTypesTable _exerciseTypeIdTable(_$AppDatabase db) =>
      db.exerciseTypes.createAlias(
        $_aliasNameGenerator(db.exercises.exerciseTypeId, db.exerciseTypes.id),
      );

  $$ExerciseTypesTableProcessedTableManager? get exerciseTypeId {
    final $_column = $_itemColumn<String>('exercise_type_id');
    if ($_column == null) return null;
    final manager = $$ExerciseTypesTableTableManager(
      $_db,
      $_db.exerciseTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ExerciseMuscleGroupTable,
    List<ExerciseMuscleGroupData>
  >
  _exerciseMuscleGroupRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseMuscleGroup,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.exerciseMuscleGroup.exerciseId,
        ),
      );

  $$ExerciseMuscleGroupTableProcessedTableManager get exerciseMuscleGroupRefs {
    final manager = $$ExerciseMuscleGroupTableTableManager(
      $_db,
      $_db.exerciseMuscleGroup,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMuscleGroupRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseEquipmentTable,
    List<ExerciseEquipmentData>
  >
  _exerciseEquipmentRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseEquipment,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.exerciseEquipment.exerciseId,
        ),
      );

  $$ExerciseEquipmentTableProcessedTableManager get exerciseEquipmentRefs {
    final manager = $$ExerciseEquipmentTableTableManager(
      $_db,
      $_db.exerciseEquipment,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseEquipmentRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramStrengthExercisesTable,
    List<ProgramStrengthExercise>
  >
  _programStrengthExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.programStrengthExercises,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.programStrengthExercises.exerciseId,
        ),
      );

  $$ProgramStrengthExercisesTableProcessedTableManager
  get programStrengthExercisesRefs {
    final manager = $$ProgramStrengthExercisesTableTableManager(
      $_db,
      $_db.programStrengthExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programStrengthExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramCardioExercisesTable,
    List<ProgramCardioExercise>
  >
  _programCardioExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.programCardioExercises,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.programCardioExercises.exerciseId,
        ),
      );

  $$ProgramCardioExercisesTableProcessedTableManager
  get programCardioExercisesRefs {
    final manager = $$ProgramCardioExercisesTableTableManager(
      $_db,
      $_db.programCardioExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programCardioExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramHybridExercisesTable,
    List<ProgramHybridExercise>
  >
  _programHybridExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.programHybridExercises,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.programHybridExercises.exerciseId,
        ),
      );

  $$ProgramHybridExercisesTableProcessedTableManager
  get programHybridExercisesRefs {
    final manager = $$ProgramHybridExercisesTableTableManager(
      $_db,
      $_db.programHybridExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programHybridExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkoutStrengthSetsTable,
    List<WorkoutStrengthSet>
  >
  _workoutStrengthSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutStrengthSets,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.workoutStrengthSets.exerciseId,
        ),
      );

  $$WorkoutStrengthSetsTableProcessedTableManager get workoutStrengthSetsRefs {
    final manager = $$WorkoutStrengthSetsTableTableManager(
      $_db,
      $_db.workoutStrengthSets,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutStrengthSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutCardioSetsTable, List<WorkoutCardioSet>>
  _workoutCardioSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutCardioSets,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.workoutCardioSets.exerciseId,
        ),
      );

  $$WorkoutCardioSetsTableProcessedTableManager get workoutCardioSetsRefs {
    final manager = $$WorkoutCardioSetsTableTableManager(
      $_db,
      $_db.workoutCardioSets,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutCardioSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutHybridSetsTable, List<WorkoutHybridSet>>
  _workoutHybridSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutHybridSets,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.workoutHybridSets.exerciseId,
        ),
      );

  $$WorkoutHybridSetsTableProcessedTableManager get workoutHybridSetsRefs {
    final manager = $$WorkoutHybridSetsTableTableManager(
      $_db,
      $_db.workoutHybridSets,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutHybridSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseTypesTableFilterComposer get exerciseTypeId {
    final $$ExerciseTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseMuscleGroupRefs(
    Expression<bool> Function($$ExerciseMuscleGroupTableFilterComposer f) f,
  ) {
    final $$ExerciseMuscleGroupTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscleGroup,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleGroupTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscleGroup,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseEquipmentRefs(
    Expression<bool> Function($$ExerciseEquipmentTableFilterComposer f) f,
  ) {
    final $$ExerciseEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipment,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.exerciseEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programStrengthExercisesRefs(
    Expression<bool> Function($$ProgramStrengthExercisesTableFilterComposer f)
    f,
  ) {
    final $$ProgramStrengthExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programStrengthExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramStrengthExercisesTableFilterComposer(
                $db: $db,
                $table: $db.programStrengthExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> programCardioExercisesRefs(
    Expression<bool> Function($$ProgramCardioExercisesTableFilterComposer f) f,
  ) {
    final $$ProgramCardioExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programCardioExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramCardioExercisesTableFilterComposer(
                $db: $db,
                $table: $db.programCardioExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> programHybridExercisesRefs(
    Expression<bool> Function($$ProgramHybridExercisesTableFilterComposer f) f,
  ) {
    final $$ProgramHybridExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programHybridExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramHybridExercisesTableFilterComposer(
                $db: $db,
                $table: $db.programHybridExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> workoutStrengthSetsRefs(
    Expression<bool> Function($$WorkoutStrengthSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutStrengthSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutStrengthSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutStrengthSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutStrengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutCardioSetsRefs(
    Expression<bool> Function($$WorkoutCardioSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutCardioSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutCardioSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutCardioSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutCardioSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutHybridSetsRefs(
    Expression<bool> Function($$WorkoutHybridSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutHybridSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutHybridSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutHybridSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutHybridSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseTypesTableOrderingComposer get exerciseTypeId {
    final $$ExerciseTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ExerciseTypesTableAnnotationComposer get exerciseTypeId {
    final $$ExerciseTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseMuscleGroupRefs<T extends Object>(
    Expression<T> Function($$ExerciseMuscleGroupTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMuscleGroupTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseMuscleGroup,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseMuscleGroupTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseMuscleGroup,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> exerciseEquipmentRefs<T extends Object>(
    Expression<T> Function($$ExerciseEquipmentTableAnnotationComposer a) f,
  ) {
    final $$ExerciseEquipmentTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseEquipment,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseEquipmentTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseEquipment,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> programStrengthExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramStrengthExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$ProgramStrengthExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programStrengthExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramStrengthExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.programStrengthExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> programCardioExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramCardioExercisesTableAnnotationComposer a) f,
  ) {
    final $$ProgramCardioExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programCardioExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramCardioExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.programCardioExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> programHybridExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramHybridExercisesTableAnnotationComposer a) f,
  ) {
    final $$ProgramHybridExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programHybridExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramHybridExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.programHybridExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutStrengthSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutStrengthSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutStrengthSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutStrengthSets,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutStrengthSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutStrengthSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutCardioSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutCardioSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutCardioSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutCardioSets,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutCardioSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutCardioSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutHybridSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutHybridSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutHybridSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutHybridSets,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutHybridSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutHybridSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool exerciseTypeId,
            bool exerciseMuscleGroupRefs,
            bool exerciseEquipmentRefs,
            bool programStrengthExercisesRefs,
            bool programCardioExercisesRefs,
            bool programHybridExercisesRefs,
            bool workoutStrengthSetsRefs,
            bool workoutCardioSetsRefs,
            bool workoutHybridSetsRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> exerciseTypeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                note: note,
                exerciseTypeId: exerciseTypeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<String?> note = const Value.absent(),
                Value<String?> exerciseTypeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                note: note,
                exerciseTypeId: exerciseTypeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                exerciseTypeId = false,
                exerciseMuscleGroupRefs = false,
                exerciseEquipmentRefs = false,
                programStrengthExercisesRefs = false,
                programCardioExercisesRefs = false,
                programHybridExercisesRefs = false,
                workoutStrengthSetsRefs = false,
                workoutCardioSetsRefs = false,
                workoutHybridSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseMuscleGroupRefs) db.exerciseMuscleGroup,
                    if (exerciseEquipmentRefs) db.exerciseEquipment,
                    if (programStrengthExercisesRefs)
                      db.programStrengthExercises,
                    if (programCardioExercisesRefs) db.programCardioExercises,
                    if (programHybridExercisesRefs) db.programHybridExercises,
                    if (workoutStrengthSetsRefs) db.workoutStrengthSets,
                    if (workoutCardioSetsRefs) db.workoutCardioSets,
                    if (workoutHybridSetsRefs) db.workoutHybridSets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (exerciseTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseTypeId,
                                    referencedTable: $$ExercisesTableReferences
                                        ._exerciseTypeIdTable(db),
                                    referencedColumn: $$ExercisesTableReferences
                                        ._exerciseTypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseMuscleGroupRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseMuscleGroupData
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseMuscleGroupRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseMuscleGroupRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseEquipmentRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseEquipmentData
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseEquipmentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseEquipmentRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programStrengthExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ProgramStrengthExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._programStrengthExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).programStrengthExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programCardioExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ProgramCardioExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._programCardioExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).programCardioExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programHybridExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ProgramHybridExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._programHybridExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).programHybridExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutStrengthSetsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          WorkoutStrengthSet
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutStrengthSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutStrengthSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutCardioSetsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          WorkoutCardioSet
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutCardioSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutCardioSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutHybridSetsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          WorkoutHybridSet
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutHybridSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutHybridSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool exerciseTypeId,
        bool exerciseMuscleGroupRefs,
        bool exerciseEquipmentRefs,
        bool programStrengthExercisesRefs,
        bool programCardioExercisesRefs,
        bool programHybridExercisesRefs,
        bool workoutStrengthSetsRefs,
        bool workoutCardioSetsRefs,
        bool workoutHybridSetsRefs,
      })
    >;
typedef $$EquipmentsTableCreateCompanionBuilder =
    EquipmentsCompanion Function({
      Value<String> id,
      required String name,
      required String iconName,
      Value<int> rowid,
    });
typedef $$EquipmentsTableUpdateCompanionBuilder =
    EquipmentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconName,
      Value<int> rowid,
    });

final class $$EquipmentsTableReferences
    extends BaseReferences<_$AppDatabase, $EquipmentsTable, Equipment> {
  $$EquipmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $ExerciseEquipmentTable,
    List<ExerciseEquipmentData>
  >
  _exerciseEquipmentRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseEquipment,
        aliasName: $_aliasNameGenerator(
          db.equipments.id,
          db.exerciseEquipment.equipmentId,
        ),
      );

  $$ExerciseEquipmentTableProcessedTableManager get exerciseEquipmentRefs {
    final manager = $$ExerciseEquipmentTableTableManager(
      $_db,
      $_db.exerciseEquipment,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseEquipmentRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramStrengthExercisesTable,
    List<ProgramStrengthExercise>
  >
  _programStrengthExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.programStrengthExercises,
        aliasName: $_aliasNameGenerator(
          db.equipments.id,
          db.programStrengthExercises.equipmentId,
        ),
      );

  $$ProgramStrengthExercisesTableProcessedTableManager
  get programStrengthExercisesRefs {
    final manager = $$ProgramStrengthExercisesTableTableManager(
      $_db,
      $_db.programStrengthExercises,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programStrengthExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramHybridExercisesTable,
    List<ProgramHybridExercise>
  >
  _programHybridExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.programHybridExercises,
        aliasName: $_aliasNameGenerator(
          db.equipments.id,
          db.programHybridExercises.equipmentId,
        ),
      );

  $$ProgramHybridExercisesTableProcessedTableManager
  get programHybridExercisesRefs {
    final manager = $$ProgramHybridExercisesTableTableManager(
      $_db,
      $_db.programHybridExercises,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programHybridExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkoutStrengthSetsTable,
    List<WorkoutStrengthSet>
  >
  _workoutStrengthSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutStrengthSets,
        aliasName: $_aliasNameGenerator(
          db.equipments.id,
          db.workoutStrengthSets.equipmentId,
        ),
      );

  $$WorkoutStrengthSetsTableProcessedTableManager get workoutStrengthSetsRefs {
    final manager = $$WorkoutStrengthSetsTableTableManager(
      $_db,
      $_db.workoutStrengthSets,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutStrengthSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutHybridSetsTable, List<WorkoutHybridSet>>
  _workoutHybridSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutHybridSets,
        aliasName: $_aliasNameGenerator(
          db.equipments.id,
          db.workoutHybridSets.equipmentId,
        ),
      );

  $$WorkoutHybridSetsTableProcessedTableManager get workoutHybridSetsRefs {
    final manager = $$WorkoutHybridSetsTableTableManager(
      $_db,
      $_db.workoutHybridSets,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutHybridSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EquipmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseEquipmentRefs(
    Expression<bool> Function($$ExerciseEquipmentTableFilterComposer f) f,
  ) {
    final $$ExerciseEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipment,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.exerciseEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programStrengthExercisesRefs(
    Expression<bool> Function($$ProgramStrengthExercisesTableFilterComposer f)
    f,
  ) {
    final $$ProgramStrengthExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programStrengthExercises,
          getReferencedColumn: (t) => t.equipmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramStrengthExercisesTableFilterComposer(
                $db: $db,
                $table: $db.programStrengthExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> programHybridExercisesRefs(
    Expression<bool> Function($$ProgramHybridExercisesTableFilterComposer f) f,
  ) {
    final $$ProgramHybridExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programHybridExercises,
          getReferencedColumn: (t) => t.equipmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramHybridExercisesTableFilterComposer(
                $db: $db,
                $table: $db.programHybridExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> workoutStrengthSetsRefs(
    Expression<bool> Function($$WorkoutStrengthSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutStrengthSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutStrengthSets,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutStrengthSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutStrengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutHybridSetsRefs(
    Expression<bool> Function($$WorkoutHybridSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutHybridSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutHybridSets,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutHybridSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutHybridSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquipmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EquipmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  Expression<T> exerciseEquipmentRefs<T extends Object>(
    Expression<T> Function($$ExerciseEquipmentTableAnnotationComposer a) f,
  ) {
    final $$ExerciseEquipmentTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseEquipment,
          getReferencedColumn: (t) => t.equipmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseEquipmentTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseEquipment,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> programStrengthExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramStrengthExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$ProgramStrengthExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programStrengthExercises,
          getReferencedColumn: (t) => t.equipmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramStrengthExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.programStrengthExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> programHybridExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramHybridExercisesTableAnnotationComposer a) f,
  ) {
    final $$ProgramHybridExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programHybridExercises,
          getReferencedColumn: (t) => t.equipmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramHybridExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.programHybridExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutStrengthSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutStrengthSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutStrengthSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutStrengthSets,
          getReferencedColumn: (t) => t.equipmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutStrengthSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutStrengthSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutHybridSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutHybridSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutHybridSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutHybridSets,
          getReferencedColumn: (t) => t.equipmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutHybridSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutHybridSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EquipmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EquipmentsTable,
          Equipment,
          $$EquipmentsTableFilterComposer,
          $$EquipmentsTableOrderingComposer,
          $$EquipmentsTableAnnotationComposer,
          $$EquipmentsTableCreateCompanionBuilder,
          $$EquipmentsTableUpdateCompanionBuilder,
          (Equipment, $$EquipmentsTableReferences),
          Equipment,
          PrefetchHooks Function({
            bool exerciseEquipmentRefs,
            bool programStrengthExercisesRefs,
            bool programHybridExercisesRefs,
            bool workoutStrengthSetsRefs,
            bool workoutHybridSetsRefs,
          })
        > {
  $$EquipmentsTableTableManager(_$AppDatabase db, $EquipmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EquipmentsCompanion(
                id: id,
                name: name,
                iconName: iconName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String iconName,
                Value<int> rowid = const Value.absent(),
              }) => EquipmentsCompanion.insert(
                id: id,
                name: name,
                iconName: iconName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EquipmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                exerciseEquipmentRefs = false,
                programStrengthExercisesRefs = false,
                programHybridExercisesRefs = false,
                workoutStrengthSetsRefs = false,
                workoutHybridSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseEquipmentRefs) db.exerciseEquipment,
                    if (programStrengthExercisesRefs)
                      db.programStrengthExercises,
                    if (programHybridExercisesRefs) db.programHybridExercises,
                    if (workoutStrengthSetsRefs) db.workoutStrengthSets,
                    if (workoutHybridSetsRefs) db.workoutHybridSets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseEquipmentRefs)
                        await $_getPrefetchedData<
                          Equipment,
                          $EquipmentsTable,
                          ExerciseEquipmentData
                        >(
                          currentTable: table,
                          referencedTable: $$EquipmentsTableReferences
                              ._exerciseEquipmentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EquipmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseEquipmentRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.equipmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programStrengthExercisesRefs)
                        await $_getPrefetchedData<
                          Equipment,
                          $EquipmentsTable,
                          ProgramStrengthExercise
                        >(
                          currentTable: table,
                          referencedTable: $$EquipmentsTableReferences
                              ._programStrengthExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EquipmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).programStrengthExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.equipmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programHybridExercisesRefs)
                        await $_getPrefetchedData<
                          Equipment,
                          $EquipmentsTable,
                          ProgramHybridExercise
                        >(
                          currentTable: table,
                          referencedTable: $$EquipmentsTableReferences
                              ._programHybridExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EquipmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).programHybridExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.equipmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutStrengthSetsRefs)
                        await $_getPrefetchedData<
                          Equipment,
                          $EquipmentsTable,
                          WorkoutStrengthSet
                        >(
                          currentTable: table,
                          referencedTable: $$EquipmentsTableReferences
                              ._workoutStrengthSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EquipmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutStrengthSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.equipmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutHybridSetsRefs)
                        await $_getPrefetchedData<
                          Equipment,
                          $EquipmentsTable,
                          WorkoutHybridSet
                        >(
                          currentTable: table,
                          referencedTable: $$EquipmentsTableReferences
                              ._workoutHybridSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EquipmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutHybridSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.equipmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EquipmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EquipmentsTable,
      Equipment,
      $$EquipmentsTableFilterComposer,
      $$EquipmentsTableOrderingComposer,
      $$EquipmentsTableAnnotationComposer,
      $$EquipmentsTableCreateCompanionBuilder,
      $$EquipmentsTableUpdateCompanionBuilder,
      (Equipment, $$EquipmentsTableReferences),
      Equipment,
      PrefetchHooks Function({
        bool exerciseEquipmentRefs,
        bool programStrengthExercisesRefs,
        bool programHybridExercisesRefs,
        bool workoutStrengthSetsRefs,
        bool workoutHybridSetsRefs,
      })
    >;
typedef $$MuscleGroupsTableCreateCompanionBuilder =
    MuscleGroupsCompanion Function({
      Value<String> id,
      required String name,
      Value<int> rowid,
    });
typedef $$MuscleGroupsTableUpdateCompanionBuilder =
    MuscleGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$MuscleGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $MuscleGroupsTable, MuscleGroup> {
  $$MuscleGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $ExerciseMuscleGroupTable,
    List<ExerciseMuscleGroupData>
  >
  _exerciseMuscleGroupRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseMuscleGroup,
        aliasName: $_aliasNameGenerator(
          db.muscleGroups.id,
          db.exerciseMuscleGroup.muscleGroupId,
        ),
      );

  $$ExerciseMuscleGroupTableProcessedTableManager get exerciseMuscleGroupRefs {
    final manager = $$ExerciseMuscleGroupTableTableManager(
      $_db,
      $_db.exerciseMuscleGroup,
    ).filter((f) => f.muscleGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMuscleGroupRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MuscleGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMuscleGroupRefs(
    Expression<bool> Function($$ExerciseMuscleGroupTableFilterComposer f) f,
  ) {
    final $$ExerciseMuscleGroupTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscleGroup,
      getReferencedColumn: (t) => t.muscleGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleGroupTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscleGroup,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MuscleGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MuscleGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> exerciseMuscleGroupRefs<T extends Object>(
    Expression<T> Function($$ExerciseMuscleGroupTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMuscleGroupTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseMuscleGroup,
          getReferencedColumn: (t) => t.muscleGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseMuscleGroupTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseMuscleGroup,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MuscleGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MuscleGroupsTable,
          MuscleGroup,
          $$MuscleGroupsTableFilterComposer,
          $$MuscleGroupsTableOrderingComposer,
          $$MuscleGroupsTableAnnotationComposer,
          $$MuscleGroupsTableCreateCompanionBuilder,
          $$MuscleGroupsTableUpdateCompanionBuilder,
          (MuscleGroup, $$MuscleGroupsTableReferences),
          MuscleGroup,
          PrefetchHooks Function({bool exerciseMuscleGroupRefs})
        > {
  $$MuscleGroupsTableTableManager(_$AppDatabase db, $MuscleGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MuscleGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MuscleGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MuscleGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MuscleGroupsCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => MuscleGroupsCompanion.insert(
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MuscleGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseMuscleGroupRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseMuscleGroupRefs) db.exerciseMuscleGroup,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseMuscleGroupRefs)
                    await $_getPrefetchedData<
                      MuscleGroup,
                      $MuscleGroupsTable,
                      ExerciseMuscleGroupData
                    >(
                      currentTable: table,
                      referencedTable: $$MuscleGroupsTableReferences
                          ._exerciseMuscleGroupRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MuscleGroupsTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseMuscleGroupRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.muscleGroupId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MuscleGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MuscleGroupsTable,
      MuscleGroup,
      $$MuscleGroupsTableFilterComposer,
      $$MuscleGroupsTableOrderingComposer,
      $$MuscleGroupsTableAnnotationComposer,
      $$MuscleGroupsTableCreateCompanionBuilder,
      $$MuscleGroupsTableUpdateCompanionBuilder,
      (MuscleGroup, $$MuscleGroupsTableReferences),
      MuscleGroup,
      PrefetchHooks Function({bool exerciseMuscleGroupRefs})
    >;
typedef $$ExerciseMuscleGroupTableCreateCompanionBuilder =
    ExerciseMuscleGroupCompanion Function({
      required String exerciseId,
      required String muscleGroupId,
      required String focus,
      Value<int> rowid,
    });
typedef $$ExerciseMuscleGroupTableUpdateCompanionBuilder =
    ExerciseMuscleGroupCompanion Function({
      Value<String> exerciseId,
      Value<String> muscleGroupId,
      Value<String> focus,
      Value<int> rowid,
    });

final class $$ExerciseMuscleGroupTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseMuscleGroupTable,
          ExerciseMuscleGroupData
        > {
  $$ExerciseMuscleGroupTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(
          db.exerciseMuscleGroup.exerciseId,
          db.exercises.id,
        ),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MuscleGroupsTable _muscleGroupIdTable(_$AppDatabase db) =>
      db.muscleGroups.createAlias(
        $_aliasNameGenerator(
          db.exerciseMuscleGroup.muscleGroupId,
          db.muscleGroups.id,
        ),
      );

  $$MuscleGroupsTableProcessedTableManager get muscleGroupId {
    final $_column = $_itemColumn<String>('muscle_group_id')!;

    final manager = $$MuscleGroupsTableTableManager(
      $_db,
      $_db.muscleGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_muscleGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseMuscleGroupTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseMuscleGroupTable> {
  $$ExerciseMuscleGroupTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableFilterComposer get muscleGroupId {
    final $$MuscleGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableFilterComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMuscleGroupTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseMuscleGroupTable> {
  $$ExerciseMuscleGroupTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableOrderingComposer get muscleGroupId {
    final $$MuscleGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMuscleGroupTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseMuscleGroupTable> {
  $$ExerciseMuscleGroupTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableAnnotationComposer get muscleGroupId {
    final $$MuscleGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMuscleGroupTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseMuscleGroupTable,
          ExerciseMuscleGroupData,
          $$ExerciseMuscleGroupTableFilterComposer,
          $$ExerciseMuscleGroupTableOrderingComposer,
          $$ExerciseMuscleGroupTableAnnotationComposer,
          $$ExerciseMuscleGroupTableCreateCompanionBuilder,
          $$ExerciseMuscleGroupTableUpdateCompanionBuilder,
          (ExerciseMuscleGroupData, $$ExerciseMuscleGroupTableReferences),
          ExerciseMuscleGroupData,
          PrefetchHooks Function({bool exerciseId, bool muscleGroupId})
        > {
  $$ExerciseMuscleGroupTableTableManager(
    _$AppDatabase db,
    $ExerciseMuscleGroupTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMuscleGroupTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMuscleGroupTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExerciseMuscleGroupTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> muscleGroupId = const Value.absent(),
                Value<String> focus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMuscleGroupCompanion(
                exerciseId: exerciseId,
                muscleGroupId: muscleGroupId,
                focus: focus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String muscleGroupId,
                required String focus,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMuscleGroupCompanion.insert(
                exerciseId: exerciseId,
                muscleGroupId: muscleGroupId,
                focus: focus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseMuscleGroupTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, muscleGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$ExerciseMuscleGroupTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$ExerciseMuscleGroupTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (muscleGroupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.muscleGroupId,
                                referencedTable:
                                    $$ExerciseMuscleGroupTableReferences
                                        ._muscleGroupIdTable(db),
                                referencedColumn:
                                    $$ExerciseMuscleGroupTableReferences
                                        ._muscleGroupIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseMuscleGroupTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseMuscleGroupTable,
      ExerciseMuscleGroupData,
      $$ExerciseMuscleGroupTableFilterComposer,
      $$ExerciseMuscleGroupTableOrderingComposer,
      $$ExerciseMuscleGroupTableAnnotationComposer,
      $$ExerciseMuscleGroupTableCreateCompanionBuilder,
      $$ExerciseMuscleGroupTableUpdateCompanionBuilder,
      (ExerciseMuscleGroupData, $$ExerciseMuscleGroupTableReferences),
      ExerciseMuscleGroupData,
      PrefetchHooks Function({bool exerciseId, bool muscleGroupId})
    >;
typedef $$ExerciseEquipmentTableCreateCompanionBuilder =
    ExerciseEquipmentCompanion Function({
      required String exerciseId,
      required String equipmentId,
      Value<int> rowid,
    });
typedef $$ExerciseEquipmentTableUpdateCompanionBuilder =
    ExerciseEquipmentCompanion Function({
      Value<String> exerciseId,
      Value<String> equipmentId,
      Value<int> rowid,
    });

final class $$ExerciseEquipmentTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseEquipmentTable,
          ExerciseEquipmentData
        > {
  $$ExerciseEquipmentTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.exerciseEquipment.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentsTable _equipmentIdTable(_$AppDatabase db) =>
      db.equipments.createAlias(
        $_aliasNameGenerator(
          db.exerciseEquipment.equipmentId,
          db.equipments.id,
        ),
      );

  $$EquipmentsTableProcessedTableManager get equipmentId {
    final $_column = $_itemColumn<String>('equipment_id')!;

    final manager = $$EquipmentsTableTableManager(
      $_db,
      $_db.equipments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseEquipmentTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableFilterComposer get equipmentId {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableFilterComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableOrderingComposer get equipmentId {
    final $$EquipmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableOrderingComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableAnnotationComposer get equipmentId {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseEquipmentTable,
          ExerciseEquipmentData,
          $$ExerciseEquipmentTableFilterComposer,
          $$ExerciseEquipmentTableOrderingComposer,
          $$ExerciseEquipmentTableAnnotationComposer,
          $$ExerciseEquipmentTableCreateCompanionBuilder,
          $$ExerciseEquipmentTableUpdateCompanionBuilder,
          (ExerciseEquipmentData, $$ExerciseEquipmentTableReferences),
          ExerciseEquipmentData,
          PrefetchHooks Function({bool exerciseId, bool equipmentId})
        > {
  $$ExerciseEquipmentTableTableManager(
    _$AppDatabase db,
    $ExerciseEquipmentTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseEquipmentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseEquipmentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseEquipmentTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> equipmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEquipmentCompanion(
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String equipmentId,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEquipmentCompanion.insert(
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseEquipmentTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, equipmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$ExerciseEquipmentTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$ExerciseEquipmentTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (equipmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.equipmentId,
                                referencedTable:
                                    $$ExerciseEquipmentTableReferences
                                        ._equipmentIdTable(db),
                                referencedColumn:
                                    $$ExerciseEquipmentTableReferences
                                        ._equipmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseEquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseEquipmentTable,
      ExerciseEquipmentData,
      $$ExerciseEquipmentTableFilterComposer,
      $$ExerciseEquipmentTableOrderingComposer,
      $$ExerciseEquipmentTableAnnotationComposer,
      $$ExerciseEquipmentTableCreateCompanionBuilder,
      $$ExerciseEquipmentTableUpdateCompanionBuilder,
      (ExerciseEquipmentData, $$ExerciseEquipmentTableReferences),
      ExerciseEquipmentData,
      PrefetchHooks Function({bool exerciseId, bool equipmentId})
    >;
typedef $$ProgramsTableCreateCompanionBuilder =
    ProgramsCompanion Function({
      Value<String> id,
      required String name,
      Value<int> rowid,
    });
typedef $$ProgramsTableUpdateCompanionBuilder =
    ProgramsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$ProgramsTableReferences
    extends BaseReferences<_$AppDatabase, $ProgramsTable, Program> {
  $$ProgramsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutDaysTable, List<WorkoutDay>>
  _workoutDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutDays,
    aliasName: $_aliasNameGenerator(db.programs.id, db.workoutDays.programId),
  );

  $$WorkoutDaysTableProcessedTableManager get workoutDaysRefs {
    final manager = $$WorkoutDaysTableTableManager(
      $_db,
      $_db.workoutDays,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutDaysRefs(
    Expression<bool> Function($$WorkoutDaysTableFilterComposer f) f,
  ) {
    final $$WorkoutDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableFilterComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> workoutDaysRefs<T extends Object>(
    Expression<T> Function($$WorkoutDaysTableAnnotationComposer a) f,
  ) {
    final $$WorkoutDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramsTable,
          Program,
          $$ProgramsTableFilterComposer,
          $$ProgramsTableOrderingComposer,
          $$ProgramsTableAnnotationComposer,
          $$ProgramsTableCreateCompanionBuilder,
          $$ProgramsTableUpdateCompanionBuilder,
          (Program, $$ProgramsTableReferences),
          Program,
          PrefetchHooks Function({bool workoutDaysRefs})
        > {
  $$ProgramsTableTableManager(_$AppDatabase db, $ProgramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramsCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => ProgramsCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutDaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutDaysRefs) db.workoutDays],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutDaysRefs)
                    await $_getPrefetchedData<
                      Program,
                      $ProgramsTable,
                      WorkoutDay
                    >(
                      currentTable: table,
                      referencedTable: $$ProgramsTableReferences
                          ._workoutDaysRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProgramsTableReferences(
                        db,
                        table,
                        p0,
                      ).workoutDaysRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.programId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramsTable,
      Program,
      $$ProgramsTableFilterComposer,
      $$ProgramsTableOrderingComposer,
      $$ProgramsTableAnnotationComposer,
      $$ProgramsTableCreateCompanionBuilder,
      $$ProgramsTableUpdateCompanionBuilder,
      (Program, $$ProgramsTableReferences),
      Program,
      PrefetchHooks Function({bool workoutDaysRefs})
    >;
typedef $$WorkoutDaysTableCreateCompanionBuilder =
    WorkoutDaysCompanion Function({
      Value<String> id,
      required String programId,
      required String dayName,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$WorkoutDaysTableUpdateCompanionBuilder =
    WorkoutDaysCompanion Function({
      Value<String> id,
      Value<String> programId,
      Value<String> dayName,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$WorkoutDaysTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutDaysTable, WorkoutDay> {
  $$WorkoutDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProgramsTable _programIdTable(_$AppDatabase db) =>
      db.programs.createAlias(
        $_aliasNameGenerator(db.workoutDays.programId, db.programs.id),
      );

  $$ProgramsTableProcessedTableManager get programId {
    final $_column = $_itemColumn<String>('program_id')!;

    final manager = $$ProgramsTableTableManager(
      $_db,
      $_db.programs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ProgramStrengthExercisesTable,
    List<ProgramStrengthExercise>
  >
  _programStrengthExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.programStrengthExercises,
        aliasName: $_aliasNameGenerator(
          db.workoutDays.id,
          db.programStrengthExercises.workoutDayId,
        ),
      );

  $$ProgramStrengthExercisesTableProcessedTableManager
  get programStrengthExercisesRefs {
    final manager = $$ProgramStrengthExercisesTableTableManager(
      $_db,
      $_db.programStrengthExercises,
    ).filter((f) => f.workoutDayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programStrengthExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramCardioExercisesTable,
    List<ProgramCardioExercise>
  >
  _programCardioExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.programCardioExercises,
        aliasName: $_aliasNameGenerator(
          db.workoutDays.id,
          db.programCardioExercises.workoutDayId,
        ),
      );

  $$ProgramCardioExercisesTableProcessedTableManager
  get programCardioExercisesRefs {
    final manager = $$ProgramCardioExercisesTableTableManager(
      $_db,
      $_db.programCardioExercises,
    ).filter((f) => f.workoutDayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programCardioExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramHybridExercisesTable,
    List<ProgramHybridExercise>
  >
  _programHybridExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.programHybridExercises,
        aliasName: $_aliasNameGenerator(
          db.workoutDays.id,
          db.programHybridExercises.workoutDayId,
        ),
      );

  $$ProgramHybridExercisesTableProcessedTableManager
  get programHybridExercisesRefs {
    final manager = $$ProgramHybridExercisesTableTableManager(
      $_db,
      $_db.programHybridExercises,
    ).filter((f) => f.workoutDayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programHybridExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutsTable, List<Workout>> _workoutsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.workouts,
    aliasName: $_aliasNameGenerator(
      db.workoutDays.id,
      db.workouts.workoutDayId,
    ),
  );

  $$WorkoutsTableProcessedTableManager get workoutsRefs {
    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.workoutDayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutDaysTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayName => $composableBuilder(
    column: $table.dayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ProgramsTableFilterComposer get programId {
    final $$ProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableFilterComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> programStrengthExercisesRefs(
    Expression<bool> Function($$ProgramStrengthExercisesTableFilterComposer f)
    f,
  ) {
    final $$ProgramStrengthExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programStrengthExercises,
          getReferencedColumn: (t) => t.workoutDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramStrengthExercisesTableFilterComposer(
                $db: $db,
                $table: $db.programStrengthExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> programCardioExercisesRefs(
    Expression<bool> Function($$ProgramCardioExercisesTableFilterComposer f) f,
  ) {
    final $$ProgramCardioExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programCardioExercises,
          getReferencedColumn: (t) => t.workoutDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramCardioExercisesTableFilterComposer(
                $db: $db,
                $table: $db.programCardioExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> programHybridExercisesRefs(
    Expression<bool> Function($$ProgramHybridExercisesTableFilterComposer f) f,
  ) {
    final $$ProgramHybridExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programHybridExercises,
          getReferencedColumn: (t) => t.workoutDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramHybridExercisesTableFilterComposer(
                $db: $db,
                $table: $db.programHybridExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> workoutsRefs(
    Expression<bool> Function($$WorkoutsTableFilterComposer f) f,
  ) {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.workoutDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayName => $composableBuilder(
    column: $table.dayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProgramsTableOrderingComposer get programId {
    final $$ProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayName =>
      $composableBuilder(column: $table.dayName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ProgramsTableAnnotationComposer get programId {
    final $$ProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> programStrengthExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramStrengthExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$ProgramStrengthExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programStrengthExercises,
          getReferencedColumn: (t) => t.workoutDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramStrengthExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.programStrengthExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> programCardioExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramCardioExercisesTableAnnotationComposer a) f,
  ) {
    final $$ProgramCardioExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programCardioExercises,
          getReferencedColumn: (t) => t.workoutDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramCardioExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.programCardioExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> programHybridExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramHybridExercisesTableAnnotationComposer a) f,
  ) {
    final $$ProgramHybridExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programHybridExercises,
          getReferencedColumn: (t) => t.workoutDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramHybridExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.programHybridExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutsRefs<T extends Object>(
    Expression<T> Function($$WorkoutsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.workoutDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutDaysTable,
          WorkoutDay,
          $$WorkoutDaysTableFilterComposer,
          $$WorkoutDaysTableOrderingComposer,
          $$WorkoutDaysTableAnnotationComposer,
          $$WorkoutDaysTableCreateCompanionBuilder,
          $$WorkoutDaysTableUpdateCompanionBuilder,
          (WorkoutDay, $$WorkoutDaysTableReferences),
          WorkoutDay,
          PrefetchHooks Function({
            bool programId,
            bool programStrengthExercisesRefs,
            bool programCardioExercisesRefs,
            bool programHybridExercisesRefs,
            bool workoutsRefs,
          })
        > {
  $$WorkoutDaysTableTableManager(_$AppDatabase db, $WorkoutDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> programId = const Value.absent(),
                Value<String> dayName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutDaysCompanion(
                id: id,
                programId: programId,
                dayName: dayName,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String programId,
                required String dayName,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutDaysCompanion.insert(
                id: id,
                programId: programId,
                dayName: dayName,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                programId = false,
                programStrengthExercisesRefs = false,
                programCardioExercisesRefs = false,
                programHybridExercisesRefs = false,
                workoutsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (programStrengthExercisesRefs)
                      db.programStrengthExercises,
                    if (programCardioExercisesRefs) db.programCardioExercises,
                    if (programHybridExercisesRefs) db.programHybridExercises,
                    if (workoutsRefs) db.workouts,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (programId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.programId,
                                    referencedTable:
                                        $$WorkoutDaysTableReferences
                                            ._programIdTable(db),
                                    referencedColumn:
                                        $$WorkoutDaysTableReferences
                                            ._programIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (programStrengthExercisesRefs)
                        await $_getPrefetchedData<
                          WorkoutDay,
                          $WorkoutDaysTable,
                          ProgramStrengthExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutDaysTableReferences
                              ._programStrengthExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).programStrengthExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programCardioExercisesRefs)
                        await $_getPrefetchedData<
                          WorkoutDay,
                          $WorkoutDaysTable,
                          ProgramCardioExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutDaysTableReferences
                              ._programCardioExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).programCardioExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programHybridExercisesRefs)
                        await $_getPrefetchedData<
                          WorkoutDay,
                          $WorkoutDaysTable,
                          ProgramHybridExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutDaysTableReferences
                              ._programHybridExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).programHybridExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutsRefs)
                        await $_getPrefetchedData<
                          WorkoutDay,
                          $WorkoutDaysTable,
                          Workout
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutDaysTableReferences
                              ._workoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutDaysTable,
      WorkoutDay,
      $$WorkoutDaysTableFilterComposer,
      $$WorkoutDaysTableOrderingComposer,
      $$WorkoutDaysTableAnnotationComposer,
      $$WorkoutDaysTableCreateCompanionBuilder,
      $$WorkoutDaysTableUpdateCompanionBuilder,
      (WorkoutDay, $$WorkoutDaysTableReferences),
      WorkoutDay,
      PrefetchHooks Function({
        bool programId,
        bool programStrengthExercisesRefs,
        bool programCardioExercisesRefs,
        bool programHybridExercisesRefs,
        bool workoutsRefs,
      })
    >;
typedef $$ProgramStrengthExercisesTableCreateCompanionBuilder =
    ProgramStrengthExercisesCompanion Function({
      Value<String> id,
      required String workoutDayId,
      Value<String?> equipmentId,
      required String exerciseId,
      Value<int> orderInProgram,
      Value<String> setsReps,
      Value<int?> restTimer,
      Value<double> weight,
      Value<int> rowid,
    });
typedef $$ProgramStrengthExercisesTableUpdateCompanionBuilder =
    ProgramStrengthExercisesCompanion Function({
      Value<String> id,
      Value<String> workoutDayId,
      Value<String?> equipmentId,
      Value<String> exerciseId,
      Value<int> orderInProgram,
      Value<String> setsReps,
      Value<int?> restTimer,
      Value<double> weight,
      Value<int> rowid,
    });

final class $$ProgramStrengthExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProgramStrengthExercisesTable,
          ProgramStrengthExercise
        > {
  $$ProgramStrengthExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutDaysTable _workoutDayIdTable(_$AppDatabase db) =>
      db.workoutDays.createAlias(
        $_aliasNameGenerator(
          db.programStrengthExercises.workoutDayId,
          db.workoutDays.id,
        ),
      );

  $$WorkoutDaysTableProcessedTableManager get workoutDayId {
    final $_column = $_itemColumn<String>('workout_day_id')!;

    final manager = $$WorkoutDaysTableTableManager(
      $_db,
      $_db.workoutDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentsTable _equipmentIdTable(_$AppDatabase db) =>
      db.equipments.createAlias(
        $_aliasNameGenerator(
          db.programStrengthExercises.equipmentId,
          db.equipments.id,
        ),
      );

  $$EquipmentsTableProcessedTableManager? get equipmentId {
    final $_column = $_itemColumn<String>('equipment_id');
    if ($_column == null) return null;
    final manager = $$EquipmentsTableTableManager(
      $_db,
      $_db.equipments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(
          db.programStrengthExercises.exerciseId,
          db.exercises.id,
        ),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgramStrengthExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramStrengthExercisesTable> {
  $$ProgramStrengthExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setsReps => $composableBuilder(
    column: $table.setsReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restTimer => $composableBuilder(
    column: $table.restTimer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutDaysTableFilterComposer get workoutDayId {
    final $$WorkoutDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableFilterComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableFilterComposer get equipmentId {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableFilterComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramStrengthExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramStrengthExercisesTable> {
  $$ProgramStrengthExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setsReps => $composableBuilder(
    column: $table.setsReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restTimer => $composableBuilder(
    column: $table.restTimer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutDaysTableOrderingComposer get workoutDayId {
    final $$WorkoutDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableOrderingComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableOrderingComposer get equipmentId {
    final $$EquipmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableOrderingComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramStrengthExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramStrengthExercisesTable> {
  $$ProgramStrengthExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => column,
  );

  GeneratedColumn<String> get setsReps =>
      $composableBuilder(column: $table.setsReps, builder: (column) => column);

  GeneratedColumn<int> get restTimer =>
      $composableBuilder(column: $table.restTimer, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  $$WorkoutDaysTableAnnotationComposer get workoutDayId {
    final $$WorkoutDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableAnnotationComposer get equipmentId {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramStrengthExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramStrengthExercisesTable,
          ProgramStrengthExercise,
          $$ProgramStrengthExercisesTableFilterComposer,
          $$ProgramStrengthExercisesTableOrderingComposer,
          $$ProgramStrengthExercisesTableAnnotationComposer,
          $$ProgramStrengthExercisesTableCreateCompanionBuilder,
          $$ProgramStrengthExercisesTableUpdateCompanionBuilder,
          (ProgramStrengthExercise, $$ProgramStrengthExercisesTableReferences),
          ProgramStrengthExercise,
          PrefetchHooks Function({
            bool workoutDayId,
            bool equipmentId,
            bool exerciseId,
          })
        > {
  $$ProgramStrengthExercisesTableTableManager(
    _$AppDatabase db,
    $ProgramStrengthExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramStrengthExercisesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProgramStrengthExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProgramStrengthExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutDayId = const Value.absent(),
                Value<String?> equipmentId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderInProgram = const Value.absent(),
                Value<String> setsReps = const Value.absent(),
                Value<int?> restTimer = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramStrengthExercisesCompanion(
                id: id,
                workoutDayId: workoutDayId,
                equipmentId: equipmentId,
                exerciseId: exerciseId,
                orderInProgram: orderInProgram,
                setsReps: setsReps,
                restTimer: restTimer,
                weight: weight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String workoutDayId,
                Value<String?> equipmentId = const Value.absent(),
                required String exerciseId,
                Value<int> orderInProgram = const Value.absent(),
                Value<String> setsReps = const Value.absent(),
                Value<int?> restTimer = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramStrengthExercisesCompanion.insert(
                id: id,
                workoutDayId: workoutDayId,
                equipmentId: equipmentId,
                exerciseId: exerciseId,
                orderInProgram: orderInProgram,
                setsReps: setsReps,
                restTimer: restTimer,
                weight: weight,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramStrengthExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutDayId = false,
                equipmentId = false,
                exerciseId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutDayId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutDayId,
                                    referencedTable:
                                        $$ProgramStrengthExercisesTableReferences
                                            ._workoutDayIdTable(db),
                                    referencedColumn:
                                        $$ProgramStrengthExercisesTableReferences
                                            ._workoutDayIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (equipmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.equipmentId,
                                    referencedTable:
                                        $$ProgramStrengthExercisesTableReferences
                                            ._equipmentIdTable(db),
                                    referencedColumn:
                                        $$ProgramStrengthExercisesTableReferences
                                            ._equipmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$ProgramStrengthExercisesTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$ProgramStrengthExercisesTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ProgramStrengthExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramStrengthExercisesTable,
      ProgramStrengthExercise,
      $$ProgramStrengthExercisesTableFilterComposer,
      $$ProgramStrengthExercisesTableOrderingComposer,
      $$ProgramStrengthExercisesTableAnnotationComposer,
      $$ProgramStrengthExercisesTableCreateCompanionBuilder,
      $$ProgramStrengthExercisesTableUpdateCompanionBuilder,
      (ProgramStrengthExercise, $$ProgramStrengthExercisesTableReferences),
      ProgramStrengthExercise,
      PrefetchHooks Function({
        bool workoutDayId,
        bool equipmentId,
        bool exerciseId,
      })
    >;
typedef $$ProgramCardioExercisesTableCreateCompanionBuilder =
    ProgramCardioExercisesCompanion Function({
      Value<String> id,
      required String workoutDayId,
      required String exerciseId,
      Value<int> orderInProgram,
      Value<int?> seconds,
      Value<double?> distancePlanned,
      Value<String> distancePlannedUnit,
      Value<int> rowid,
    });
typedef $$ProgramCardioExercisesTableUpdateCompanionBuilder =
    ProgramCardioExercisesCompanion Function({
      Value<String> id,
      Value<String> workoutDayId,
      Value<String> exerciseId,
      Value<int> orderInProgram,
      Value<int?> seconds,
      Value<double?> distancePlanned,
      Value<String> distancePlannedUnit,
      Value<int> rowid,
    });

final class $$ProgramCardioExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProgramCardioExercisesTable,
          ProgramCardioExercise
        > {
  $$ProgramCardioExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutDaysTable _workoutDayIdTable(_$AppDatabase db) =>
      db.workoutDays.createAlias(
        $_aliasNameGenerator(
          db.programCardioExercises.workoutDayId,
          db.workoutDays.id,
        ),
      );

  $$WorkoutDaysTableProcessedTableManager get workoutDayId {
    final $_column = $_itemColumn<String>('workout_day_id')!;

    final manager = $$WorkoutDaysTableTableManager(
      $_db,
      $_db.workoutDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(
          db.programCardioExercises.exerciseId,
          db.exercises.id,
        ),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgramCardioExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramCardioExercisesTable> {
  $$ProgramCardioExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distancePlanned => $composableBuilder(
    column: $table.distancePlanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distancePlannedUnit => $composableBuilder(
    column: $table.distancePlannedUnit,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutDaysTableFilterComposer get workoutDayId {
    final $$WorkoutDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableFilterComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramCardioExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramCardioExercisesTable> {
  $$ProgramCardioExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distancePlanned => $composableBuilder(
    column: $table.distancePlanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distancePlannedUnit => $composableBuilder(
    column: $table.distancePlannedUnit,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutDaysTableOrderingComposer get workoutDayId {
    final $$WorkoutDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableOrderingComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramCardioExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramCardioExercisesTable> {
  $$ProgramCardioExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);

  GeneratedColumn<double> get distancePlanned => $composableBuilder(
    column: $table.distancePlanned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get distancePlannedUnit => $composableBuilder(
    column: $table.distancePlannedUnit,
    builder: (column) => column,
  );

  $$WorkoutDaysTableAnnotationComposer get workoutDayId {
    final $$WorkoutDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramCardioExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramCardioExercisesTable,
          ProgramCardioExercise,
          $$ProgramCardioExercisesTableFilterComposer,
          $$ProgramCardioExercisesTableOrderingComposer,
          $$ProgramCardioExercisesTableAnnotationComposer,
          $$ProgramCardioExercisesTableCreateCompanionBuilder,
          $$ProgramCardioExercisesTableUpdateCompanionBuilder,
          (ProgramCardioExercise, $$ProgramCardioExercisesTableReferences),
          ProgramCardioExercise,
          PrefetchHooks Function({bool workoutDayId, bool exerciseId})
        > {
  $$ProgramCardioExercisesTableTableManager(
    _$AppDatabase db,
    $ProgramCardioExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramCardioExercisesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProgramCardioExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProgramCardioExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutDayId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderInProgram = const Value.absent(),
                Value<int?> seconds = const Value.absent(),
                Value<double?> distancePlanned = const Value.absent(),
                Value<String> distancePlannedUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramCardioExercisesCompanion(
                id: id,
                workoutDayId: workoutDayId,
                exerciseId: exerciseId,
                orderInProgram: orderInProgram,
                seconds: seconds,
                distancePlanned: distancePlanned,
                distancePlannedUnit: distancePlannedUnit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String workoutDayId,
                required String exerciseId,
                Value<int> orderInProgram = const Value.absent(),
                Value<int?> seconds = const Value.absent(),
                Value<double?> distancePlanned = const Value.absent(),
                Value<String> distancePlannedUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramCardioExercisesCompanion.insert(
                id: id,
                workoutDayId: workoutDayId,
                exerciseId: exerciseId,
                orderInProgram: orderInProgram,
                seconds: seconds,
                distancePlanned: distancePlanned,
                distancePlannedUnit: distancePlannedUnit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramCardioExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutDayId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutDayId,
                                referencedTable:
                                    $$ProgramCardioExercisesTableReferences
                                        ._workoutDayIdTable(db),
                                referencedColumn:
                                    $$ProgramCardioExercisesTableReferences
                                        ._workoutDayIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$ProgramCardioExercisesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$ProgramCardioExercisesTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProgramCardioExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramCardioExercisesTable,
      ProgramCardioExercise,
      $$ProgramCardioExercisesTableFilterComposer,
      $$ProgramCardioExercisesTableOrderingComposer,
      $$ProgramCardioExercisesTableAnnotationComposer,
      $$ProgramCardioExercisesTableCreateCompanionBuilder,
      $$ProgramCardioExercisesTableUpdateCompanionBuilder,
      (ProgramCardioExercise, $$ProgramCardioExercisesTableReferences),
      ProgramCardioExercise,
      PrefetchHooks Function({bool workoutDayId, bool exerciseId})
    >;
typedef $$ProgramHybridExercisesTableCreateCompanionBuilder =
    ProgramHybridExercisesCompanion Function({
      Value<String> id,
      required String workoutDayId,
      Value<String?> equipmentId,
      required String exerciseId,
      Value<int> orderInProgram,
      Value<String> setsDistances,
      Value<String> distanceUnit,
      Value<int?> restTimer,
      Value<double> weight,
      Value<int> rowid,
    });
typedef $$ProgramHybridExercisesTableUpdateCompanionBuilder =
    ProgramHybridExercisesCompanion Function({
      Value<String> id,
      Value<String> workoutDayId,
      Value<String?> equipmentId,
      Value<String> exerciseId,
      Value<int> orderInProgram,
      Value<String> setsDistances,
      Value<String> distanceUnit,
      Value<int?> restTimer,
      Value<double> weight,
      Value<int> rowid,
    });

final class $$ProgramHybridExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProgramHybridExercisesTable,
          ProgramHybridExercise
        > {
  $$ProgramHybridExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutDaysTable _workoutDayIdTable(_$AppDatabase db) =>
      db.workoutDays.createAlias(
        $_aliasNameGenerator(
          db.programHybridExercises.workoutDayId,
          db.workoutDays.id,
        ),
      );

  $$WorkoutDaysTableProcessedTableManager get workoutDayId {
    final $_column = $_itemColumn<String>('workout_day_id')!;

    final manager = $$WorkoutDaysTableTableManager(
      $_db,
      $_db.workoutDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentsTable _equipmentIdTable(_$AppDatabase db) =>
      db.equipments.createAlias(
        $_aliasNameGenerator(
          db.programHybridExercises.equipmentId,
          db.equipments.id,
        ),
      );

  $$EquipmentsTableProcessedTableManager? get equipmentId {
    final $_column = $_itemColumn<String>('equipment_id');
    if ($_column == null) return null;
    final manager = $$EquipmentsTableTableManager(
      $_db,
      $_db.equipments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(
          db.programHybridExercises.exerciseId,
          db.exercises.id,
        ),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgramHybridExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramHybridExercisesTable> {
  $$ProgramHybridExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setsDistances => $composableBuilder(
    column: $table.setsDistances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restTimer => $composableBuilder(
    column: $table.restTimer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutDaysTableFilterComposer get workoutDayId {
    final $$WorkoutDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableFilterComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableFilterComposer get equipmentId {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableFilterComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramHybridExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramHybridExercisesTable> {
  $$ProgramHybridExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setsDistances => $composableBuilder(
    column: $table.setsDistances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restTimer => $composableBuilder(
    column: $table.restTimer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutDaysTableOrderingComposer get workoutDayId {
    final $$WorkoutDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableOrderingComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableOrderingComposer get equipmentId {
    final $$EquipmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableOrderingComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramHybridExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramHybridExercisesTable> {
  $$ProgramHybridExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderInProgram => $composableBuilder(
    column: $table.orderInProgram,
    builder: (column) => column,
  );

  GeneratedColumn<String> get setsDistances => $composableBuilder(
    column: $table.setsDistances,
    builder: (column) => column,
  );

  GeneratedColumn<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restTimer =>
      $composableBuilder(column: $table.restTimer, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  $$WorkoutDaysTableAnnotationComposer get workoutDayId {
    final $$WorkoutDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableAnnotationComposer get equipmentId {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramHybridExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramHybridExercisesTable,
          ProgramHybridExercise,
          $$ProgramHybridExercisesTableFilterComposer,
          $$ProgramHybridExercisesTableOrderingComposer,
          $$ProgramHybridExercisesTableAnnotationComposer,
          $$ProgramHybridExercisesTableCreateCompanionBuilder,
          $$ProgramHybridExercisesTableUpdateCompanionBuilder,
          (ProgramHybridExercise, $$ProgramHybridExercisesTableReferences),
          ProgramHybridExercise,
          PrefetchHooks Function({
            bool workoutDayId,
            bool equipmentId,
            bool exerciseId,
          })
        > {
  $$ProgramHybridExercisesTableTableManager(
    _$AppDatabase db,
    $ProgramHybridExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramHybridExercisesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProgramHybridExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProgramHybridExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutDayId = const Value.absent(),
                Value<String?> equipmentId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderInProgram = const Value.absent(),
                Value<String> setsDistances = const Value.absent(),
                Value<String> distanceUnit = const Value.absent(),
                Value<int?> restTimer = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramHybridExercisesCompanion(
                id: id,
                workoutDayId: workoutDayId,
                equipmentId: equipmentId,
                exerciseId: exerciseId,
                orderInProgram: orderInProgram,
                setsDistances: setsDistances,
                distanceUnit: distanceUnit,
                restTimer: restTimer,
                weight: weight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String workoutDayId,
                Value<String?> equipmentId = const Value.absent(),
                required String exerciseId,
                Value<int> orderInProgram = const Value.absent(),
                Value<String> setsDistances = const Value.absent(),
                Value<String> distanceUnit = const Value.absent(),
                Value<int?> restTimer = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramHybridExercisesCompanion.insert(
                id: id,
                workoutDayId: workoutDayId,
                equipmentId: equipmentId,
                exerciseId: exerciseId,
                orderInProgram: orderInProgram,
                setsDistances: setsDistances,
                distanceUnit: distanceUnit,
                restTimer: restTimer,
                weight: weight,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramHybridExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutDayId = false,
                equipmentId = false,
                exerciseId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutDayId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutDayId,
                                    referencedTable:
                                        $$ProgramHybridExercisesTableReferences
                                            ._workoutDayIdTable(db),
                                    referencedColumn:
                                        $$ProgramHybridExercisesTableReferences
                                            ._workoutDayIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (equipmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.equipmentId,
                                    referencedTable:
                                        $$ProgramHybridExercisesTableReferences
                                            ._equipmentIdTable(db),
                                    referencedColumn:
                                        $$ProgramHybridExercisesTableReferences
                                            ._equipmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$ProgramHybridExercisesTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$ProgramHybridExercisesTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ProgramHybridExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramHybridExercisesTable,
      ProgramHybridExercise,
      $$ProgramHybridExercisesTableFilterComposer,
      $$ProgramHybridExercisesTableOrderingComposer,
      $$ProgramHybridExercisesTableAnnotationComposer,
      $$ProgramHybridExercisesTableCreateCompanionBuilder,
      $$ProgramHybridExercisesTableUpdateCompanionBuilder,
      (ProgramHybridExercise, $$ProgramHybridExercisesTableReferences),
      ProgramHybridExercise,
      PrefetchHooks Function({
        bool workoutDayId,
        bool equipmentId,
        bool exerciseId,
      })
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<String> id,
      required String workoutDayId,
      Value<DateTime> date,
      Value<int> rowid,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<String> id,
      Value<String> workoutDayId,
      Value<DateTime> date,
      Value<int> rowid,
    });

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutDaysTable _workoutDayIdTable(_$AppDatabase db) =>
      db.workoutDays.createAlias(
        $_aliasNameGenerator(db.workouts.workoutDayId, db.workoutDays.id),
      );

  $$WorkoutDaysTableProcessedTableManager get workoutDayId {
    final $_column = $_itemColumn<String>('workout_day_id')!;

    final manager = $$WorkoutDaysTableTableManager(
      $_db,
      $_db.workoutDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $WorkoutStrengthSetsTable,
    List<WorkoutStrengthSet>
  >
  _workoutStrengthSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutStrengthSets,
        aliasName: $_aliasNameGenerator(
          db.workouts.id,
          db.workoutStrengthSets.workoutId,
        ),
      );

  $$WorkoutStrengthSetsTableProcessedTableManager get workoutStrengthSetsRefs {
    final manager = $$WorkoutStrengthSetsTableTableManager(
      $_db,
      $_db.workoutStrengthSets,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutStrengthSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutCardioSetsTable, List<WorkoutCardioSet>>
  _workoutCardioSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutCardioSets,
        aliasName: $_aliasNameGenerator(
          db.workouts.id,
          db.workoutCardioSets.workoutId,
        ),
      );

  $$WorkoutCardioSetsTableProcessedTableManager get workoutCardioSetsRefs {
    final manager = $$WorkoutCardioSetsTableTableManager(
      $_db,
      $_db.workoutCardioSets,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutCardioSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutHybridSetsTable, List<WorkoutHybridSet>>
  _workoutHybridSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutHybridSets,
        aliasName: $_aliasNameGenerator(
          db.workouts.id,
          db.workoutHybridSets.workoutId,
        ),
      );

  $$WorkoutHybridSetsTableProcessedTableManager get workoutHybridSetsRefs {
    final manager = $$WorkoutHybridSetsTableTableManager(
      $_db,
      $_db.workoutHybridSets,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutHybridSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutDaysTableFilterComposer get workoutDayId {
    final $$WorkoutDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableFilterComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutStrengthSetsRefs(
    Expression<bool> Function($$WorkoutStrengthSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutStrengthSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutStrengthSets,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutStrengthSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutStrengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutCardioSetsRefs(
    Expression<bool> Function($$WorkoutCardioSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutCardioSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutCardioSets,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutCardioSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutCardioSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutHybridSetsRefs(
    Expression<bool> Function($$WorkoutHybridSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutHybridSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutHybridSets,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutHybridSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutHybridSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutDaysTableOrderingComposer get workoutDayId {
    final $$WorkoutDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableOrderingComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$WorkoutDaysTableAnnotationComposer get workoutDayId {
    final $$WorkoutDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutDayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutStrengthSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutStrengthSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutStrengthSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutStrengthSets,
          getReferencedColumn: (t) => t.workoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutStrengthSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutStrengthSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutCardioSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutCardioSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutCardioSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutCardioSets,
          getReferencedColumn: (t) => t.workoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutCardioSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutCardioSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutHybridSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutHybridSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutHybridSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutHybridSets,
          getReferencedColumn: (t) => t.workoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutHybridSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutHybridSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          Workout,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (Workout, $$WorkoutsTableReferences),
          Workout,
          PrefetchHooks Function({
            bool workoutDayId,
            bool workoutStrengthSetsRefs,
            bool workoutCardioSetsRefs,
            bool workoutHybridSetsRefs,
          })
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutDayId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                workoutDayId: workoutDayId,
                date: date,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String workoutDayId,
                Value<DateTime> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                workoutDayId: workoutDayId,
                date: date,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutDayId = false,
                workoutStrengthSetsRefs = false,
                workoutCardioSetsRefs = false,
                workoutHybridSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutStrengthSetsRefs) db.workoutStrengthSets,
                    if (workoutCardioSetsRefs) db.workoutCardioSets,
                    if (workoutHybridSetsRefs) db.workoutHybridSets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutDayId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutDayId,
                                    referencedTable: $$WorkoutsTableReferences
                                        ._workoutDayIdTable(db),
                                    referencedColumn: $$WorkoutsTableReferences
                                        ._workoutDayIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutStrengthSetsRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          WorkoutStrengthSet
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._workoutStrengthSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutStrengthSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutCardioSetsRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          WorkoutCardioSet
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._workoutCardioSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutCardioSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutHybridSetsRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          WorkoutHybridSet
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._workoutHybridSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutHybridSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      Workout,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (Workout, $$WorkoutsTableReferences),
      Workout,
      PrefetchHooks Function({
        bool workoutDayId,
        bool workoutStrengthSetsRefs,
        bool workoutCardioSetsRefs,
        bool workoutHybridSetsRefs,
      })
    >;
typedef $$WorkoutStrengthSetsTableCreateCompanionBuilder =
    WorkoutStrengthSetsCompanion Function({
      Value<String> id,
      required String workoutId,
      required String exerciseId,
      Value<String?> equipmentId,
      required int reps,
      required double weight,
      required int setNumber,
      Value<bool> isCompleted,
      Value<DateTime> dateLogged,
      Value<int> rowid,
    });
typedef $$WorkoutStrengthSetsTableUpdateCompanionBuilder =
    WorkoutStrengthSetsCompanion Function({
      Value<String> id,
      Value<String> workoutId,
      Value<String> exerciseId,
      Value<String?> equipmentId,
      Value<int> reps,
      Value<double> weight,
      Value<int> setNumber,
      Value<bool> isCompleted,
      Value<DateTime> dateLogged,
      Value<int> rowid,
    });

final class $$WorkoutStrengthSetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutStrengthSetsTable,
          WorkoutStrengthSet
        > {
  $$WorkoutStrengthSetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
        $_aliasNameGenerator(db.workoutStrengthSets.workoutId, db.workouts.id),
      );

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workout_id')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(
          db.workoutStrengthSets.exerciseId,
          db.exercises.id,
        ),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentsTable _equipmentIdTable(_$AppDatabase db) =>
      db.equipments.createAlias(
        $_aliasNameGenerator(
          db.workoutStrengthSets.equipmentId,
          db.equipments.id,
        ),
      );

  $$EquipmentsTableProcessedTableManager? get equipmentId {
    final $_column = $_itemColumn<String>('equipment_id');
    if ($_column == null) return null;
    final manager = $$EquipmentsTableTableManager(
      $_db,
      $_db.equipments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutStrengthSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutStrengthSetsTable> {
  $$WorkoutStrengthSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableFilterComposer get equipmentId {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableFilterComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutStrengthSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutStrengthSetsTable> {
  $$WorkoutStrengthSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableOrderingComposer get equipmentId {
    final $$EquipmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableOrderingComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutStrengthSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutStrengthSetsTable> {
  $$WorkoutStrengthSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => column,
  );

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableAnnotationComposer get equipmentId {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutStrengthSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutStrengthSetsTable,
          WorkoutStrengthSet,
          $$WorkoutStrengthSetsTableFilterComposer,
          $$WorkoutStrengthSetsTableOrderingComposer,
          $$WorkoutStrengthSetsTableAnnotationComposer,
          $$WorkoutStrengthSetsTableCreateCompanionBuilder,
          $$WorkoutStrengthSetsTableUpdateCompanionBuilder,
          (WorkoutStrengthSet, $$WorkoutStrengthSetsTableReferences),
          WorkoutStrengthSet,
          PrefetchHooks Function({
            bool workoutId,
            bool exerciseId,
            bool equipmentId,
          })
        > {
  $$WorkoutStrengthSetsTableTableManager(
    _$AppDatabase db,
    $WorkoutStrengthSetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutStrengthSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutStrengthSetsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkoutStrengthSetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String?> equipmentId = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> dateLogged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutStrengthSetsCompanion(
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                reps: reps,
                weight: weight,
                setNumber: setNumber,
                isCompleted: isCompleted,
                dateLogged: dateLogged,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String workoutId,
                required String exerciseId,
                Value<String?> equipmentId = const Value.absent(),
                required int reps,
                required double weight,
                required int setNumber,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> dateLogged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutStrengthSetsCompanion.insert(
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                reps: reps,
                weight: weight,
                setNumber: setNumber,
                isCompleted: isCompleted,
                dateLogged: dateLogged,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutStrengthSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutId = false, exerciseId = false, equipmentId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutId,
                                    referencedTable:
                                        $$WorkoutStrengthSetsTableReferences
                                            ._workoutIdTable(db),
                                    referencedColumn:
                                        $$WorkoutStrengthSetsTableReferences
                                            ._workoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$WorkoutStrengthSetsTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$WorkoutStrengthSetsTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (equipmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.equipmentId,
                                    referencedTable:
                                        $$WorkoutStrengthSetsTableReferences
                                            ._equipmentIdTable(db),
                                    referencedColumn:
                                        $$WorkoutStrengthSetsTableReferences
                                            ._equipmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutStrengthSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutStrengthSetsTable,
      WorkoutStrengthSet,
      $$WorkoutStrengthSetsTableFilterComposer,
      $$WorkoutStrengthSetsTableOrderingComposer,
      $$WorkoutStrengthSetsTableAnnotationComposer,
      $$WorkoutStrengthSetsTableCreateCompanionBuilder,
      $$WorkoutStrengthSetsTableUpdateCompanionBuilder,
      (WorkoutStrengthSet, $$WorkoutStrengthSetsTableReferences),
      WorkoutStrengthSet,
      PrefetchHooks Function({
        bool workoutId,
        bool exerciseId,
        bool equipmentId,
      })
    >;
typedef $$WorkoutCardioSetsTableCreateCompanionBuilder =
    WorkoutCardioSetsCompanion Function({
      Value<String> id,
      required String workoutId,
      required String exerciseId,
      required int durationSeconds,
      Value<double?> distanceMeters,
      Value<String> distanceUnit,
      Value<bool> isCompleted,
      Value<DateTime> dateLogged,
      Value<int> rowid,
    });
typedef $$WorkoutCardioSetsTableUpdateCompanionBuilder =
    WorkoutCardioSetsCompanion Function({
      Value<String> id,
      Value<String> workoutId,
      Value<String> exerciseId,
      Value<int> durationSeconds,
      Value<double?> distanceMeters,
      Value<String> distanceUnit,
      Value<bool> isCompleted,
      Value<DateTime> dateLogged,
      Value<int> rowid,
    });

final class $$WorkoutCardioSetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutCardioSetsTable,
          WorkoutCardioSet
        > {
  $$WorkoutCardioSetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
        $_aliasNameGenerator(db.workoutCardioSets.workoutId, db.workouts.id),
      );

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workout_id')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.workoutCardioSets.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutCardioSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutCardioSetsTable> {
  $$WorkoutCardioSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutCardioSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutCardioSetsTable> {
  $$WorkoutCardioSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutCardioSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutCardioSetsTable> {
  $$WorkoutCardioSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => column,
  );

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutCardioSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutCardioSetsTable,
          WorkoutCardioSet,
          $$WorkoutCardioSetsTableFilterComposer,
          $$WorkoutCardioSetsTableOrderingComposer,
          $$WorkoutCardioSetsTableAnnotationComposer,
          $$WorkoutCardioSetsTableCreateCompanionBuilder,
          $$WorkoutCardioSetsTableUpdateCompanionBuilder,
          (WorkoutCardioSet, $$WorkoutCardioSetsTableReferences),
          WorkoutCardioSet,
          PrefetchHooks Function({bool workoutId, bool exerciseId})
        > {
  $$WorkoutCardioSetsTableTableManager(
    _$AppDatabase db,
    $WorkoutCardioSetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutCardioSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutCardioSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutCardioSetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<String> distanceUnit = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> dateLogged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutCardioSetsCompanion(
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                distanceUnit: distanceUnit,
                isCompleted: isCompleted,
                dateLogged: dateLogged,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String workoutId,
                required String exerciseId,
                required int durationSeconds,
                Value<double?> distanceMeters = const Value.absent(),
                Value<String> distanceUnit = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> dateLogged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutCardioSetsCompanion.insert(
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                distanceUnit: distanceUnit,
                isCompleted: isCompleted,
                dateLogged: dateLogged,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutCardioSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable:
                                    $$WorkoutCardioSetsTableReferences
                                        ._workoutIdTable(db),
                                referencedColumn:
                                    $$WorkoutCardioSetsTableReferences
                                        ._workoutIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$WorkoutCardioSetsTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$WorkoutCardioSetsTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutCardioSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutCardioSetsTable,
      WorkoutCardioSet,
      $$WorkoutCardioSetsTableFilterComposer,
      $$WorkoutCardioSetsTableOrderingComposer,
      $$WorkoutCardioSetsTableAnnotationComposer,
      $$WorkoutCardioSetsTableCreateCompanionBuilder,
      $$WorkoutCardioSetsTableUpdateCompanionBuilder,
      (WorkoutCardioSet, $$WorkoutCardioSetsTableReferences),
      WorkoutCardioSet,
      PrefetchHooks Function({bool workoutId, bool exerciseId})
    >;
typedef $$WorkoutHybridSetsTableCreateCompanionBuilder =
    WorkoutHybridSetsCompanion Function({
      Value<String> id,
      required String workoutId,
      required String exerciseId,
      Value<String?> equipmentId,
      required int setNumber,
      required double weight,
      required double distance,
      Value<String> distanceUnit,
      Value<double?> distanceMeters,
      Value<bool> isCompleted,
      Value<DateTime> dateLogged,
      Value<int> rowid,
    });
typedef $$WorkoutHybridSetsTableUpdateCompanionBuilder =
    WorkoutHybridSetsCompanion Function({
      Value<String> id,
      Value<String> workoutId,
      Value<String> exerciseId,
      Value<String?> equipmentId,
      Value<int> setNumber,
      Value<double> weight,
      Value<double> distance,
      Value<String> distanceUnit,
      Value<double?> distanceMeters,
      Value<bool> isCompleted,
      Value<DateTime> dateLogged,
      Value<int> rowid,
    });

final class $$WorkoutHybridSetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutHybridSetsTable,
          WorkoutHybridSet
        > {
  $$WorkoutHybridSetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
        $_aliasNameGenerator(db.workoutHybridSets.workoutId, db.workouts.id),
      );

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workout_id')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.workoutHybridSets.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentsTable _equipmentIdTable(_$AppDatabase db) =>
      db.equipments.createAlias(
        $_aliasNameGenerator(
          db.workoutHybridSets.equipmentId,
          db.equipments.id,
        ),
      );

  $$EquipmentsTableProcessedTableManager? get equipmentId {
    final $_column = $_itemColumn<String>('equipment_id');
    if ($_column == null) return null;
    final manager = $$EquipmentsTableTableManager(
      $_db,
      $_db.equipments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutHybridSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutHybridSetsTable> {
  $$WorkoutHybridSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableFilterComposer get equipmentId {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableFilterComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutHybridSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutHybridSetsTable> {
  $$WorkoutHybridSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableOrderingComposer get equipmentId {
    final $$EquipmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableOrderingComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutHybridSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutHybridSetsTable> {
  $$WorkoutHybridSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateLogged => $composableBuilder(
    column: $table.dateLogged,
    builder: (column) => column,
  );

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableAnnotationComposer get equipmentId {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutHybridSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutHybridSetsTable,
          WorkoutHybridSet,
          $$WorkoutHybridSetsTableFilterComposer,
          $$WorkoutHybridSetsTableOrderingComposer,
          $$WorkoutHybridSetsTableAnnotationComposer,
          $$WorkoutHybridSetsTableCreateCompanionBuilder,
          $$WorkoutHybridSetsTableUpdateCompanionBuilder,
          (WorkoutHybridSet, $$WorkoutHybridSetsTableReferences),
          WorkoutHybridSet,
          PrefetchHooks Function({
            bool workoutId,
            bool exerciseId,
            bool equipmentId,
          })
        > {
  $$WorkoutHybridSetsTableTableManager(
    _$AppDatabase db,
    $WorkoutHybridSetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutHybridSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutHybridSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutHybridSetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String?> equipmentId = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<double> distance = const Value.absent(),
                Value<String> distanceUnit = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> dateLogged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutHybridSetsCompanion(
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                setNumber: setNumber,
                weight: weight,
                distance: distance,
                distanceUnit: distanceUnit,
                distanceMeters: distanceMeters,
                isCompleted: isCompleted,
                dateLogged: dateLogged,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String workoutId,
                required String exerciseId,
                Value<String?> equipmentId = const Value.absent(),
                required int setNumber,
                required double weight,
                required double distance,
                Value<String> distanceUnit = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> dateLogged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutHybridSetsCompanion.insert(
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                setNumber: setNumber,
                weight: weight,
                distance: distance,
                distanceUnit: distanceUnit,
                distanceMeters: distanceMeters,
                isCompleted: isCompleted,
                dateLogged: dateLogged,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutHybridSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutId = false, exerciseId = false, equipmentId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutId,
                                    referencedTable:
                                        $$WorkoutHybridSetsTableReferences
                                            ._workoutIdTable(db),
                                    referencedColumn:
                                        $$WorkoutHybridSetsTableReferences
                                            ._workoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$WorkoutHybridSetsTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$WorkoutHybridSetsTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (equipmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.equipmentId,
                                    referencedTable:
                                        $$WorkoutHybridSetsTableReferences
                                            ._equipmentIdTable(db),
                                    referencedColumn:
                                        $$WorkoutHybridSetsTableReferences
                                            ._equipmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutHybridSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutHybridSetsTable,
      WorkoutHybridSet,
      $$WorkoutHybridSetsTableFilterComposer,
      $$WorkoutHybridSetsTableOrderingComposer,
      $$WorkoutHybridSetsTableAnnotationComposer,
      $$WorkoutHybridSetsTableCreateCompanionBuilder,
      $$WorkoutHybridSetsTableUpdateCompanionBuilder,
      (WorkoutHybridSet, $$WorkoutHybridSetsTableReferences),
      WorkoutHybridSet,
      PrefetchHooks Function({
        bool workoutId,
        bool exerciseId,
        bool equipmentId,
      })
    >;
typedef $$BodyweightEntriesTableCreateCompanionBuilder =
    BodyweightEntriesCompanion Function({
      Value<String> id,
      required DateTime date,
      required double weight,
      Value<int> rowid,
    });
typedef $$BodyweightEntriesTableUpdateCompanionBuilder =
    BodyweightEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<double> weight,
      Value<int> rowid,
    });

class $$BodyweightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BodyweightEntriesTable> {
  $$BodyweightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyweightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyweightEntriesTable> {
  $$BodyweightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyweightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyweightEntriesTable> {
  $$BodyweightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);
}

class $$BodyweightEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyweightEntriesTable,
          BodyweightEntry,
          $$BodyweightEntriesTableFilterComposer,
          $$BodyweightEntriesTableOrderingComposer,
          $$BodyweightEntriesTableAnnotationComposer,
          $$BodyweightEntriesTableCreateCompanionBuilder,
          $$BodyweightEntriesTableUpdateCompanionBuilder,
          (
            BodyweightEntry,
            BaseReferences<
              _$AppDatabase,
              $BodyweightEntriesTable,
              BodyweightEntry
            >,
          ),
          BodyweightEntry,
          PrefetchHooks Function()
        > {
  $$BodyweightEntriesTableTableManager(
    _$AppDatabase db,
    $BodyweightEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyweightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyweightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyweightEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyweightEntriesCompanion(
                id: id,
                date: date,
                weight: weight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime date,
                required double weight,
                Value<int> rowid = const Value.absent(),
              }) => BodyweightEntriesCompanion.insert(
                id: id,
                date: date,
                weight: weight,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyweightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyweightEntriesTable,
      BodyweightEntry,
      $$BodyweightEntriesTableFilterComposer,
      $$BodyweightEntriesTableOrderingComposer,
      $$BodyweightEntriesTableAnnotationComposer,
      $$BodyweightEntriesTableCreateCompanionBuilder,
      $$BodyweightEntriesTableUpdateCompanionBuilder,
      (
        BodyweightEntry,
        BaseReferences<_$AppDatabase, $BodyweightEntriesTable, BodyweightEntry>,
      ),
      BodyweightEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExerciseTypesTableTableManager get exerciseTypes =>
      $$ExerciseTypesTableTableManager(_db, _db.exerciseTypes);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$EquipmentsTableTableManager get equipments =>
      $$EquipmentsTableTableManager(_db, _db.equipments);
  $$MuscleGroupsTableTableManager get muscleGroups =>
      $$MuscleGroupsTableTableManager(_db, _db.muscleGroups);
  $$ExerciseMuscleGroupTableTableManager get exerciseMuscleGroup =>
      $$ExerciseMuscleGroupTableTableManager(_db, _db.exerciseMuscleGroup);
  $$ExerciseEquipmentTableTableManager get exerciseEquipment =>
      $$ExerciseEquipmentTableTableManager(_db, _db.exerciseEquipment);
  $$ProgramsTableTableManager get programs =>
      $$ProgramsTableTableManager(_db, _db.programs);
  $$WorkoutDaysTableTableManager get workoutDays =>
      $$WorkoutDaysTableTableManager(_db, _db.workoutDays);
  $$ProgramStrengthExercisesTableTableManager get programStrengthExercises =>
      $$ProgramStrengthExercisesTableTableManager(
        _db,
        _db.programStrengthExercises,
      );
  $$ProgramCardioExercisesTableTableManager get programCardioExercises =>
      $$ProgramCardioExercisesTableTableManager(
        _db,
        _db.programCardioExercises,
      );
  $$ProgramHybridExercisesTableTableManager get programHybridExercises =>
      $$ProgramHybridExercisesTableTableManager(
        _db,
        _db.programHybridExercises,
      );
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$WorkoutStrengthSetsTableTableManager get workoutStrengthSets =>
      $$WorkoutStrengthSetsTableTableManager(_db, _db.workoutStrengthSets);
  $$WorkoutCardioSetsTableTableManager get workoutCardioSets =>
      $$WorkoutCardioSetsTableTableManager(_db, _db.workoutCardioSets);
  $$WorkoutHybridSetsTableTableManager get workoutHybridSets =>
      $$WorkoutHybridSetsTableTableManager(_db, _db.workoutHybridSets);
  $$BodyweightEntriesTableTableManager get bodyweightEntries =>
      $$BodyweightEntriesTableTableManager(_db, _db.bodyweightEntries);
}
