import 'package:reptrack/persistance/database.dart';


class ExerciseWithVolume {
  final Exercise exercise;
  final ProgramExerciseData volume;

  ExerciseWithVolume({required this.exercise, required this.volume});
}

class WorkoutDayWithExercises {
  final WorkoutDay workoutDay;
  final List<ExerciseWithVolume> exercises;

  WorkoutDayWithExercises({
    required this.workoutDay,
    required this.exercises,
  });
}