import 'dart:async';

import 'package:get/get.dart';
import 'package:reptrack/pages/track_workout.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';

/// Controller for the Workout selection screen.
///
/// Manages program/day dropdowns and navigation to [TrackWorkoutPage].
/// Programs are loaded on [onInit]; workout days are fetched reactively
/// whenever the selected program changes.
class WorkoutSelectionController extends GetxController {
  /// The shared database instance, resolved via GetX dependency injection.
  final AppDatabase db = Get.find<AppDatabase>();

  /// All programs available for selection.
  var programs = <Program>[].obs;

  /// Workout days belonging to [selectedProgram].
  var workoutDays = <WorkoutDay>[].obs;

  /// The currently selected program, or `null` if none is chosen.
  var selectedProgram = Rxn<Program>();

  /// The currently selected workout day, or `null` if none is chosen.
  var selectedDay = Rxn<WorkoutDay>();

  /// True when [selectedDay] is set but contains no exercises.
  var workoutDayHasNoExercises = false.obs;

  List<WorkoutDayWithExercises> _cachedDaysWithExercises = [];
  StreamSubscription<List<WorkoutDayWithExercises>>? _exercisesSubscription;

  @override
  void onInit() {
    super.onInit();
    programs.bindStream(db.watchAllPrograms());
    ever(programs, (_) {
      if (selectedProgram.value != null &&
          !programs.any((p) => p.id == selectedProgram.value!.id)) {
        selectedProgram.value = null;
        selectedDay.value = null;
        workoutDays.clear();
      }
    });
    ever(workoutDays, (_) {
      if (selectedDay.value != null &&
          !workoutDays.any((d) => d.id == selectedDay.value!.id)) {
        selectedDay.value = null;
      }
    });
    ever(selectedDay, (_) => _updateNoExercisesFlag());
  }

  @override
  void onClose() {
    _exercisesSubscription?.cancel();
    super.onClose();
  }

  void _updateNoExercisesFlag() {
    final day = selectedDay.value;
    if (day == null) {
      workoutDayHasNoExercises.value = false;
      return;
    }
    final match = _cachedDaysWithExercises.where(
      (d) => d.workoutDay.id == day.id,
    );
    workoutDayHasNoExercises.value =
        match.isEmpty || match.first.exercises.isEmpty;
  }

  /// Called when the user selects a different [program] from the dropdown.
  ///
  /// Resets [selectedDay] and binds a live stream of workout days for
  /// [program]. If [program] is `null` the day list is cleared.
  void onProgramChanged(Program? program) {
    selectedProgram.value = program;
    selectedDay.value = null;
    _exercisesSubscription?.cancel();

    if (program != null) {
      final stream = db.watchWorkoutDaysWithExercises(program.id);
      workoutDays.bindStream(
        stream.map((list) => list.map((e) => e.workoutDay).toList()),
      );
      _exercisesSubscription = stream.listen((daysWithExercises) {
        _cachedDaysWithExercises = daysWithExercises;
        _updateNoExercisesFlag();
      });
    } else {
      workoutDays.clear();
      _cachedDaysWithExercises = [];
    }
  }

  /// Navigates to [TrackWorkoutPage] for the currently [selectedDay].
  ///
  /// Does nothing if [selectedDay] is `null`.
  void startWorkout() {
    if (selectedDay.value != null) {
      Get.to(
        () => TrackWorkoutPage(
          dayId: selectedDay.value!.id,
          dayName: selectedDay.value!.dayName,
        ),
      );
    }
  }
}
