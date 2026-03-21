import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';

class CreateExerciseController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final RxList<String> muscleGroups = <String>[].obs;
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;
  final RxSet<int> selectedEquipmentIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final groups = await db.select(db.muscleGroups).get();
    muscleGroups.assignAll(groups.map((g) => g.name).toList());

    final equips = await db.select(db.equipments).get();
    availableEquipment.assignAll(equips);
  }

  void toggleEquipment(int equipmentId) {
    if (selectedEquipmentIds.contains(equipmentId)) {
      selectedEquipmentIds.remove(equipmentId);
    } else {
      selectedEquipmentIds.add(equipmentId);
    }
  }

  Future<Exercise?> createExercise({
    required String name,
    String? muscleGroup,
    String? note,
    required Set<int> equipmentIds,
  }) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Exercise name is required');
      return null;
    }

    if (equipmentIds.isEmpty) {
      Get.snackbar('Error', 'Please select at least one equipment type');
      return null;
    }

    try {
      final id = await db.addExercise(
        name.trim(),
        muscleGroup: muscleGroup?.trim(),
        comment: note?.trim(),
      );

      // Add equipment associations
      for (final equipmentId in equipmentIds) {
        await db
            .into(db.exerciseEquipment)
            .insert(
              ExerciseEquipmentCompanion(
                exerciseId: drift.Value(id),
                equipmentId: drift.Value(equipmentId),
              ),
            );
      }

      Get.snackbar('Success', 'Exercise created successfully');
      return Exercise(
        id: id,
        name: name.trim(),
        muscleGroup: muscleGroup?.trim(),
        note: note?.trim(),
        timer: null,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create exercise: $e');
      return null;
    }
  }
}
