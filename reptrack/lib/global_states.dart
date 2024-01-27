import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';

class AppState extends ChangeNotifier {
  List<WorkoutSchedule> schedules = List.empty();
  List<Exercise> exercises = List.empty();

  Realm? realm;

  AppState() {
    //deleteDb();
    final config = Configuration.local([WorkoutSchedule.schema, Workout.schema, WorkoutExercise.schema, Exercise.schema, TrainingSession.schema, SessionExercise.schema]);
    realm = Realm(config);
    fillDb();


    readSchedules();
    readExercises();
  }

  void readExercises() {
    exercises = realm!.all<Exercise>().toList();
  }

  void readSchedules() {
    schedules = realm!.all<WorkoutSchedule>().toList();
  }

  void addSchedule(WorkoutSchedule schedule) {
    realm!.write(() => 
    realm!.add(schedule, update: true));
    readSchedules();
    notifyListeners();
  }


  Future<void> fillDb() async {
    final input = File('/home/jurriaan/Documents/Programming/reptrack/reptrack/lib/data/exercises.csv').openRead();
    final exercises = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();
    List<Exercise> exercisesList = List.empty(growable: true);
    for (var exercise in exercises) {
      Exercise exerciseObj = Exercise(exercise[1].toString());
      exercisesList.add(exerciseObj);
      
    }
    realm!.write(() => realm!.addAll(exercisesList, update: true));
    print("Filled");


  }
}
void deleteDb() {
      String defaultPath = Configuration.defaultRealmPath.toString();
      try {
        File(defaultPath).delete();
      } catch (e) {
        print(e);
      }
}