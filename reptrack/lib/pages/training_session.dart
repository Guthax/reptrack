import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/pages/training_session_complete.dart';
import 'package:reptrack/session/controllers/session_controller.dart';
import 'package:reptrack/session/widgets/training_session_exercise_widget.dart';

class TrainingSessionPage extends StatelessWidget {
  SessionController sessionController = Get.find<SessionController>();
  
@override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Training session")),
      ),
      body: Center(
        child: Column(
          children: [
              SizedBox(height: 500,
                child: PageView(
                    controller: controller,
                    children: sessionController.selectedWorkout.value.value!.exercises.map((exercise) {
                              SessionExercise? previousSessionExercise = sessionController.getPreviousWorkoutExercise(exercise.exercise!);
                              return TrainingSessionExercise(exercise, previousSessionExercise);
                            }).toList(),
                  )),
          Row(children: [
            ElevatedButton(onPressed: (() {}), child: Text("Stop workout")),
            ElevatedButton(onPressed: (() {
              Get.to(TrainingSessionCompletePage());
            }), child: Text("Finish workout"))
          ])
            
        ]),
      ),
    );
  }

}