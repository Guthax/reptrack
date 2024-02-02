
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'dart:math' as math;

import 'package:reptrack/pages/add_exercise.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_session_overview_widget.dart';

class TrainingSessionOverviewPage extends StatelessWidget {
  final WorkoutSchedule schedule;
  List<TrainingSession> trainingSessions = List.empty(growable: true);

  TrainingSessionOverviewPage(this.schedule) {

    schedule.workouts.forEach((workout) {
      workout.trainingSessions.forEach((element) {
        trainingSessions.add(element);
      });
      
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
                    appBar: AppBar(
                      title: const Text('View workout'),
                    ),
                    body: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: trainingSessions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TrainingSessionOverviewWidget(trainingSessions[index]);
                      }
                    )
                  );
  }
}