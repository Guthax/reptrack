
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/pages/add_workout.dart';
import 'dart:math' as math;

import 'package:reptrack/schedules/controllers/new_schedules_controller.dart';

class AddSchedulePage extends StatelessWidget {
  final controller = Get.put(AddScheduleController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
                    appBar: AppBar(
                      title: const Text('Add a schedule'),
                      leading: IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: () => Navigator.pop(context, null),
                      ),
                    ),
                    body: Form(
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
              controller.scheduleName.value = value;
              return null;
            },
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            decoration: const InputDecoration(
              hintText: 'Enter a number of weeks for this schedule to last',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              controller.scheduleNumWeeks.value = int.parse(value);
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  // Process data.  
                  controller.submitSchedule();
                  Get.back();
                  
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    )
                  );
  }
}
