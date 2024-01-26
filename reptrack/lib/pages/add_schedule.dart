
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/classes/schemas.dart';
import 'dart:math' as math;

import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/add_workout.dart';

class AddSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
                    appBar: AppBar(
                      title: const Text('Add a schedule'),
                    ),
                    body: const Center(
                      child: Column(
                        children: [
                          AddScheduleForm()
                        ],
                      ),
                    ),
                  );
  }
}


class AddScheduleForm extends StatefulWidget {
  const AddScheduleForm({super.key});

  @override
  State<AddScheduleForm> createState() => _AddScheduleFormState();
}

class _AddScheduleFormState extends State<AddScheduleForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  WorkoutSchedule schedule = WorkoutSchedule(ObjectId());
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
              hintText: 'Enter a name for the training schedule',
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
              hintText: 'Enter a number of weeks for this schedule to last',
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
              setState(() {
                schedule.name = value;
              });
              return null;
            },
          ),
          ElevatedButton(onPressed: () async {
             final workout = await Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddWorkoutPage();
                },
              ));

              setState(() {
                schedule.workouts.add(workout as Workout);
              });
          }, child: Text("Add workout day")),
           SizedBox(
            height: 200,
            child: ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: schedule.workouts.length,
             itemBuilder: (BuildContext context, int index) {
               return Container(
             height: 50,
             color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
             child: Center(child:Text("${schedule.workouts[index].day.toString()}"))
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
                  Navigator.pop(context, schedule);
                  
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
