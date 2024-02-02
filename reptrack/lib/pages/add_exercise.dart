
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import 'package:reptrack/global_states.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:search_page/search_page.dart';




class AddExerciseDialog extends StatefulWidget {
  final callback;
  const AddExerciseDialog(this.callback);
  @override
  State<AddExerciseDialog> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExerciseDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Exercise? selectedExercise;
  WorkoutExercise workoutExercise = WorkoutExercise(ObjectId());
  TextEditingController editingController = TextEditingController();

  TextEditingController setsController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController timerController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(children: [
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
            )
          ),
          TextFormField(
            controller: setsController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: "Enter the amoutn of sets",
            ),
          ),
          TextFormField(
            controller: repsController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: 'Enter the amount of reps per set',
            )
           
            //workoutExercise.repsPerSet.clear();
            //workoutExercise.repsPerSet.addAll(List.filled(workoutExercise.sets, int.parse(value)));
            
          ),
          TextFormField(
            controller: timerController,
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
                if (selectedExercise != null) {
                  workoutExercise.exercise = selectedExercise;
                  workoutExercise.sets = int.parse(setsController.text);
                  
                  workoutExercise.repsPerSet.clear();
                  workoutExercise.repsPerSet.addAll(List.filled(workoutExercise.sets, int.parse(repsController.text)));
                  workoutExercise.timer = int.parse(timerController.text);
                  widget.callback(workoutExercise, state);
                  Navigator.of(context).pop(); 
                  
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ]),
      ));
  }
}
