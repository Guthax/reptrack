
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'dart:math' as math;

import 'package:reptrack/pages/add_exercise.dart';
import 'package:reptrack/schemas/schemas.dart';

class TrainingSessionOverviewWidget extends StatelessWidget {
  final TrainingSession session;
  const TrainingSessionOverviewWidget(this.session);


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(10.0),
      color: Colors.blue, // Set the background color to blue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Date: ${session.dateStarted}}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            SizedBox(height: 10.0),
            SizedBox(
              height: 100,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: session.exercises.length,
                itemBuilder: (context, index) {
                  SessionExercise sessionExercise = session.exercises[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${sessionExercise.exercise!.name} : ${sessionExercise.weightPerSetKg} - ${sessionExercise.repsPerSet}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}