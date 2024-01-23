

import 'package:realm/realm.dart';
part 'schemas.g.dart';

@RealmModel()
class _User {
  @PrimaryKey()
  @MapTo("_id")
  late final ObjectId userId;

  late final String name = "Jurriaan";
  late _WorkoutSchedule? activeSchedule;
}
@RealmModel()
class _WorkoutSchedule {
  @PrimaryKey()
  @MapTo("_id")
  late final ObjectId scheduleId;
  
  late String name = "Push Pull Legs";
  late int numWeeks = 6;

  late int startingWeightKg = 60;
  late int finishWeightKg = 90;
  late DateTime? dateStarted;

  late List<_TrainingSession> sessions = List.empty();
  late List<_Workout> workouts = List.empty();
  late _Workout? activeWorkout;

}


@RealmModel()
class _TrainingSession {
  @PrimaryKey()
  @MapTo("_id")
  late final ObjectId sessionId;

  late DateTime? dateStarted;
  late DateTime? dateEnded;

  late List<_SessionExercise> exercises = List.empty();

}

@RealmModel()
class _SessionExercise {
  late _Exercise? exercise;
  late int sets = 2;
  late List<int> repsPerSet = List.empty();
  late List<int> weightPerSetKg = List.empty();
  late String? comment;
}

@RealmModel()
class _Workout {
  @PrimaryKey()
  @MapTo("_id")
  late final ObjectId workoutId;
  late final int day;
  late List<_Exercise> exercises = List.empty();

}


@RealmModel()
class _Exercise {
  
  @PrimaryKey()
  String? name;

  late String? description;
  late String? muscles;
}
