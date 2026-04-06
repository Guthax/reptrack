import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/navigation_controller.dart';
import 'package:reptrack/controllers/workout_selection_controller.dart';
import 'package:reptrack/pages/settings.dart';
import 'package:reptrack/persistance/database.dart';

/// Page where the user selects a program and workout day before starting.
///
/// Presents two dropdowns (program → day) and a START button that navigates
/// to [TrackWorkoutPage] via [WorkoutSelectionController.startWorkout].
class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkoutSelectionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.programs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No programs yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a program first before starting a workout.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Go to Programs'),
                    onPressed: () =>
                        Get.find<NavigationController>().changeIndex(0),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Select your session",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Obx(
                        () => DropdownButtonFormField<Program>(
                          decoration: const InputDecoration(
                            labelText: "Program",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.list_alt),
                          ),
                          initialValue: controller.selectedProgram.value,
                          items: controller.programs.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p.name),
                            );
                          }).toList(),
                          onChanged: controller.onProgramChanged,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Obx(
                        () => DropdownButtonFormField<WorkoutDay>(
                          decoration: const InputDecoration(
                            labelText: "Workout Day",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          initialValue: controller.selectedDay.value,
                          disabledHint: const Text("Select a program first"),
                          items: controller.workoutDays.map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text(d.dayName),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              controller.selectedDay.value = val,
                        ),
                      ),

                      if (controller.workoutDayHasNoExercises.value) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'This day has no exercises yet. Add exercises to this day in the Programs section.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed:
                              controller.selectedDay.value == null ||
                                  controller.workoutDayHasNoExercises.value
                              ? null
                              : controller.startWorkout,
                          child: const Text(
                            "START WORKOUT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
