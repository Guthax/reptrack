
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import 'package:reptrack/global_states.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:search_page/search_page.dart';

class AddExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
                    appBar: AppBar(
                      title: const Text('Add a new exercise'),
                      leading: IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: () => Navigator.pop(context, null),
                      ),
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
  Exercise? selectedExercise;
  WorkoutExercise workoutExercise = WorkoutExercise(ObjectId());
  TextEditingController editingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
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
                    items: state.exercises,
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
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: 'Enter the amount of sets',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              workoutExercise.sets = int.parse(value);
              return null;
            },
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: 'Enter the amount of reps',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              workoutExercise.repsPerSet.clear();
              workoutExercise.repsPerSet.addAll(List.filled(workoutExercise.sets, int.parse(value)));
            },
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: 'Enter a timer per rep',
            ),
            validator: (String? value) {
              if (value != null) {
                 workoutExercise.timer = int.parse(value);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate() && selectedExercise != null) {
                  workoutExercise.exercise = selectedExercise;
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
