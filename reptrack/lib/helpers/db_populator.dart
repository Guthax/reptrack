import 'package:realm/realm.dart';
import 'package:reptrack/classes/workout.dart';


List<Exercise> exercises = List.empty();


class DbPopulator {
  Realm? dbRealm;
  DbPopulator(Realm realm) {
    dbRealm = realm;
  }
  void fillExercises() {
    
  }
}