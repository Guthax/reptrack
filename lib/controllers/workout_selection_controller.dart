import 'package:get/get.dart';
import 'package:reptrack/pages/track_workout.dart';
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

  @override
  void onInit() {
    super.onInit();
    fetchPrograms();
  }

  /// Loads all programs from the database into [programs].
  ///
  /// Declared as [Future<void>] so callers can await completion and
  /// propagated errors are not silently swallowed.
  Future<void> fetchPrograms() async {
    programs.value = await db.getAllPrograms();
  }

  /// Called when the user selects a different [program] from the dropdown.
  ///
  /// Resets [selectedDay] and fetches the workout days for [program].
  /// If [program] is `null` the day list is cleared.
  ///
  /// Declared as [Future<void>] so propagated errors are not silently swallowed.
  Future<void> onProgramChanged(Program? program) async {
    selectedProgram.value = program;
    selectedDay.value = null;

    if (program != null) {
      workoutDays.value = await db.getWorkoutDaysForProgram(program.id);
    } else {
      workoutDays.clear();
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
