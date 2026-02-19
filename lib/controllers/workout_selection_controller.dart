import 'package:get/get.dart';
import 'package:reptrack/pages/track_workout.dart';
import 'package:reptrack/persistance/database.dart'; // Adjust path

class WorkoutSelectionController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  // Observable lists for dropdowns
  var programs = <Program>[].obs;
  var workoutDays = <WorkoutDay>[].obs;

  // Selected values
  var selectedProgram = Rxn<Program>();
  var selectedDay = Rxn<WorkoutDay>();

  @override
  void onInit() {
    super.onInit();
    fetchPrograms();
  }

  void fetchPrograms() async {
    programs.value = await db.getAllPrograms();
  }

  void onProgramChanged(Program? program) async {
    selectedProgram.value = program;
    selectedDay.value = null; // Reset day when program changes
    
    if (program != null) {
      workoutDays.value = await db.getWorkoutDaysForProgram(program.id);
    } else {
      workoutDays.clear();
    }
  }

  void startWorkout() {
    if (selectedDay.value != null) {
      Get.to(() => TrackWorkoutPage(
        dayId: selectedDay.value!.id,
        dayName: selectedDay.value!.dayName,
      ));
    }
  }
}