import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:reptrack/persistance/database.dart';

/// Populates [db] with the static reference data needed on first launch.
///
/// Idempotent — uses insert-or-update for lookup tables and skips exercises
/// that already exist by name. Safe to call on every app start.
///
/// Seeds:
/// - Exercise types (Strength, Cardio)
/// - Muscle groups (Chest, Back, …)
/// - Equipment types (Bodyweight, Barbell, …)
/// - Exercises from `assets/data/exercises.csv`
Future<void> seedDatabase(AppDatabase db) async {
  await db.transaction(() async {
    final exerciseTypes = {1: 'Strength', 2: 'Cardio'};
    for (var entry in exerciseTypes.entries) {
      await db
          .into(db.exerciseTypes)
          .insertOnConflictUpdate(
            ExerciseTypesCompanion.insert(
              id: Value(entry.key),
              name: entry.value,
            ),
          );
    }

    final muscleNames = {
      1: 'Chest',
      2: 'Back',
      3: 'Bicep',
      4: 'Tricep',
      5: 'Shoulders',
      6: 'Abs',
      7: 'Legs',
    };
    for (var entry in muscleNames.entries) {
      await db
          .into(db.muscleGroups)
          .insertOnConflictUpdate(
            MuscleGroupsCompanion.insert(
              id: Value(entry.key),
              name: entry.value,
            ),
          );
    }

    final equipmentNames = {
      1: 'Bodyweight',
      2: 'Barbell',
      3: 'Dumbbells',
      4: 'EZ-Bar',
      5: 'Machine',
      6: 'Cable',
      7: 'Plate Loaded',
      8: 'Smith Machine',
    };
    for (var entry in equipmentNames.entries) {
      await db
          .into(db.equipments)
          .insertOnConflictUpdate(
            EquipmentsCompanion.insert(
              id: Value(entry.key),
              name: entry.value,
              iconName: entry.value.toLowerCase().replaceAll(' ', '_'),
            ),
          );
    }

    final allExisting = await db.select(db.exercises).get();
    final Set<String> existingNames = allExisting
        .map((e) => e.name.trim().toLowerCase())
        .toSet();

    try {
      final String rawData = await rootBundle.loadString(
        'assets/data/exercises.csv',
      );
      final lines = rawData.split(RegExp(r'\r?\n'));

      for (var line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) {
          continue;
        }

        final columns = _splitCsvLine(trimmedLine);
        if (columns.length < 5) {
          continue;
        }

        final String name = columns[0].trim();
        if (name.isEmpty || existingNames.contains(name.toLowerCase())) {
          continue;
        }

        try {
          final exerciseTypeId = int.tryParse(columns[1].trim());
          final primaryId = int.parse(columns[2].trim());
          final secondaryId = columns[3].trim() == 'null'
              ? null
              : int.tryParse(columns[3].trim());

          final String rawEquipColumn = columns[4];
          final cleanEquipStr = rawEquipColumn.replaceAll('"', '').trim();
          final List<int> equipIds = cleanEquipStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e))
              .toList();

          final exerciseId = await db
              .into(db.exercises)
              .insert(
                ExercisesCompanion.insert(
                  name: name,
                  exerciseTypeId: Value(exerciseTypeId),
                ),
              );

          await db
              .into(db.exerciseMuscleGroup)
              .insert(
                ExerciseMuscleGroupCompanion.insert(
                  exerciseId: exerciseId,
                  muscleGroupId: primaryId,
                  focus: 'primary',
                ),
              );

          if (secondaryId != null) {
            await db
                .into(db.exerciseMuscleGroup)
                .insert(
                  ExerciseMuscleGroupCompanion.insert(
                    exerciseId: exerciseId,
                    muscleGroupId: secondaryId,
                    focus: 'secondary',
                  ),
                );
          }

          for (var eId in equipIds) {
            await db
                .into(db.exerciseEquipment)
                .insert(
                  ExerciseEquipmentCompanion.insert(
                    exerciseId: exerciseId,
                    equipmentId: eId,
                  ),
                );
          }

          existingNames.add(name.toLowerCase());
        } catch (_) {}
      }
    } catch (_) {}
  });
}

/// Splits a single CSV [line] into fields, respecting double-quoted values.
List<String> _splitCsvLine(String line) {
  final result = <String>[];
  bool inQuotes = false;
  StringBuffer current = StringBuffer();

  for (int i = 0; i < line.length; i++) {
    String char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(current.toString().trim());
      current.clear();
    } else {
      current.write(char);
    }
  }
  result.add(current.toString().trim());
  return result;
}
