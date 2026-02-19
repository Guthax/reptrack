import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/persistance/database.dart';

class BuildProgramPage extends StatelessWidget {
  final Program program;
  late final BuildProgramController controller;

  BuildProgramPage({super.key, required this.program}) {
    controller = Get.put(BuildProgramController(program.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${program.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Day',
            onPressed: () => _showAddDayDialog(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.daysWithExercises.isEmpty) {
          return const Center(child: Text("No workout days added yet."));
        }

        return ListView.builder(
          itemCount: controller.daysWithExercises.length,
          itemBuilder: (context, index) {
            final entry = controller.daysWithExercises[index];
            final day = entry.workoutDay;
            final exercises = entry.exercises;

           // ... inside ListView.builder item builder ...
return Card(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  child: ExpansionTile(
    title: Text(day.dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text("${exercises.length} Exercises"),
    leading: const Icon(Icons.calendar_today),
    children: [
      ...exercises.map((ex) => ListTile(
            leading: const Icon(Icons.fitness_center, size: 18),
            title: Text(ex.exercise.name),
            // Displaying Muscle Group
            subtitle: Text(ex.exercise.muscleGroup ?? "No muscle group"),
            // Added trailing widget to show Sets x Reps
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${ex.volume.sets} × ${ex.volume.reps}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          )),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton.icon(
          onPressed: () => _showAddExerciseDialog(day.id),
          icon: const Icon(Icons.add),
          label: const Text("Add Exercise"),
        ),
      )
    ],
  ),
);
          },
        );
      }),
    );
  }

  void _showAddDayDialog() {
    final TextEditingController nameController = TextEditingController();

    Get.defaultDialog(
      title: "New Workout Day",
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(hintText: "e.g. Push Day, Leg Day"),
        autofocus: true,
      ),
      textConfirm: "OK",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.addDay(nameController.text.trim());
        Get.back(); // Close dialog
      },
    );
  }

  // Make this method async to await the Future from getAvailableExercises
  Future<void> _showAddExerciseDialog(int dayId) async {
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

  // Reactive variable for selected exercise
  Rx<Exercise?> selectedExercise = Rx<Exercise?>(null);

  // Basic hardcoded exercises for the dropdown
  final List<Exercise> availableExercises = [
    Exercise(id: 1, name: 'Push-up', muscleGroup: 'Chest'),
    Exercise(id: 2, name: 'Squat', muscleGroup: 'Legs'),
    Exercise(id: 3, name: 'Deadlift', muscleGroup: 'Back'),
    Exercise(id: 4, name: 'Bench Press', muscleGroup: 'Chest'),
    Exercise(id: 5, name: 'Pull-up', muscleGroup: 'Back'),
  ];

  Get.defaultDialog(
    title: "Add Exercise",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dropdown for selecting exercise
        Obx(() {
          return DropdownButton<Exercise>(
            hint: const Text("Select Exercise"),
            value: selectedExercise.value,
            onChanged: (newExercise) {
              selectedExercise.value = newExercise;
            },
            items: availableExercises.map((exercise) {
              return DropdownMenuItem<Exercise>(
                value: exercise,
                child: Text(exercise.name),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 16),
        // Input fields for sets and reps
        TextField(
          controller: setsController,
          decoration: const InputDecoration(labelText: "Sets"),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: repsController,
          decoration: const InputDecoration(labelText: "Reps"),
          keyboardType: TextInputType.number,
        ),
      ],
    ),
    textConfirm: "Add",
    textCancel: "Cancel",
    confirmTextColor: Colors.white,
    onConfirm: () {
      if (selectedExercise.value != null &&
          setsController.text.isNotEmpty &&
          repsController.text.isNotEmpty) {
        final sets = int.tryParse(setsController.text.trim()) ?? 0;
        final reps = int.tryParse(repsController.text.trim()) ?? 0;

        // Add exercise to day
        controller.addExerciseToDay(dayId, selectedExercise.value!, sets, reps);

        // Close dialog
        Get.back();
      } else {
        Get.snackbar("Error", "Please fill in all fields.");
      }
    },
  );
}

}
