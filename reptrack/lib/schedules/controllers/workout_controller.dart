import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';

/// Controller to handle all business logic regarding workouts for a specific schedule.
class WorkoutController extends GetxController {
  SchedulesController controller = Get.find<SchedulesController>();

  var schedule;
  var workoutNameController = TextEditingController().obs;
  var workouts = <Workout>[].obs;

  var all_exercises = List<Exercise>.empty(growable: true).obs;
  WorkoutController() {
       readExercises();
  }


  var selectedExercise = Exercise("").obs;
  var exerciseController = TextEditingController();
  var setsTextController = TextEditingController();
  var repsTextController = TextEditingController();
  var timerController = TextEditingController();

  // Call  all exercises where the user can choose from.
   void readExercises() async {
    all_exercises.assignAll(await controller.dataRepository.getAllExercises());
  }

  void setSchedule(WorkoutSchedule currentSchedule) {
    schedule = currentSchedule;
    workouts.assignAll(currentSchedule.workouts);
  }

  void updateWorkouts(WorkoutSchedule schedule) {
    workouts.assignAll(schedule.workouts);
    update();
  }

  void addExercise(Workout w) {
    WorkoutExercise workoutExercise = WorkoutExercise(ObjectId());
    workoutExercise.exercise = selectedExercise.value;
    workoutExercise.sets = int.parse(setsTextController.text);
    workoutExercise.repsPerSet.assignAll(List.filled(workoutExercise.sets, int.parse(repsTextController.text)));
    controller.dataRepository.addWorkoutExerciseToWorkout(w, workoutExercise);
    updateWorkouts(schedule);
  }

  void submitWorkout() {
    Workout workout = Workout(ObjectId(), workoutNameController.value.text);
    controller.addWorkout(schedule, workout);
  }
}
