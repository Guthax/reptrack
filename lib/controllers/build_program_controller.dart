import 'package:get/get.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';

class BuildProgramController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final int programId;

  BuildProgramController(this.programId);

  // This reactive variable will hold our joined data
  RxList<WorkoutDayWithExercises> daysWithExercises = <WorkoutDayWithExercises>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Bind the stream from Drift to our reactive list
    daysWithExercises.bindStream(db.watchWorkoutDaysWithExercises(programId));
  }

  // Method to add a workout day
  void addDay(String name) async {
    if (name.isNotEmpty) {
      await db.addWorkoutDay(programId, name);
    }
  }

  // Method to get available exercises from the database
  Future<List<Exercise>> getAvailableExercises() async {
    // Fetch all exercises from the database asynchronously
    final exercises = await db.getAllExercises();
    return exercises;
  }

  // Method to add an exercise to a workout day (with sets and reps)
  void addExerciseToDay(int dayId, Exercise exercise, int sets, int reps) async {
  // Validate sets and reps
  if (sets > 0 && reps > 0) {
    // Insert the exercise to the programExercise table
    await db.addExerciseToDay(
      workoutDayId: dayId,
      exerciseId: exercise.id,
      sets: sets,
      reps: reps,
      weight: 0.0, // Optionally, set weight as 0.0 or allow users to input weight
    );
  } else {
    Get.snackbar("Error", "Sets and Reps must be greater than 0.");
  }
}

}

