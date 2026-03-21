import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/fuzzy_search.dart';

class TrackingController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final RxList<Exercise> allExercises = <Exercise>[].obs;
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  final Rx<Exercise?> selectedExercise = Rx<Exercise?>(null);
  final RxList<WorkoutSet> exerciseSets = <WorkoutSet>[].obs;
  final RxMap<int, Equipment> setEquipment = <int, Equipment>{}.obs;
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;
  final Rx<Equipment?> selectedEquipment = Rx<Equipment?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final all = await db.getAllExercises();
    allExercises.assignAll(all);
    filteredExercises.assignAll(all);
  }

  void filterExercises(String query) {
    filteredExercises.assignAll(
      fuzzyFilter(allExercises, query, (e) => e.name),
    );
  }

  Future<void> selectExercise(Exercise exercise) async {
    selectedExercise.value = exercise;
    final sets = await db.getSetsForExercise(exercise.id);
    // getSetsForExercise returns desc order; reverse for chronological chart
    exerciseSets.assignAll(sets.reversed.toList());

    // Load equipment from past sets and exercise definition
    setEquipment.clear();
    final equipmentIds = <int>{};
    for (final set in exerciseSets) {
      equipmentIds.add(set.equipmentId);
    }

    // Also load equipment from exercise definition (even if no past sets)
    final exerciseEquipment = await db.getEquipmentForExercise(exercise.id);
    for (final equip in exerciseEquipment) {
      equipmentIds.add(equip.id);
    }

    final equipmentList = <Equipment>[];
    for (final id in equipmentIds) {
      final equipment = await db.getEquipmentById(id);
      if (equipment != null &&
          !equipmentList.any((e) => e.id == equipment.id)) {
        setEquipment[id] = equipment;
        equipmentList.add(equipment);
      }
    }
    equipmentList.sort((a, b) => a.name.compareTo(b.name));
    availableEquipment.assignAll(equipmentList);

    // Set default to first equipment if available
    selectedEquipment.value = equipmentList.isNotEmpty
        ? equipmentList.first
        : null;
  }

  void clearSelection() {
    selectedExercise.value = null;
    exerciseSets.clear();
    availableEquipment.clear();
    selectedEquipment.value = null;
    setEquipment.clear();
  }

  /// Returns (date, maxWeight) pairs grouped by day, sorted chronologically.
  /// Filters by selected equipment if one is selected.
  List<MapEntry<DateTime, double>> get weightProgressData {
    final Map<String, double> maxByDate = {};
    final Map<String, DateTime> dateByKey = {};
    final selectedEquip = selectedEquipment.value;

    for (final s in exerciseSets) {
      // Filter by selected equipment if available
      if (selectedEquip != null && s.equipmentId != selectedEquip.id) {
        continue;
      }

      final d = s.dateLogged;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      dateByKey[key] = DateTime(d.year, d.month, d.day);
      if (!maxByDate.containsKey(key) || s.weight > maxByDate[key]!) {
        maxByDate[key] = s.weight;
      }
    }

    final result =
        maxByDate.entries
            .map((e) => MapEntry(dateByKey[e.key]!, e.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return result;
  }
}
