import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/fuzzy_search.dart';

/// Which metric to plot on the exercise progress chart.
enum ChartType {
  // Strength
  maxWeight,
  totalVolume,
  // Cardio
  duration,
  distance,
  pace,
  // Hybrid
  hybridMaxWeight,
  hybridTotalDistance,
  hybridVolume,
}

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

  /// All historical [WorkoutStrengthSet]s for [selectedExercise], in chronological order.
  final RxList<WorkoutStrengthSet> exerciseSets = <WorkoutStrengthSet>[].obs;

  /// All historical [WorkoutCardioSet]s for the selected cardio exercise.
  final RxList<WorkoutCardioSet> cardioSets = <WorkoutCardioSet>[].obs;

  /// All historical [WorkoutHybridSet]s for the selected hybrid exercise.
  final RxList<WorkoutHybridSet> hybridSets = <WorkoutHybridSet>[].obs;

  /// The exerciseTypeId of the currently selected exercise ('1'=strength, '2'=cardio, '3'=hybrid).
  final RxString selectedExerciseTypeId = '1'.obs;

  /// Map from equipment ID to [Equipment] for every set in [exerciseSets].
  final RxMap<String, Equipment> setEquipment = <String, Equipment>{}.obs;

  /// Equipment variants that appear in [exerciseSets] or the exercise definition.
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;

  /// The equipment variant currently selected for the weight progress chart.
  final Rx<Equipment?> selectedEquipment = Rx<Equipment?>(null);

  /// Which metric is currently plotted on the exercise chart.
  final Rx<ChartType> selectedChartType = ChartType.maxWeight.obs;

  /// All bodyweight entries in chronological order.
  final RxList<BodyweightEntry> bodyweightEntries = <BodyweightEntry>[].obs;

  /// Selected date in the "Log Bodyweight" dialog.
  final Rx<DateTime> logDate = DateTime.now().obs;

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
    final typeId = exercise.exerciseTypeId ?? '1';
    selectedExerciseTypeId.value = typeId;

    exerciseSets.clear();
    cardioSets.clear();
    hybridSets.clear();
    availableEquipment.clear();
    setEquipment.clear();
    selectedEquipment.value = null;

    if (typeId == '2') {
      // Cardio
      final sets = await db.getCardioSetsForExercise(exercise.id);
      cardioSets.assignAll(sets.reversed.toList());
      selectedChartType.value = ChartType.duration;
    } else if (typeId == '3') {
      // Hybrid
      final sets = await db.getHybridSetsForExercise(exercise.id);
      hybridSets.assignAll(sets.reversed.toList());
      selectedChartType.value = ChartType.hybridMaxWeight;

      final equipmentIds = <String>{};
      for (final set in hybridSets) {
        if (set.equipmentId != null) equipmentIds.add(set.equipmentId!);
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
      final lastSet = hybridSets.isNotEmpty
          ? hybridSets.reduce(
              (a, b) => a.dateLogged.isAfter(b.dateLogged) ? a : b,
            )
          : null;
      selectedEquipment.value =
          equipmentList.firstWhereOrNull((e) => e.id == lastSet?.equipmentId) ??
          equipmentList.firstOrNull;
    } else {
      // Strength
      final sets = await db.getStrengthSetsForExercise(exercise.id);
      exerciseSets.assignAll(sets.reversed.toList());
      selectedChartType.value = ChartType.maxWeight;

      final equipmentIds = <String>{};
      for (final set in exerciseSets) {
        if (set.equipmentId != null) equipmentIds.add(set.equipmentId!);
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
      final lastSet = exerciseSets.isNotEmpty
          ? exerciseSets.reduce(
              (a, b) => a.dateLogged.isAfter(b.dateLogged) ? a : b,
            )
          : null;
      selectedEquipment.value =
          equipmentList.firstWhereOrNull((e) => e.id == lastSet?.equipmentId) ??
          equipmentList.firstOrNull;
    }
  }

  /// Resets the exercise selection and clears all related state.
  void clearSelection() {
    selectedExercise.value = null;
    exerciseSets.clear();
    cardioSets.clear();
    hybridSets.clear();
    availableEquipment.clear();
    selectedEquipment.value = null;
    setEquipment.clear();
  }

  /// Logs a bodyweight entry for [date] (defaults to today) with [weight] in kg.
  Future<void> logBodyweight(double weight, {DateTime? date}) {
    return db.addBodyweightEntry(date ?? DateTime.now(), weight);
  }

  /// Deletes the bodyweight entry with the given [id].
  Future<void> deleteBodyweight(String id) {
    return db.deleteBodyweightEntry(id);
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

  /// Returns `(date, totalVolume)` pairs grouped by calendar day, sorted
  /// chronologically. Volume = sum of `weight × reps` across all sets that day.
  ///
  /// Only sets matching [selectedEquipment] are included.
  List<MapEntry<DateTime, double>> get volumeProgressData {
    final Map<String, double> volumeByDate = {};
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
      volumeByDate[key] = (volumeByDate[key] ?? 0) + s.weight * s.reps;
    }

    final result =
        volumeByDate.entries
            .map((e) => MapEntry(dateByKey[e.key]!, e.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return result;
  }

  // ── Cardio getters ──────────────────────────────────────────────────────────

  /// Helper: collapses [sets] by calendar day using [value] extractor.
  List<MapEntry<DateTime, double>> _groupCardioByDay(
    List<WorkoutCardioSet> sets,
    double Function(List<WorkoutCardioSet>) aggregate,
  ) {
    final Map<String, List<WorkoutCardioSet>> byDay = {};
    final Map<String, DateTime> dateByKey = {};
    for (final s in sets) {
      final d = s.dateLogged;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      dateByKey[key] = DateTime(d.year, d.month, d.day);
      byDay.putIfAbsent(key, () => []).add(s);
    }
    return byDay.entries
        .map((e) => MapEntry(dateByKey[e.key]!, aggregate(e.value)))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  /// Total duration per session in minutes.
  List<MapEntry<DateTime, double>> get cardioDurationData =>
      _groupCardioByDay(cardioSets, (sets) {
        final totalSec = sets.fold<int>(0, (s, e) => s + e.durationSeconds);
        return totalSec / 60.0;
      });

  /// Total distance per session in km (only sessions with distance data).
  List<MapEntry<DateTime, double>> get cardioDistanceData {
    final withDist = cardioSets.where((s) => s.distanceMeters != null).toList();
    return _groupCardioByDay(withDist, (sets) {
      final totalM = sets.fold<double>(0, (s, e) => s + e.distanceMeters!);
      return totalM / 1000.0;
    });
  }

  /// Average pace per session in min/km (only sessions with distance data).
  List<MapEntry<DateTime, double>> get cardioPaceData {
    final withDist = cardioSets.where((s) => s.distanceMeters != null).toList();
    return _groupCardioByDay(withDist, (sets) {
      final totalSec = sets.fold<int>(0, (s, e) => s + e.durationSeconds);
      final totalKm =
          sets.fold<double>(0, (s, e) => s + e.distanceMeters!) / 1000.0;
      if (totalKm == 0) return 0;
      return (totalSec / 60.0) / totalKm;
    })..removeWhere((e) => e.value == 0);
  }

  // ── Hybrid getters ───────────────────────────────────────────────────────

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Max weight per session (in kg), filtered by [selectedEquipment].
  List<MapEntry<DateTime, double>> get hybridMaxWeightData {
    final Map<String, double> maxByDay = {};
    final Map<String, DateTime> dateByKey = {};
    final selectedEquip = selectedEquipment.value;
    for (final s in hybridSets) {
      if (selectedEquip != null && s.equipmentId != selectedEquip.id) continue;
      final key = _dayKey(s.dateLogged);
      dateByKey[key] = DateTime(
        s.dateLogged.year,
        s.dateLogged.month,
        s.dateLogged.day,
      );
      if (!maxByDay.containsKey(key) || s.weight > maxByDay[key]!) {
        maxByDay[key] = s.weight;
      }
    }
    return maxByDay.entries
        .map((e) => MapEntry(dateByKey[e.key]!, e.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  /// Total distance per session in metres (normalised), filtered by [selectedEquipment].
  List<MapEntry<DateTime, double>> get hybridTotalDistanceData {
    final Map<String, double> distByDay = {};
    final Map<String, DateTime> dateByKey = {};
    final selectedEquip = selectedEquipment.value;
    for (final s in hybridSets) {
      if (selectedEquip != null && s.equipmentId != selectedEquip.id) continue;
      final meters = s.distanceMeters ?? 0;
      final key = _dayKey(s.dateLogged);
      dateByKey[key] = DateTime(
        s.dateLogged.year,
        s.dateLogged.month,
        s.dateLogged.day,
      );
      distByDay[key] = (distByDay[key] ?? 0) + meters;
    }
    return distByDay.entries
        .map((e) => MapEntry(dateByKey[e.key]!, e.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  /// Total volume (weight × distanceMeters) per session, filtered by [selectedEquipment].
  List<MapEntry<DateTime, double>> get hybridVolumeData {
    final Map<String, double> volByDay = {};
    final Map<String, DateTime> dateByKey = {};
    final selectedEquip = selectedEquipment.value;
    for (final s in hybridSets) {
      if (selectedEquip != null && s.equipmentId != selectedEquip.id) continue;
      final meters = s.distanceMeters ?? 0;
      final key = _dayKey(s.dateLogged);
      dateByKey[key] = DateTime(
        s.dateLogged.year,
        s.dateLogged.month,
        s.dateLogged.day,
      );
      volByDay[key] = (volByDay[key] ?? 0) + s.weight * meters;
    }
    return volByDay.entries
        .map((e) => MapEntry(dateByKey[e.key]!, e.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  /// Returns the active chart data based on [selectedChartType].
  List<MapEntry<DateTime, double>> get activeChartData =>
      selectedChartType.value == ChartType.maxWeight
      ? weightProgressData
      : volumeProgressData;
}
