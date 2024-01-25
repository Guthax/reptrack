
import 'package:flutter/material.dart';
import 'package:reptrack/classes/schemas.dart';
import 'dart:math' as math;

import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/add_schedule.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  List<WorkoutSchedule> schedules = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add schedule',
            onPressed: () {
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Go to the next page',
            onPressed: () async {
              final schedule = await Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddSchedulePage();
                }));

              setState(() {
                schedules.add(schedule as WorkoutSchedule);
              });
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
