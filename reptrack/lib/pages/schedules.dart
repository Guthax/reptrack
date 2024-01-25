
import 'package:flutter/material.dart';
import 'package:reptrack/classes/schemas.dart';
import 'dart:math' as math;

import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/add_schedule.dart';

class SchedulesPage extends StatelessWidget {
  List<WorkoutSchedule> schedules = List.empty();

  bool show_add_dialog = false;

  SchedulesPage(AppState global_state) {
    schedules = global_state.schedules;
  }

  @override
  Widget build(BuildContext context) {
    var favorites = ["Push Pull Legs 1", "Upper lower"];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add schedule',
            onPressed: () {
              show_add_dialog = true;
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Go to the next page',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddSchedulePage();
                },
              ));
            },
          ),
        ],
      ),
      body: ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: schedules.length,
             itemBuilder: (BuildContext context, int index) {
               return Container(
          height: 50,
          color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
          child: Center(child: Text(schedules[index].name)),
               );
             }
          )
    );
  }
}



class DialogExample extends StatelessWidget {
  const DialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('This is a typical dialog.'),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: const Text('Show Dialog'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog.fullscreen(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('This is a fullscreen dialog.'),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
          child: const Text('Show Fullscreen Dialog'),
        ),
      ],
    );
  }
}
