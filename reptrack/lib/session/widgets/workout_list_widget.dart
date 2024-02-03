import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/pages/training_session.dart';
import 'package:reptrack/session/controllers/session_controller.dart';

class WorkoutExerciseCard extends StatelessWidget {
  SessionController controller = Get.find<SessionController>();
  Workout? workout;

  WorkoutExerciseCard(Workout w) {
    workout = w;
  }
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
                  workout!.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 50),
                ElevatedButton(onPressed: () => {
                  Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    controller.setSelectedWorkout(workout!);
                    return TrainingSessionPage();
                  }))
                }, child: Text("START"))
              ],
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: workout!.exercises.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${workout!.exercises[index].exercise!.name!}: ${workout!.exercises[index].sets.toString()} sets of ${workout!.exercises[index].repsPerSet}",
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