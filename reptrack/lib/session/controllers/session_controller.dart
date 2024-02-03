import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';

class SessionController extends GetxController {
  SchedulesController controller = Get.find<SchedulesController>();
  var selectedSchedule = Rxn<WorkoutSchedule>().obs;
  var selectedWorkout =  Rxn<Workout>().obs;

  var trainingSession = TrainingSession(ObjectId()).obs;

  var currentCountDown = 0.obs;

  SessionController() {

    selectedSchedule.value.value =  null;
    
  }

  @override
  void onInit() {
    super.onInit();
    controller.schedules.stream.listen((List<WorkoutSchedule> value) {
      if(!value.contains(selectedSchedule) && value.isNotEmpty) {
        selectedSchedule.value.value = value.first;
      } else {
        selectedSchedule.value.value = null;
      }
    });
  }

  void setSelectedSchedule(WorkoutSchedule schedule) {
    selectedSchedule.value.value = schedule;
  }

  void setSelectedWorkout(Workout workout) {
    selectedWorkout.value.value = workout;
  }

  SessionExercise? getPreviousWorkoutExercise(Exercise exercise) {
    SessionExercise? previousSessionExercise;
    if (selectedWorkout.value.value!.trainingSessions.isNotEmpty) {
      List<SessionExercise> previousRecords = selectedWorkout.value.value!.trainingSessions.last.exercises.where((element) => element.exercise == exercise).toList();
      if (previousRecords.isNotEmpty) {
        previousSessionExercise = previousRecords[0];
        
      }
    }
    return previousSessionExercise;
  }
  void logSet(Exercise exercise, int weight, int reps) {
    bool addNew = trainingSession.value.exercises.where((element) => element.exercise!.name == exercise.name).isEmpty;

    if(addNew) {
      trainingSession.value.exercises.add(SessionExercise(ObjectId(), exercise: exercise));
    }

    trainingSession.value.exercises.where((element) => element.exercise == exercise).first.sets += 1;
    trainingSession.value.exercises.where((element) => element.exercise == exercise).first.repsPerSet.add(reps);
    trainingSession.value.exercises.where((element) => element.exercise == exercise).first.weightPerSetKg.add(weight);

  }

  void addTrainingSession() async {
    await controller.dataRepository.addTrainingSession(selectedWorkout.value.value!, trainingSession.value);
  }

  void resetSession() {
    trainingSession.value = TrainingSession(ObjectId());
  }


}
