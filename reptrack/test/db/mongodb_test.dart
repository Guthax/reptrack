import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/classes/schemas.dart';
void main() {
  test('simple mongodb example', () async {
    final config = Configuration.local([WorkoutSchedule.schema, Workout.schema, Exercise.schema, TrainingSession.schema, SessionExercise.schema]);
    final realm = Realm(config);
    realm.close();
  });
}