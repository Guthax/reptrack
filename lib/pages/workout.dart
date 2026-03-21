import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/workout_selection_controller.dart';
import 'package:reptrack/persistance/database.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkoutSelectionController());

    return Scaffold(
      appBar: AppBar(title: const Text('Start Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Select your session",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    Obx(() => DropdownButtonFormField<Program>(
                          decoration: const InputDecoration(
                            labelText: "Program",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.list_alt),
                          ),
                          initialValue: controller.selectedProgram.value,
                          items: controller.programs.map((p) {
                            return DropdownMenuItem(value: p, child: Text(p.name));
                          }).toList(),
                          onChanged: controller.onProgramChanged,
                        )),

                    const SizedBox(height: 16),

                    Obx(() => DropdownButtonFormField<WorkoutDay>(
                          decoration: const InputDecoration(
                            labelText: "Workout Day",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          initialValue: controller.selectedDay.value,
                          disabledHint: const Text("Select a program first"),
                          items: controller.workoutDays.map((d) {
                            return DropdownMenuItem(value: d, child: Text(d.dayName));
                          }).toList(),
                          onChanged: (val) => controller.selectedDay.value = val,
                        )),

                    const SizedBox(height: 24),

                    Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: controller.selectedDay.value == null 
                              ? null 
                              : controller.startWorkout,
                          child: const Text(
                            "START WORKOUT",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}