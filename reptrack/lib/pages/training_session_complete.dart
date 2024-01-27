import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_session_exercise_widget.dart';

class TrainingSessionCompletePage extends StatelessWidget {
  final TrainingSession session;


  const TrainingSessionCompletePage (this.session );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Training session complete")),
        automaticallyImplyLeading: false,  
      ),
      body: Column(
        children: session.exercises.map((element) {
          return Text("${element.exercise!.name!}: ${element.sets.toString()} : ${element.repsPerSet.toString()} : ${element.weightPerSetKg.toString()}");
        }).toList()),
    );
  }
}