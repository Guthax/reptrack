import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/pages/add_schedule.dart';
import 'package:reptrack/pages/view_workout_schedule.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';
import 'package:reptrack/schedules/controllers/workout_controller.dart';
import 'package:reptrack/schedules/widgets/training_schedule_list_widget.dart';

class SchedulesPage extends StatelessWidget {
  final SchedulesController schedulesController = Get.find<SchedulesController>();
  final WorkoutController workoutController = Get.put(WorkoutController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add a new schedule',
            onPressed: () async {
              Get.to(AddSchedulePage());
            },
          ),
        ],
      ),
      body: GetBuilder<SchedulesController>(
        builder: (schedulesController) {
          if (schedulesController.schedules.isEmpty) {
            // If schedules are not loaded yet, show a loading indicator
            return Center(child: Text("No schedules"));
          } else {
            // Your UI content here that depends on the loaded schedules
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: schedulesController.schedules.length,
              itemBuilder: (BuildContext context, int index) {
               return ListTile(
                      title: WorkoutScheduleListCard(schedulesController.schedules[index]),
                      onTap: () {
                        workoutController.setSchedule(schedulesController.schedules[index]);
                        Get.to(WorkoutScheduleOverview());
                      } 
                    );
              },
            );
          }
        },
      ),
    );
  }
}
