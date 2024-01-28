import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/schemas/schemas.dart';

class MockAppState extends Mock implements AppState {
  
  @override
  List<WorkoutSchedule> get schedules {
    WorkoutSchedule workoutSchedule = WorkoutSchedule(ObjectId());
    workoutSchedule.name = "PPL";
    
    Workout workout = Workout(ObjectId());

    WorkoutExercise we1 = WorkoutExercise(ObjectId());
    we1.exercise = exercises[0];
    we1.sets = 3;
    we1.repsPerSet.addAll([12,12,12]);
    workout.exercises.add(we1);


    Workout workout2 = Workout(ObjectId());
    WorkoutExercise we2 = WorkoutExercise(ObjectId());
    we2.exercise = exercises[1];
    we2.sets = 3;
    we2.repsPerSet.addAll([12,12,12]);
    workout2.exercises.add(we2);

    workoutSchedule.workouts.addAll([workout, workout2]);
    return[workoutSchedule];

  }

  @override
  List<Exercise> get exercises =>  <Exercise>[Exercise("Push ups"), Exercise("Sit ups"), Exercise("Pull ups")];

  
}
