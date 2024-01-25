import 'dart:io';

import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/classes/schemas.dart';

class AppState extends ChangeNotifier {
  List<WorkoutSchedule> schedules = List.empty();
  AppState() {
    //deleteDb();
    final config = Configuration.local([WorkoutSchedule.schema, Workout.schema, WorkoutExercise.schema, Exercise.schema, TrainingSession.schema, SessionExercise.schema]);
    
    final realm = Realm(config);

    WorkoutSchedule ws = WorkoutSchedule(ObjectId());
    realm.write(() => realm.add(ws));
    
    schedules = realm.all<WorkoutSchedule>().toList();
  }

  void addSchedule(WorkoutSchedule schedule) {
    schedules.add(schedule);
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