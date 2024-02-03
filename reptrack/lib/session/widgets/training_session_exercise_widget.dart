import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/session/widgets/training_session_exercise_set_widget.dart';

class TrainingSessionExercise extends StatefulWidget {
  final WorkoutExercise exercise;
  final SessionExercise? previousSessionExercise;

  TrainingSessionExercise (this.exercise, this.previousSessionExercise);

  @override
  _TrainingSessionExerciseState createState() => _TrainingSessionExerciseState();

}

class _TrainingSessionExerciseState extends State<TrainingSessionExercise> with AutomaticKeepAliveClientMixin {

  
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: ExerciseCard(widget.exercise, widget.previousSessionExercise)
    );
  }

  @override
  bool get wantKeepAlive => true;

}

class ExerciseCard extends StatelessWidget {
  SessionExercise? previousExercise;
  WorkoutExercise exercise;
  ExerciseCard (this.exercise, this.previousExercise);

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
              exercise.exercise!.name!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: generateSetList(exercise, previousExercise),
            ),
          ],
          
        ),
        
      ),
    ),         ]);
  }

}

List<Widget> generateSetList(WorkoutExercise exercise, SessionExercise? previousSessionExercise) {
  List<Widget> setListWidgets = List.empty(growable: true);

  for (var i = 0; i < exercise.sets; i++) {
    if(previousSessionExercise != null &&  i < previousSessionExercise.repsPerSet.length) {
      setListWidgets.add(TrainingSessionExerciseSetWidget(exercise.exercise!, i, previousSessionExercise.weightPerSetKg[i], previousSessionExercise.repsPerSet[i]));
    } else {
      setListWidgets.add(TrainingSessionExerciseSetWidget(exercise.exercise!, 0,0, exercise.repsPerSet[i]));
    }
  }
   setListWidgets.add(SizedBox(height: 5));
    return setListWidgets;
  }