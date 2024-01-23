
import 'package:flutter/material.dart';
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
              return null;
            },
          ),
          ElevatedButton(onPressed: (){
             Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddWorkoutPage();
                },
              ));
          }, child: Text("Add workout day")),
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
