import 'dart:io';

import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/classes/schemas.dart';

class AppState extends ChangeNotifier {
  List<WorkoutSchedule> schedules = List.empty();

  Realm? realm;

  AppState() {
    final config = Configuration.local([WorkoutSchedule.schema, Workout.schema, WorkoutExercise.schema, Exercise.schema, TrainingSession.schema, SessionExercise.schema]);
    realm = Realm(config);

    
    readSchedules();
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
}

void deleteDb() {
      String defaultPath = Configuration.defaultRealmPath.toString();
      try {
        File(defaultPath).delete();
      } catch (e) {
        print(e);
      }
}