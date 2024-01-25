
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/classes/schemas.dart';
import 'dart:math' as math;

import 'package:reptrack/global_states.dart';
import 'package:search_page/search_page.dart';

class AddExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
                    appBar: AppBar(
                      title: const Text('Add a new exercise'),
                    ),
                    body: const Center(
                      child: Column(
                        children: [
                          AddExercise()
                        ],
                      ),
                    ),
                  );
  }
}


class AddExercise extends StatefulWidget {
  const AddExercise({super.key});

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String dropdownValue = "Monday";
  Exercise? selectedExercise = Exercise("Push ups");
  TextEditingController editingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: editingController,
            readOnly: true,
            keyboardType: TextInputType.name,
            onTap: () => 
            showSearch(
                  context: context,
                  delegate: SearchPage<Exercise>(
                    items: [Exercise("Bench Press")],
                    searchLabel: 'Search exercises',
                    suggestion: Center(
                      child: Text('Find exercises by name'),
                    ),
                    failure: Center(
                      child: Text('No exercise found :('),
                    ),
                    filter: (exercise) => [
                      exercise.name,
                    ],
                    builder: (exercise) => ListTile(
                      title: Text(exercise.name!),
                      onTap: () {
                        selectedExercise = exercise;
                        editingController.text = exercise.name!;
                        Navigator.pop(context);
                        },
                    ),
                  ),
                ),
            decoration: const InputDecoration(
              hintText: 'Search for an exercise',
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
              hintText: 'Enter the amount of sets',
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
              hintText: 'Enter the amount of reps',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate() && selectedExercise != null) {
                  WorkoutExercise workoutExercise = WorkoutExercise(ObjectId(), exercise: selectedExercise, repsPerSet: [1,2]);
                  Navigator.pop(context, workoutExercise); 
                  
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
