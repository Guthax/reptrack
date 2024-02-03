import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';
import 'package:reptrack/session/widgets/workout_list_widget.dart';
import 'package:reptrack/session/controllers/session_controller.dart';

class WorkoutCard extends StatelessWidget {
  SchedulesController schedulesController = Get.find<SchedulesController>();
  SessionController sessionController = Get.find<SessionController>();

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Obx(() => Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: sessionController.selectedSchedule.value.value == null ? Text("No schedules") : Card(
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
                  value: sessionController.selectedSchedule.value.value!.name,
                  items: schedulesController.schedules
                      .map((schedule) => DropdownMenuItem<String>(
                            value: schedule.name,
                            child: Text(schedule.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    sessionController.setSelectedSchedule(schedulesController.schedules.firstWhere((element) => element.name == value));
                  },
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 200,
                child: PageView(
                    controller: controller,
                    children: sessionController.selectedSchedule.value.value!.workouts.map((value) {
                              return Center(
                                child: WorkoutExerciseCard(value),
                              );
                            }).toList()
                  ))
              ])
          )
        )
    ));
  }
}