
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reptrack/classes/schemas.dart';
import 'dart:math' as math;

import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/add_schedule.dart';

class SchedulesPage extends StatefulWidget {
  SchedulesPage() {
    super.key;

  }
  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Go to the next page',
            onPressed: () async {
              final schedule = await Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddSchedulePage();
                }));

            state.addSchedule(schedule as WorkoutSchedule);

            },
          ),
        ],
      ),
      body: ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: state.schedules.length,
             itemBuilder: (BuildContext context, int index) {
               return Container(
          height: 50,
          color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
          child: Center(child: Text(state.schedules[index].name)),
               );
             }
          )
    );
  }

}
