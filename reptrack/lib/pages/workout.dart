import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';
import 'package:reptrack/session/controllers/session_controller.dart';
import 'package:reptrack/session/widgets/current_date_widget.dart';
import 'package:reptrack/session/widgets/workout_detail_widget.dart';

class WorkoutPage extends StatelessWidget {
  SessionController sessionController = Get.put(SessionController());

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Workout")),
      ),
      body: Center(
        child: Column(
          children: [
            CurrentDateWidget(),
            WorkoutCard()
        ]),
      ),
    );

  }
}