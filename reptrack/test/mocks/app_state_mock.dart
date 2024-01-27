import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/schemas/schemas.dart';

class MockAppState extends Mock implements AppState {
  @override
  // TODO: implement schedules
  List<WorkoutSchedule> get schedules => [WorkoutSchedule(ObjectId()), WorkoutSchedule(ObjectId())];
}