import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/fuzzy_search.dart';

class TrackingController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final RxList<Exercise> allExercises = <Exercise>[].obs;
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  final Rx<Exercise?> selectedExercise = Rx<Exercise?>(null);
  final RxList<WorkoutSet> exerciseSets = <WorkoutSet>[].obs;

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
  }

  void clearSelection() {
    selectedExercise.value = null;
    exerciseSets.clear();
  }

  /// Returns (date, maxWeight) pairs grouped by day, sorted chronologically.
  List<MapEntry<DateTime, double>> get weightProgressData {
    final Map<String, double> maxByDate = {};
    final Map<String, DateTime> dateByKey = {};

    for (final s in exerciseSets) {
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
