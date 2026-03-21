import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';

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
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      AppSnackbar.error('Exercise name is required');
      return null;
    }

    if (equipmentIds.isEmpty) {
      AppSnackbar.error('Please select at least one equipment type');
      return null;
    }

    final existing = await db.getExerciseByName(trimmedName);
    if (existing != null) {
      AppSnackbar.error('"$trimmedName" already exists');
      return null;
    }

    final id = await db.addExercise(
      trimmedName,
      muscleGroup: muscleGroup?.trim(),
      comment: note?.trim(),
    );

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

    AppSnackbar.success('"$trimmedName" created');
    return Exercise(
      id: id,
      name: trimmedName,
      muscleGroup: muscleGroup?.trim(),
      note: note?.trim(),
      timer: null,
    );
  }
}
