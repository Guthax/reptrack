import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/add_exercise.dart';



class WorkoutWidget extends StatelessWidget {
  final Workout workout;
  const WorkoutWidget(this.workout);

  
  @override
  Widget build(BuildContext context) {
    return  Card(
      elevation: 4.0,
      margin: EdgeInsets.all(10.0),
      color: Colors.blue, // Set the background color to blue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  workout.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                 onPressed: () => showDialog<String>(
                  useRootNavigator: false,
                                      context: context,
                                      builder: (BuildContext context) => AddExerciseDialog(workout)
                                      ),
                                    
                 icon: Row(children: [Icon(Icons.add), Text("Add exercise"),])),
                SizedBox(width: 50),
              ],
            ),
            SizedBox(height: 10.0),
            Column(
              children: workout.exercises.map((we) {
                return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${we.exercise!.name!}: ${we.sets.toString()} sets of ${we.repsPerSet}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  );
              }).toList()
            )
          ],
        ),
      ),
    );;
  }
}
/*
class _WorkoutWidgetState extends State<WorkoutWidget> {
  List<WorkoutExercise> exercises = List.empty(growable: true);

  
  @override
  Widget build(BuildContext context) {
    AppState state = context.watch<AppState>();
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(10.0),
      color: Colors.blue, // Set the background color to blue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.workout.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                 onPressed: () => showDialog<String>(
                  useRootNavigator: false,
                                      context: context,
                                      builder: (BuildContext context) => AddExerciseDialog(addExercise)
                                      ),
                                    
                 icon: Row(children: [Icon(Icons.add), Text("Add exercise"),])),
                SizedBox(width: 50),
              ],
            ),
            SizedBox(height: 10.0),
            Column(
              children: widget.workout.exercises.map((we) {
                return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${we.exercise!.name!}: ${we.sets.toString()} sets of ${we.repsPerSet}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  );
              }).toList()
            )
          ],
        ),
      ),
    );
}

void addExercise(WorkoutExercise workoutExercise, AppState state) {
  state.addWorkoutExercise(widget.workout, workoutExercise);

}
}
*/