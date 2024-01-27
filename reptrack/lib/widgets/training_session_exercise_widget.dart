import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_session_exercise_set_widget.dart';

class TrainingSessionExercise extends StatefulWidget {
  final WorkoutExercise? exercise;
  SessionExercise? result;

  TrainingSessionExercise ({ Key? key, this.exercise }): super(key: key);
  @override
  _TrainingSessionExerciseState createState() => _TrainingSessionExerciseState();

  void setSession(SessionExercise se) {
    result = se;
  }

}

class _TrainingSessionExerciseState extends State<TrainingSessionExercise> {
  SessionExercise sessionExercise = SessionExercise(ObjectId());
  Exercise? exercise;


  
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: ExerciseCard(exercise: widget.exercise, calllback: addSet)
    );
  }

  SessionExercise getSessionExercise() {
    return sessionExercise;
  }

  void addSet(int weight, int reps) {
    sessionExercise.exercise = widget.exercise!.exercise;
    
    sessionExercise.sets = widget.exercise!.sets;
    sessionExercise.weightPerSetKg.add(weight);
    sessionExercise.repsPerSet.add(reps);
    widget.setSession(sessionExercise);
  }
}

class ExerciseCard extends StatelessWidget {
  final WorkoutExercise? exercise;
  final calllback;
  const ExerciseCard ({ Key? key, this.exercise, this.calllback }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: 
    [Card(
      color: Colors.blue,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              exercise!.exercise!.name!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: generateSetList(exercise!, calllback),
            ),
          ],
          
        ),
        
      ),
    ),             ElevatedButton(
                  onPressed: () {
                    // Implement the registration logic here
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                  ),
                  child: Text(
                    'Next excercise',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),]);
  }

}

List<Widget> generateSetList(WorkoutExercise exercise, func) {
  List<Widget> setListWidgets = List.empty(growable: true);
  for (var i = 0; i < exercise.sets; i++) {
   int amountReps = exercise.repsPerSet[i];
   setListWidgets.add(TrainingSessionExerciseSetWidget(i, func));
   setListWidgets.add(SizedBox(height: 5));

  }
  return setListWidgets;
}