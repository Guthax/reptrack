import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';

class ActiveWorkoutController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final int workoutDayId;

  var exercisesWithVolume = <ExerciseWithVolume>[].obs;
  var isLoading = true.obs;
  var currentPageIndex = 0.obs;
  int? currentWorkoutId;

  // Key: ExerciseID, Value: List of sets from the last time this exercise was done
  var lastWorkoutSets = <int, List<WorkoutSet>>{}.obs;
  var completedSets = <String>{}.obs;

  // Key: ExerciseID, Value: Currently selected EquipmentID for this session
  var selectedEquipments = <int, int>{}.obs;

  final PageController pageController = PageController();

  ActiveWorkoutController(this.workoutDayId);

  @override
  void onInit() {
    super.onInit();
    _setupWorkout();
  }

  Future<void> _setupWorkout() async {
    try {
      currentWorkoutId = await db.into(db.workouts).insert(
        WorkoutsCompanion.insert(
          workoutDayId: workoutDayId,
          date: d.Value(DateTime.now()),
        ),
      );

      final query = db.select(db.programExercise).join([
        d.innerJoin(db.exercises, db.exercises.id.equalsExp(db.programExercise.exerciseId)),
        d.innerJoin(db.equipments, db.equipments.id.equalsExp(db.programExercise.equipmentId)),
      ])..where(db.programExercise.workoutDayId.equals(workoutDayId));

      final rows = await query.get();

      final List<ExerciseWithVolume> items = rows.map((row) {
        final ex = row.readTable(db.exercises);
        final eq = row.readTable(db.equipments);
        
        // Initialize the equipment switcher with the planned equipment
        selectedEquipments[ex.id] = eq.id;

        return ExerciseWithVolume(
          exercise: ex,
          volume: row.readTable(db.programExercise),
          equipment: eq,
        );
      }).toList();

      // Fetch past performance for history matching
      for (var item in items) {
        final sets = await (db.select(db.workoutSets)
              ..where((tbl) => tbl.exerciseId.equals(item.exercise.id))
              ..orderBy([(u) => d.OrderingTerm(expression: u.id, mode: d.OrderingMode.desc)]))
            .get();
        
        if (sets.isNotEmpty) {
          lastWorkoutSets[item.exercise.id] = sets;
        }
      }

      exercisesWithVolume.assignAll(items); 
      
    } catch (e) {
      Get.snackbar("Error", "Failed to load workout: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Updated to find the last time THIS specific equipment was used for THIS set number
  WorkoutSet? getPastSetData(int exerciseId, int setNum, int equipmentId) {
    final sets = lastWorkoutSets[exerciseId];
    if (sets == null) return null;
    
    return sets.firstWhereOrNull((s) => 
      s.setNumber == setNum && s.equipmentId == equipmentId
    );
  }

  Future<void> logSet({
    required int exerciseId, 
    required int equipmentId, 
    required int reps, 
    required double weight, 
    required int setNum
  }) async {
    if (currentWorkoutId == null) return;
    
    await db.into(db.workoutSets).insert(
      WorkoutSetsCompanion.insert(
        workoutId: currentWorkoutId!,
        exerciseId: exerciseId,
        equipmentId: equipmentId,
        reps: reps,
        weight: weight,
        setNumber: setNum,
        isCompleted: const d.Value(true),
      ),
    );
    completedSets.add("$exerciseId-$setNum");
  }

  bool isSetCompleted(int exerciseId, int setNum) => completedSets.contains("$exerciseId-$setNum");

// ... existing code ...

  /// Swaps an existing exercise in the current session with a new one.
  /// Preserves the sets/reps (volume) from the original slot.
  Future<void> swapExercise({
    required int oldExerciseId,
    required Exercise newExercise,
    required int newEquipmentId,
  }) async {
    try {
      // 1. Find the index of the exercise being replaced
      final index = exercisesWithVolume.indexWhere((item) => item.exercise.id == oldExerciseId);
      
      if (index != -1) {
        // 2. Fetch the actual Equipment object from the DB for the new selection
        final equipmentList = await db.getEquipmentForExercise(newExercise.id);
        final newEquip = equipmentList.firstWhere(
          (e) => e.id == newEquipmentId,
          orElse: () => equipmentList.isNotEmpty 
              ? equipmentList.first 
              : Equipment(id: newEquipmentId, name: "Default", icon_name: "fitness_center"),
        );

        // 3. Create the new composite object
        // We reuse the 'volume' from the existing index to keep planned sets/reps
        final originalItem = exercisesWithVolume[index];
        
        final swappedItem = ExerciseWithVolume(
          exercise: newExercise,
          volume: originalItem.volume, // Inherit planned sets/reps
          equipment: newEquip,
        );

        // 4. Update the selected equipment map for the switcher UI
        selectedEquipments[newExercise.id] = newEquipmentId;

        // 5. Replace in the list and refresh the observer
        exercisesWithVolume[index] = swappedItem;
        
        // 6. Fetch past performance for the NEW exercise so "History" values show up
        final sets = await (db.select(db.workoutSets)
              ..where((tbl) => tbl.exerciseId.equals(newExercise.id))
              ..orderBy([(u) => d.OrderingTerm(expression: u.id, mode: d.OrderingMode.desc)]))
            .get();
        
        if (sets.isNotEmpty) {
          lastWorkoutSets[newExercise.id] = sets;
        }

        // 7. Clear any sets already logged for the OLD exercise (preventing data ghosting)
        completedSets.removeWhere((key) => key.startsWith("$oldExerciseId-"));

        // Force GetX update
        exercisesWithVolume.refresh();
      }
    } catch (e) {
      Get.snackbar("Swap Error", "Could not swap exercise: $e");
    }
  }

  // ... rest of the controller ...
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}