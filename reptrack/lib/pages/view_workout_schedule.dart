
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/global_states.dart';
import 'dart:math' as math;

import 'package:reptrack/pages/add_exercise.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_session_overview_widget.dart';
import 'package:reptrack/widgets/workout.dart';

// ignore: must_be_immutable
class ViewWorkoutSchedulePage extends StatefulWidget {
  WorkoutSchedule schedule;

  ViewWorkoutSchedulePage(this.schedule);

  @override
  State<ViewWorkoutSchedulePage> createState() => _ViewWorkoutSchedulePageState();
}

class _ViewWorkoutSchedulePageState extends State<ViewWorkoutSchedulePage> {
  List<Workout> workouts =  List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    workouts = widget.schedule.workouts.toList();
    AppState state = context.watch<AppState>();
    TextEditingController textController = TextEditingController();
    return Scaffold(
  
                    appBar: AppBar(
                      title: const Text('View workout'),
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                      children: List<Widget>.from(workouts.map((workout) {
                                  return WorkoutWidget(workout);
                                }).toList()) +  
                                List.from([
                                  ElevatedButton(
                                   onPressed: () => showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('Add workout'),
                                        content: TextField(
                                          controller: textController,
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, 'Cancel'),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              addWorkout(textController.text, state);
                                              Navigator.pop(context, 'OK');
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  child: Text("Add workout"))
                                ]),
                  )));
  }

  void addWorkout(String name, AppState state) {
    Workout workout = Workout(ObjectId(), name);
    state.addWorkout(widget.schedule, workout);

  }
}