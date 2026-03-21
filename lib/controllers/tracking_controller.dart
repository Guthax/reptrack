import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/fuzzy_search.dart';

/// Controller for the Tracking screen.
///
/// Manages two tabs: exercise progress charts and bodyweight tracking.
/// Exercise search/filter state and historical workout sets are scoped to the
/// exercises tab. Bodyweight entries are kept live via a Drift stream.
class TrackingController extends GetxController {
  /// The shared database instance, resolved via GetX dependency injection.
  final AppDatabase db = Get.find<AppDatabase>();

  /// 0 = exercises tab, 1 = bodyweight tab.
  final RxInt selectedTab = 0.obs;

  /// All exercises stored in the database, loaded once on [onInit].
  final RxList<Exercise> allExercises = <Exercise>[].obs;

  /// Subset of [allExercises] that matches the current search query.
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;

  /// The exercise the user has tapped to inspect, or `null` in search mode.
  final Rx<Exercise?> selectedExercise = Rx<Exercise?>(null);

  /// All historical [WorkoutSet]s for [selectedExercise], in chronological order.
  final RxList<WorkoutSet> exerciseSets = <WorkoutSet>[].obs;

  /// Map from equipment ID to [Equipment] for every set in [exerciseSets].
  final RxMap<int, Equipment> setEquipment = <int, Equipment>{}.obs;

  /// Equipment variants that appear in [exerciseSets] or the exercise definition.
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;

  /// The equipment variant currently selected for the weight progress chart.
  final Rx<Equipment?> selectedEquipment = Rx<Equipment?>(null);

  /// All bodyweight entries in chronological order.
  final RxList<BodyweightEntry> bodyweightEntries = <BodyweightEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadExercises();
    bodyweightEntries.bindStream(db.watchBodyweightEntries());
  }

  /// Fetches all exercises from the database and initialises both
  /// [allExercises] and [filteredExercises].
  Future<void> _loadExercises() async {
    final all = await db.getAllExercises();
    allExercises.assignAll(all);
    filteredExercises.assignAll(all);
  }

  /// Filters [allExercises] by [query] using fuzzy matching and updates
  /// [filteredExercises].
  void filterExercises(String query) {
    filteredExercises.assignAll(
      fuzzyFilter(allExercises, query, (e) => e.name),
    );
  }

  /// Selects [exercise] and loads its historical sets and equipment data.
  ///
  /// Sets are stored in chronological order for chart display. Equipment is
  /// collected from both past sets and the exercise's own equipment
  /// definition, deduplicated, and sorted by name.
  Future<void> selectExercise(Exercise exercise) async {
    selectedExercise.value = exercise;
    final sets = await db.getSetsForExercise(exercise.id);
    exerciseSets.assignAll(sets.reversed.toList());

    setEquipment.clear();
    final equipmentIds = <int>{};
    for (final set in exerciseSets) {
      equipmentIds.add(set.equipmentId);
    }

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

    selectedEquipment.value = equipmentList.isNotEmpty
        ? equipmentList.first
        : null;
  }

  /// Resets the exercise selection and clears all related state.
  void clearSelection() {
    selectedExercise.value = null;
    exerciseSets.clear();
    availableEquipment.clear();
    selectedEquipment.value = null;
    setEquipment.clear();
  }

  /// Logs a bodyweight entry for today with [weight] in kg.
  Future<void> logBodyweight(double weight) {
    return db.addBodyweightEntry(DateTime.now(), weight);
  }

  /// Returns `(date, maxWeight)` pairs grouped by calendar day, sorted
  /// chronologically.
  ///
  /// Only sets matching [selectedEquipment] are included. Accessing this
  /// getter inside an [Obx] is sufficient for reactivity because it reads
  /// the reactive [exerciseSets] and [selectedEquipment] observables.
  List<MapEntry<DateTime, double>> get weightProgressData {
    final Map<String, double> maxByDate = {};
    final Map<String, DateTime> dateByKey = {};
    final selectedEquip = selectedEquipment.value;

    for (final s in exerciseSets) {
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
