import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';
import 'package:reptrack/session/controllers/session_controller.dart';
import 'package:reptrack/session/widgets/training_session_exercise_widget.dart';

class TrainingSessionCompletePage extends StatelessWidget {
  SchedulesController schedulesController = Get.find<SchedulesController>();
  SessionController sessionController = Get.find<SessionController>();


  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Training session complete")),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () { 
              sessionController.trainingSession.value.dateEnded = DateTime.now();
              sessionController.addTrainingSession();
              sessionController.resetSession();
              Navigator.of(context).popUntil((route) => route.isFirst);
              // handle the press
            },
          ),
        ], 
      ),
      body: Column(
        children: sessionController.trainingSession.value.exercises.map((element) {
          print(element.sets);
          print(element.exercise);
          return Text("${element.exercise!.name!}: ${element.sets.toString()} : ${element.repsPerSet.toString()} : ${element.weightPerSetKg.toString()}");
        }).toList()),
    );
  }
}