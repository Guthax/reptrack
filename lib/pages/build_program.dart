import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/widgets/add_exercise_dialog.dart';

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
            return _buildDayCard(entry);
          },
        );
      }),
    );
  }

  Widget _buildDayCard(entry) {
    final day = entry.workoutDay;
    final exercises = entry.exercises;

return Card(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  child: ExpansionTile(
    title: Text(day.dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text("${exercises.length} Exercises"),
    leading: const Icon(Icons.calendar_today),
    children: [
    ...exercises.map((ex) => ListTile(
      leading: Icon(_getIconData(ex.equipment.icon_name), color: Colors.blueAccent),
      title: Row(
        children: [
          // 1. NAME (Left side)
          Expanded(
            flex: 3, 
            child: Text(
              ex.exercise.name, 
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 2. REPS (True Middle)
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "${ex.volume.sets} × ${ex.volume.reps}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),

          // 3. SPACER (To balance the Row so Reps stay centered)
          const Expanded(flex: 1, child: SizedBox()),
        ],
      ),
      subtitle: Text("${ex.exercise.muscleGroup} • ${ex.equipment.name}"),
      // 4. DELETE BUTTON (The very end)
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () => {
        Get.defaultDialog(
          title: "Are you sure you want to delete the exercise from the program?",
          middleText: "",
          onCancel: () => {},
          onConfirm: () {
            controller.removeExerciseFromDay(day.id, ex.exercise.id);
            Get.back();
          },
        )
      },
      ),
    )),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton.icon(
          onPressed: () => Get.dialog(AddExerciseDialog(dayId: day.id)),
          icon: const Icon(Icons.add),
          label: const Text("Add Exercise"),
        ),
      )
    ],
  ),
);
  }

  void _showAddDayDialog() {
    final textController = TextEditingController();
    Get.defaultDialog(
      title: "New Workout Day",
      content: TextField(controller: textController, autofocus: true),
      onConfirm: () {
        controller.addDay(textController.text);
        Get.back();
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dumbell': return Icons.fitness_center;
      case 'barbell': return Icons.architecture;
      case 'cable': return Icons.cable;
      default: return Icons.help_outline;
    }
  }
}