
import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
void main() {
  test("create_scedule", () {
    WorkoutSchedule workoutSchedule = WorkoutSchedule(ObjectId());
    workoutSchedule.name = "Push pull legs";
    workoutSchedule.finishWeightKg = 20;

    expect(workoutSchedule.name, "Push pull legs");
  });
}
