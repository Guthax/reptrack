
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/add_schedule.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/training_schedule_list_widget.dart';

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
            tooltip: 'Add a new schedule',
            onPressed: () async {
              final schedule = await Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddSchedulePage();
                }));
                try {
                WorkoutSchedule ws = (schedule as WorkoutSchedule);
                setState(() {
                  state.addSchedule(schedule as WorkoutSchedule);
                });
              } catch (e) {
                print("Schedule not defined");
              }

            },
          ),
        ],
      ),
      body: ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: state.schedules.length,
             itemBuilder: (BuildContext context, int index) {
               return ListTile(
                title: WorkoutScheduleListCard(state.schedules[index]),
                onTap: () => {print("Test")},
                );
             }
          )
    );
  }

}
