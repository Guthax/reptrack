import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';

/// Controller for the Create Exercise dialog.
///
/// Loads available muscle groups and equipment on [onInit], manages
/// the set of selected equipment IDs, and handles the create operation
/// with input validation.
class CreateExerciseController extends GetxController {
  /// The shared database instance, resolved via GetX dependency injection.
  final AppDatabase db = Get.find<AppDatabase>();

  /// Reactive list of all muscle group names for the dropdown.
  final RxList<String> muscleGroups = <String>[].obs;

  /// Reactive list of all equipment items available for selection.
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;

  /// The set of equipment IDs the user has toggled on.
  final RxSet<int> selectedEquipmentIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  /// Fetches muscle groups and equipment from the database.
  Future<void> _loadData() async {
    final groups = await db.select(db.muscleGroups).get();
    muscleGroups.assignAll(groups.map((g) => g.name).toList());

    final equips = await db.select(db.equipments).get();
    availableEquipment.assignAll(equips);
  }

  /// Toggles the selection state of the equipment identified by [equipmentId].
  ///
  /// If [equipmentId] is already in [selectedEquipmentIds] it is removed;
  /// otherwise it is added.
  void toggleEquipment(int equipmentId) {
    if (selectedEquipmentIds.contains(equipmentId)) {
      selectedEquipmentIds.remove(equipmentId);
    } else {
      selectedEquipmentIds.add(equipmentId);
    }
  }

  /// Validates input and creates a new exercise in the database.
  ///
  /// - [name]: required, must be non-empty and unique.
  /// - [muscleGroup]: optional primary muscle group label.
  /// - [note]: optional free-text note.
  /// - [equipmentIds]: must contain at least one entry.
  ///
  /// Returns the newly created [Exercise] on success, or `null` if
  /// validation fails. Error messages are shown via [AppSnackbar].
  Future<Exercise?> createExercise({
    required String name,
    String? muscleGroupName,
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
      muscleGroupName: muscleGroupName?.trim(),
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

    return Exercise(id: id, name: trimmedName, note: note?.trim());
  }
}
