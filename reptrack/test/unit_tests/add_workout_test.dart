
import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
void main() {
  test("create_workout", () {
    Exercise ex1 = Exercise("Push ups");
    Exercise ex2 = Exercise("Sit ups");
    Workout workout = Workout(ObjectId());
    workout.day = 2;
    expect(workout.day, 2);
  });
}
