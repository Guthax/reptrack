import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
class AppState extends ChangeNotifier {
  List<WorkoutSchedule> schedules = List.empty();
  List<Exercise> exercises = List.empty();

  Realm? realm;

  AppState() {
    //deleteDb();
    final config = Configuration.local([WorkoutSchedule.schema, Workout.schema, WorkoutExercise.schema, Exercise.schema, TrainingSession.schema, SessionExercise.schema]);
    realm = Realm(config);
    //print(Configuration.defaultRealmPath.toString());
    if (realm!.all<Exercise>().isEmpty) {
      fillDb();
    }


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

  void addTrainingSession(Workout w, TrainingSession s) { 
    realm!.write(() => w.trainingSessions.add(s));
    readSchedules();
  }
  void updateWorkout(Workout w) {
    realm!.write(() => 
    realm!.add(
      w, update: true)
    );
    print("updated");
    readSchedules();
    

  }

  Future<void> fillDb() async {

    //path.join(root.path, relativePath);
    String data  = await rootBundle.loadString('assets/exercises.csv');
    List<List<dynamic>> exercises = const CsvToListConverter().convert(data).toList();
    List<Exercise> exercisesList = List.empty(growable: true);

    for (var exercise in exercises) {
      Exercise exerciseObj = Exercise(exercise[1].toString());
      exercisesList.add(exerciseObj);
      
    }
    realm!.write(() => realm!.addAll(exercisesList, update: true));
    readExercises();
    notifyListeners();
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