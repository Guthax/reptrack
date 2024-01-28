import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:reptrack/widgets/workout_list_widget.dart';

class WorkoutCard extends StatefulWidget {
  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  WorkoutSchedule? selectedSchedule;
  int selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    AppState state = context.watch<AppState>();
    final PageController controller = PageController();
    selectedSchedule ??= state.schedules.length > 0 ? state.schedules[0] : null;
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: selectedSchedule == null ? Text("No schedules") : Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Workout Schedule:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                DropdownButton<String>(
                  value: selectedSchedule!.name,
                  items: state.schedules
                      .map((schedule) => DropdownMenuItem<String>(
                            value: schedule.name,
                            child: Text(schedule.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSchedule = state.schedules.firstWhere((element) => element.name == value);
                      selectedDay = 0;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 200,
                child: PageView(
                    controller: controller,
                    children: selectedSchedule!.workouts.map((value) {
                              return Center(
                                child: WorkoutExerciseCard(value),
                              );
                            }).toList()
                  ))
              ])
          )
        )
    );
  }
}