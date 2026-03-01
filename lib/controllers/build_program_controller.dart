import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/composites.dart';

class BuildProgramController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final int programId;

  BuildProgramController(this.programId);

  RxList<WorkoutDayWithExercises> daysWithExercises = <WorkoutDayWithExercises>[].obs;

  @override
  void onInit() {
    super.onInit();
    daysWithExercises.bindStream(db.watchWorkoutDaysWithExercises(programId));
  }

  Future<List<Exercise>> getAvailableExercises() => db.getAllExercises();

  void addDay(String name) async {
    if (name.trim().isNotEmpty) {
      await db.addWorkoutDay(programId, name.trim());
    }
  }

  void addExerciseToDay(int dayId, Exercise exercise, int equipmentId, int sets, int reps, int? restTimer) async {
    await db.addExerciseToDay(
      workoutDayId: dayId,
      exerciseId: exercise.id,
      equipmentId: equipmentId,
      sets: sets,
      reps: reps,
      restTimer: restTimer,
      weight: 0.0,
    );
  }

  void removeExerciseFromDay(int dayId, int exerciseId) async {
    await db.deleteExerciseFromWorkoutDay(
      dayId,
      exerciseId
    );
  }
}