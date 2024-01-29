import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/pages/training_session_complete.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_session_exercise_widget.dart';

class TrainingSessionPage extends StatefulWidget {
  final Workout? workout;

  const TrainingSessionPage ({ Key? key, this.workout }): super(key: key);
  @override
  State<TrainingSessionPage> createState() => _TrainingSessionPageState();


}

class _TrainingSessionPageState extends State<TrainingSessionPage> {
  TrainingSession session = TrainingSession(ObjectId(), dateStarted: DateTime.now());
  

  List<TrainingSessionExercise> sessionWidgets = List.empty(growable: true);
  int currentCountDown = 0;

  Timer? _timer;
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
                    children: widget.workout!.exercises.map((exercise) {
                              SessionExercise? previousSessionExercise = null;
                              if (widget.workout!.trainingSessions.length > 0) {
                                List<SessionExercise> previousRecords = widget.workout!.trainingSessions.last.exercises.where((element) => element.exercise == exercise.exercise).toList();
                                if (previousRecords.length > 0) {
                                  previousSessionExercise = previousRecords[0];
                                  
                                }
                              }
                              TrainingSessionExercise tewidget = TrainingSessionExercise( exercise, previousSessionExercise, startTimer);
                              sessionWidgets.add(tewidget);
                              return tewidget;
                            }).toList(),
                  )),
              Visibility(
              visible: currentCountDown > 0,
                child: Text(currentCountDown.toString())
              ),
          Row(children: [
            ElevatedButton(onPressed: (() {}), child: Text("Stop workout")),
            ElevatedButton(onPressed: (() {
              sessionWidgets.forEach((widget) {

                session.exercises.add(widget.result!);
              });
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return TrainingSessionCompletePage(session, widget.workout!);
                }));
            }), child: Text("Finish workout"))
          ])
            
        ]),
      ),
    );
  }

  void startTimer(int timerDuration) {
    if(_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if(timerDuration - timer.tick < 0) {
          timer.cancel();
        } else {
          if(timerDuration - timer.tick <= 5) {
            SystemSound.play(SystemSoundType.alert);
          }
          setState(() {
            currentCountDown = timerDuration - timer.tick;
          });
        }
      });
  }
}