import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_session_exercise_widget.dart';

class TrainingSessionCompletePage extends StatelessWidget {
  final TrainingSession session;
  final Workout workout;


  const TrainingSessionCompletePage (this.session, this.workout);



  @override
  Widget build(BuildContext context) {
    
    AppState state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Training session complete")),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () { 
              state.addTrainingSession(workout,session);
              Navigator.of(context).popUntil((route) => route.isFirst);
              // handle the press
            },
          ),
        ], 
      ),
      body: Column(
        children: session.exercises.map((element) {
          return Text("${element.exercise!.name!}: ${element.sets.toString()} : ${element.repsPerSet.toString()} : ${element.weightPerSetKg.toString()}");
        }).toList()),
    );
  }
}