
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/classes/schemas.dart';
import 'dart:math' as math;

import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/add_exercise.dart';


class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String dropdownValue = "Monday";
  Workout? workout = Workout(ObjectId(), 1);
  
  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child:
      Scaffold( 
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ElevatedButton(onPressed: () async {
             final workoutExercise = await Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddExercisePage();
                },
              ));

              setState(() {
                workout?.exercises.add(workoutExercise as WorkoutExercise);
              });
          }, child: Text("Add exercise")),
          SizedBox(
            height: 200,
            child: ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: workout!.exercises.length,
             itemBuilder: (BuildContext context, int index) {
               return Container(
             height: 50,
             color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
             child: Center(child: buildText(workout!.exercises[index]))
                );
              }
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  // Process data.  
                  Navigator.pop(context, workout);
                }
              },
              child: const Text('Submit'),
            ),
          ),
          
        ],
      ),
    ));
  }
}

Text buildText(WorkoutExercise exercise) {
  return Text("${exercise.exercise!.name}: ${exercise.sets} - ${exercise.repsPerSet[0]}");
}