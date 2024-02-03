
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/global_states.dart';
import 'dart:math' as math;

import 'package:reptrack/pages/add_exercise.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';
import 'package:reptrack/schedules/controllers/workout_controller.dart';
import 'package:reptrack/schedules/widgets/workout.dart';


class WorkoutScheduleOverview extends StatelessWidget {
  WorkoutController controller = Get.find<WorkoutController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View workout'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GetBuilder<WorkoutController>(
              builder: (workoutController) {
                return SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: workoutController.workouts.length,
                    itemBuilder: (context, index) {
                      print("renderer");
                      
                      print(workoutController.workouts[index].name);
                      return WorkoutWidget(workoutController.workouts[index]);
                      
                    },
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Add workout'),
                  content: TextField(
                    controller: controller.workoutNameController.value,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.submitWorkout();
                        Get.back();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              child: Text("Add workout"),
            ),
          ],
        ),
      ),
    );
  }
}
