import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_session_exercise_set_widget.dart';

class TrainingSessionExercise extends StatefulWidget {
  final WorkoutExercise exercise;
  final SessionExercise? previousSessionExercise;

  SessionExercise result = SessionExercise(ObjectId());

  TrainingSessionExercise (this.exercise, this.previousSessionExercise ) {
    result.exercise = exercise.exercise;
    result.sets = exercise.sets;

    for(int i = 0; i < result.sets; i++) {
      if(this.previousSessionExercise != null && this.previousSessionExercise!.weightPerSetKg.length > i) {
        result.weightPerSetKg.add(this.previousSessionExercise!.weightPerSetKg[i]);
        result.repsPerSet.add(this.previousSessionExercise!.repsPerSet[i]);
      } else {
        result.weightPerSetKg.add(0);
        result.repsPerSet.add(exercise.repsPerSet[i]);
      }
    }
  }
  @override
  _TrainingSessionExerciseState createState() => _TrainingSessionExerciseState();

  void setSet(int i, int weight, int reps) {
    result.weightPerSetKg.setAll(i, [weight]);
    result.repsPerSet.setAll(i, [reps]);
    print(result.weightPerSetKg);
    print(result.repsPerSet);
  }

}

class _TrainingSessionExerciseState extends State<TrainingSessionExercise> with AutomaticKeepAliveClientMixin {
  SessionExercise sessionExercise = SessionExercise(ObjectId());
  Exercise? exercise;


  
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: ExerciseCard(widget.result, addSet)
    );
  }

  SessionExercise getSessionExercise() {
    return sessionExercise;
  }

  void addSet(int index, int weight, int reps) {
    widget.setSet(index, weight, reps);
  }
  @override
  bool get wantKeepAlive => true;

}

class ExerciseCard extends StatelessWidget {
  SessionExercise exercise;
  final callback;
  ExerciseCard (this.exercise, this.callback);

  @override
  Widget build(BuildContext context) {
    print("Building");
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
              children: generateSetList(exercise, callback),
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

List<Widget> generateSetList(SessionExercise exercise, func) {
  List<Widget> setListWidgets = List.empty(growable: true);
  for (var i = 0; i < exercise.sets; i++) {
   int amountReps = exercise.repsPerSet[i];
    setListWidgets.add(TrainingSessionExerciseSetWidget(i, exercise.weightPerSetKg[i], exercise.repsPerSet[i], func));
   }
   setListWidgets.add(SizedBox(height: 5));
    return setListWidgets;
  }
