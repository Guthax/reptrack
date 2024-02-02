
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
final config = Configuration.local([WorkoutSchedule.schema, Workout.schema, WorkoutExercise.schema, Exercise.schema, TrainingSession.schema, SessionExercise.schema, BodyWeightLog.schema]);

class DataRepository {
  final Realm _realm = Realm(config);

  Future<List<WorkoutSchedule>> getAllSchedules() async {
    // Retrieve all tasks from Realm
    // Example: _realm.objects<Task>().toList();
    return _realm.all<WorkoutSchedule>().toList();
  }


  Future<List<Exercise>> getAllExercises() async {
    // Retrieve all tasks from Realm
    // Example: _realm.objects<Task>().toList();
    return _realm.all<Exercise>().toList();
  }

  Future<bool> addWorkoutSchedule(WorkoutSchedule schedule) async {
    try {
      _realm.write(() => _realm.add(schedule, update: true));
      return true;
    } catch  (e) {
      return false;
    }
  }


  Future<bool> addWorkoutToSchedule(WorkoutSchedule schedule, Workout workout) async {
    try {
      _realm.write(() => schedule.workouts.add(workout));
      return true;
    } catch  (e) {
      return false;
    }
  }

  Future<bool> addWorkoutExerciseToWorkout(Workout workout, WorkoutExercise exercise) async {
    try {
      _realm.write(() => workout.exercises.add(exercise));
      return true;
    } catch  (e) {
      return false;
    }
  }

  Future<bool> addTrainingSession(Workout workout, TrainingSession session) async {
    try {
      _realm.write(() => workout.trainingSessions.add(session));
      return true;
    } catch  (e) {
      return false;
    }
  }

  Future<bool> deleteWorkoutSchedule(WorkoutSchedule schedule) async {
    try {
      _realm.write(() => _realm.delete(schedule));
      return true;
    } catch  (e) {
      return false;
    }
  }



  Future<void> fillDb() async {
      if(_realm.all<Exercise>().isEmpty) {
            String data  = await rootBundle.loadString('assets/exercises_old.csv');
            List<List<dynamic>> exercises = const CsvToListConverter().convert(data).toList();
            List<Exercise> exercisesList = List.empty(growable: true);

            for (var exercise in exercises) {
              Exercise exerciseObj = Exercise(exercise[1].toString());
              exerciseObj.description = exercise[2].toString();
              exerciseObj.type = exercise[3].toString();
              exerciseObj.muscles = exercise[4].toString();
              exerciseObj.equipment = exercise[5].toString();
              exercisesList.add(exerciseObj);
              
            }
            _realm.write(() => _realm.addAll(exercisesList, update: true));
            print("filled");
      }
  }
}