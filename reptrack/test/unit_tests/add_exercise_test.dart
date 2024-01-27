
import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
void main() {
  test("create_exercise", () {
    Exercise ex = Exercise("Push ups");
    ex.muscles = "Chest";
    ex.description = "Press with arms";

    expect(ex.name, "Push ups");
  });

  test("create_workout_exercise", () {
    Exercise ex = Exercise("Push ups");
    ex.muscles = "Chest";
    ex.description = "Press with arms";

    WorkoutExercise wex = WorkoutExercise(ObjectId());
    wex.exercise = ex;
    wex.sets = 2;
    expect(wex.exercise, ex);
    expect(wex.sets, 2);
  });
}
