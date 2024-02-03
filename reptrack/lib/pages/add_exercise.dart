
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/data_repository.dart';
import 'package:reptrack/data/schemas/schemas.dart';

import 'package:reptrack/global_states.dart';
import 'package:reptrack/schedules/controllers/workout_controller.dart';
import 'package:search_page/search_page.dart';


class AddExerciseDialog extends StatelessWidget {
  Exercise? selectedExercise;
  WorkoutController controller = Get.find<WorkoutController>();

  Workout workout;

  AddExerciseDialog(this.workout);

@override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        child: Column(children: [
          TextFormField(
            controller: controller.exerciseController,
            readOnly: true,
            keyboardType: TextInputType.name,
            onTap: () => 
            showSearch(
                  context: context,
                  delegate: SearchPage<Exercise>(
                    items: controller.all_exercises,
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
                        controller.selectedExercise.value = exercise;
                        controller.exerciseController.text = exercise.name!;
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
            controller: controller.setsTextController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: "Enter the amoutn of sets",
            ),
          ),
          TextFormField(
            controller: controller.repsTextController,
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
            controller: controller.timerController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: 'Enter a timer per rep',
            ),
            validator: (String? value) {
              
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (controller.selectedExercise != null) {
                  //workoutExercise.exercise = selectedExercise;
                  //workoutExercise.sets = int.parse(setsController.text);
                  
                  //workoutExercise.repsPerSet.clear();
                  //workoutExercise.repsPerSet.addAll(List.filled(workoutExercise.sets, int.parse(repsController.text)));
                  //workoutExercise.timer = int.parse(timerController.text);
                  //widget.callback(workoutExercise, state);
                  //Navigator.of(context).pop(); 
                  controller.addExercise(workout);
                  Get.back();
                  
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ]),
      ));
  }
}