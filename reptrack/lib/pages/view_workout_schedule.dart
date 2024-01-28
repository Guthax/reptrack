
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'dart:math' as math;

import 'package:reptrack/pages/add_exercise.dart';
import 'package:reptrack/schemas/schemas.dart';

class ViewWorkoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
                    appBar: AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: () => Navigator.pop(context, null),
                      ),
                      title: const Text('Add a new workout'),
                    ),
                    body: const Center(
                      child: Column(
                        children: [
                          AddWorkout()
                        ],
                      ),
                    ),
                  );
  }
}

class AddWorkout extends StatefulWidget {
  const AddWorkout({super.key});

  @override
  State<AddWorkout> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkout> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String dropdownValue = "Monday";
  Workout workout = Workout(ObjectId());
  
  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child:Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ElevatedButton(onPressed: () async {
             var workoutExercise = await Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddExercisePage();
                },
              ));
              try {
                WorkoutExercise we = (workoutExercise as WorkoutExercise);
                setState(() {
                  workout.exercises.add(we);
                });
              } catch (e) {
                print("Exercise not defined");
              }
          }, child: Text("Add exercise")),
          SizedBox(
            height: 200,
            child: ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: workout.exercises.length,
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
      ));
  }
}

Text buildText(WorkoutExercise exercise) {
  return Text("${exercise.exercise!.name}: ${exercise.sets} sets - ${exercise.repsPerSet.toString()}");
}