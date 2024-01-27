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
  // Dummy data for workout schedules and details
  List<String> workoutSchedules = ['Schedule 1', 'Schedule 2', 'Schedule 3'];
  Map<String, Map<String, List<String>>> workoutDetails = {
    'Schedule 1': {
      'Day 1': ['Exercise 1', 'Exercise 2', 'Exercise 3'],
      'Day 2': ['Exercise 4', 'Exercise 5', 'Exercise 6'],
    },
    'Schedule 2': {
      'Day 1': ['Exercise 7', 'Exercise 8', 'Exercise 9'],
      'Day 2': ['Exercise 10', 'Exercise 11', 'Exercise 12'],
    },
    'Schedule 3': {
      'Day 1': ['Exercise 13', 'Exercise 14', 'Exercise 15'],
      'Day 2': ['Exercise 16', 'Exercise 17', 'Exercise 18'],
    },
  };

  WorkoutSchedule? selectedSchedule;
  int selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    AppState state = context.watch<AppState>();
    final PageController controller = PageController();
    print(state.schedules.length);
    selectedSchedule ??= state.schedules[0];
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Card(
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
                    /*
                    children: <Widget>[
                      selectedSchedule!.workouts.forEach((element) => Text("yes"))
                      Center(
                        child: WorkoutExerciseCard(selectedSchedule!.workouts[0]),
                      ),
                      Center(
                        child: Text('Second Page'),
                      ),
                      Center(
                        child: Text('Third Page'),
                      ),
                    ],*/
                  ))
              ])
          )
        )
    );
  }
}