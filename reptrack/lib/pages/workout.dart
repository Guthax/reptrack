import 'package:flutter/material.dart';
import 'package:reptrack/widgets/current_date_widget.dart';
import 'package:reptrack/widgets/workout_detail_widget.dart';

class WorkoutPage extends StatefulWidget {
  SchedulesPage() {
    super.key;

  }
  @override
  State<WorkoutPage> createState() => _WorkoutPagePageState();
}

class _WorkoutPagePageState extends State<WorkoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Workout")),
      ),
      body: Center(
        child: Column(
          children: [
            CurrentDateWidget(context: context),
            WorkoutCard()
        ]),
      ),
    );
  }
}