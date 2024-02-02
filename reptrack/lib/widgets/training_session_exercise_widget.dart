import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_session_exercise_set_widget.dart';

class TrainingSessionExercise extends StatefulWidget {
  final WorkoutExercise exercise;
  final SessionExercise? previousSessionExercise;
  final timerCallback;

  SessionExercise? result;

  TrainingSessionExercise (this.exercise, this.previousSessionExercise, this.timerCallback);

  @override
  _TrainingSessionExerciseState createState() => _TrainingSessionExerciseState();

}

class _TrainingSessionExerciseState extends State<TrainingSessionExercise> with AutomaticKeepAliveClientMixin {
  Exercise? exercise;
  SessionExercise result = SessionExercise(ObjectId());

  
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: ExerciseCard(widget.exercise, widget.previousSessionExercise, logSet)
    );
  }


  void logSet(int weight, int reps) {
    result.exercise = widget.exercise.exercise;
    result.weightPerSetKg.add(weight);
    result.repsPerSet.add(reps);
    print(result.exercise!.name);
    print(result.weightPerSetKg);
    print(result.repsPerSet);
    widget.result = result;
    //if (widget.exercise.timer != null) {
    //  widget.timerCallback(widget.exercise.timer);
    //}
  }



  @override
  bool get wantKeepAlive => true;

}

class ExerciseCard extends StatelessWidget {
  SessionExercise? previousExercise;
  WorkoutExercise exercise;
  final callback;
  ExerciseCard (this.exercise, this.previousExercise, this.callback);

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
              children: generateSetList(exercise, previousExercise, callback),
            ),
          ],
          
        ),
        
      ),
    ),         ]);
  }

}

List<Widget> generateSetList(WorkoutExercise exercise, SessionExercise? previousSessionExercise, func) {
  List<Widget> setListWidgets = List.empty(growable: true);

  for (var i = 0; i < exercise.sets; i++) {
    if(previousSessionExercise != null &&  i < previousSessionExercise.repsPerSet.length) {
      setListWidgets.add(TrainingSessionExerciseSetWidget(i, previousSessionExercise.weightPerSetKg[i], previousSessionExercise.repsPerSet[i], func));
    } else {
      setListWidgets.add(TrainingSessionExerciseSetWidget(i, 0, exercise.repsPerSet[i], func));
    }
  }
   setListWidgets.add(SizedBox(height: 5));
    return setListWidgets;
  }
