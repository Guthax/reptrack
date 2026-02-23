import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:reptrack/persistance/database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  await db.transaction(() async {
    print("--- Starting Database Seed ---");

    // 1. Seed Muscle Groups
    final muscleNames = {
      1: 'Chest', 2: 'Back', 3: 'Bicep', 4: 'Tricep', 5: 'Shoulders', 6: 'Abs', 7: 'Legs'
    };
    for (var entry in muscleNames.entries) {
      await db.into(db.muscleGroups).insertOnConflictUpdate(
        MuscleGroupsCompanion.insert(id: Value(entry.key), name: entry.value),
      );
    }

    // 2. Seed Equipment
    final equipmentNames = {
      1: 'Bodyweight', 2: 'Barbell', 3: 'Dumbbells', 4: 'EZ-Bar', 5: 'Machine', 6: 'Cable', 7: 'Plate Loaded'
    };
    for (var entry in equipmentNames.entries) {
      await db.into(db.equipments).insertOnConflictUpdate(
        EquipmentsCompanion.insert(
          id: Value(entry.key), 
          name: entry.value, 
          icon_name: entry.value.toLowerCase().replaceAll(' ', '_'),
        ),
      );
    }

    // 3. Prevent Duplicates
    final allExisting = await db.select(db.exercises).get();
    final Set<String> existingNames = allExisting.map((e) => e.name.trim().toLowerCase()).toSet();

    try {
      final String rawData = await rootBundle.loadString('assets/data/exercises.csv');
      final lines = rawData.split(RegExp(r'\r?\n'));

      int addedCount = 0;

      for (var line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;

        final columns = _splitCsvLine(trimmedLine);
        if (columns.length < 4) continue;

        final String name = columns[0].trim();
        if (name.isEmpty || existingNames.contains(name.toLowerCase())) continue;

        try {
          final primaryId = int.parse(columns[1].trim());
          final secondaryId = columns[2].trim() == 'null' ? null : int.tryParse(columns[2].trim());
          
          // --- CRITICAL FIX FOR EQUIPMENT PARSING ---
          // Strip quotes, then split by comma, then trim each ID
          final String rawEquipColumn = columns[3];
          final cleanEquipStr = rawEquipColumn.replaceAll('"', '').trim();
          final List<int> equipIds = cleanEquipStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e))
              .toList();

          // A. Insert Exercise
          final exerciseId = await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              name: name,
              muscleGroup: Value(muscleNames[primaryId] ?? 'General'),
            ),
          );

          // B. Link Primary Muscle
          await db.into(db.exerciseMuscleGroup).insert(
            ExerciseMuscleGroupCompanion.insert(
              exerciseId: exerciseId,
              muscleGroupId: primaryId,
              focus: 'primary',
            ),
          );

          // C. Link Secondary Muscle
          if (secondaryId != null) {
            await db.into(db.exerciseMuscleGroup).insert(
              ExerciseMuscleGroupCompanion.insert(
                exerciseId: exerciseId,
                muscleGroupId: secondaryId,
                focus: 'secondary',
              ),
            );
          }

          // D. Link Equipment
          for (var eId in equipIds) {
            await db.into(db.exerciseEquipment).insert(
              ExerciseEquipmentCompanion.insert(
                exerciseId: exerciseId,
                equipmentId: eId,
              ),
            );
          }

          existingNames.add(name.toLowerCase());
          addedCount++;
        } catch (innerError) {
          print("Error parsing equipment for $name: $innerError");
        }
      }
      
      // Verification log
      final linkCount = await db.select(db.exerciseEquipment).get();
      print("--- SEED FINISHED ---");
      print("Exercises added: $addedCount");
      print("Total Equipment Links in DB: ${linkCount.length}");
      
    } catch (e) {
      print("CRITICAL SEED ERROR: $e");
    }
  });
}

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