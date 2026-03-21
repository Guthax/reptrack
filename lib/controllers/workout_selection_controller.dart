import 'package:get/get.dart';
import 'package:reptrack/pages/track_workout.dart';
import 'package:reptrack/persistance/database.dart';

class WorkoutSelectionController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  var programs = <Program>[].obs;
  var workoutDays = <WorkoutDay>[].obs;

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
    selectedDay.value = null;

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
