import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/data_repository.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
class AppState extends ChangeNotifier {
  List<WorkoutSchedule> schedules = List.empty();
  List<Exercise> exercises = List.empty();

  DataRepository dataRepository = DataRepository();
  AppState() {
    //if (realm!.all<Exercise>().isEmpty) {
    fillDb();
    readSchedules();
    readExercises();
    //print(exercises[0].name);
  }

  void fillDb() async {
    await dataRepository.fillDb();
  }

  void readSchedules() async {
    schedules = await dataRepository.getAllSchedules();
  }

  void readExercises() async {
    exercises = await dataRepository.getAllExercises();
  }
  
  void addSchedule(WorkoutSchedule schedule) async {
    bool success = await dataRepository.addWorkoutSchedule(schedule);
    print(success);
    if(success) {
      readSchedules();
      notifyListeners();
    }
  }

  void addWorkout(WorkoutSchedule schedule, Workout w) async {
    bool success = await dataRepository.addWorkoutToSchedule(schedule, w);
    readSchedules();
    notifyListeners();
  }

  void addWorkoutExercise(Workout workout, WorkoutExercise workoutExercise) async {
    bool success = await dataRepository.addWorkoutExerciseToWorkout(workout, workoutExercise);
    readSchedules();
    notifyListeners();
  }

  void addTrainingSession(Workout workout, TrainingSession session) async {
    bool success = await dataRepository.addTrainingSession(workout, session);
    readSchedules();
    notifyListeners();
  }

  void deleteWorkoutSchedule(WorkoutSchedule schedule) async {
    bool success = await dataRepository.deleteWorkoutSchedule(schedule);
    readSchedules();
    notifyListeners();
  }
}


void deleteDb() {
      String defaultPath = Configuration.defaultRealmPath.toString();
      try {
        File(defaultPath).delete();
        print("deleted");
      } catch (e) {
        print(e);
      }
}