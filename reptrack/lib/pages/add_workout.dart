
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/add_exercise.dart';

class AddWorkoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
                    appBar: AppBar(
                      title: const Text('Add a workout'),
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
  State<AddWorkout> createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<AddWorkout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String dropdownValue = "Monday";
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: 'Enter a name for the workout',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter your starting bodyweight.',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          ElevatedButton(onPressed: (){
             Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddExercisePage();
                },
              ));
          }, child: Text("Add exercise")),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  // Process data.  
                  
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
