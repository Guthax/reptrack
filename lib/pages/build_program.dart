import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/widgets/add_exercise_dialog.dart';
import 'package:reptrack/widgets/edit_program_exercise_dialog.dart';
import 'package:reptrack/widgets/workout_information_dialog.dart';

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

        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemCount: controller.daysWithExercises.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;
            final reordered = [...controller.daysWithExercises];
            final item = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, item);
            controller.reorderDays(reordered);
          },
          itemBuilder: (context, index) {
            final entry = controller.daysWithExercises[index];
            return _buildDayCard(entry, index);
          },
        );
      }),
    );
  }

  Widget _buildDayCard(WorkoutDayWithExercises entry, int index) {
    final day = entry.workoutDay;
    final exercises = entry.exercises;

    return Card(
      key: ValueKey(day.id),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 8),
            Text(
              day.dayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () =>
                  Get.dialog(WorkoutInformationDialog(dayWithExercises: entry)),
              child: const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Text("${exercises.length} Exercises"),
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        children: [
          ReorderableListView(
            buildDefaultDragHandles: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final reordered = [...exercises];
              final item = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, item);
              controller.reorderExercisesInDay(reordered);
            },
            children: exercises
                .map(
                  (ex) => ListTile(
                    key: ValueKey(ex.volume.id),
                    leading: SvgPicture.asset(
                      'assets/icons/equipments/${ex.equipment.icon_name}.svg',
                      width: 36,
                      height: 36,
                      colorFilter: const ColorFilter.mode(
                        AppColors.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            ex.exercise.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              ex.volume.setsRepsLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const Expanded(flex: 1, child: SizedBox()),
                      ],
                    ),
                    subtitle: Text(
                      "${ex.exercise.muscleGroup} • ${ex.equipment.name}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: AppColors.primary,
                          onPressed: () => Get.dialog(
                            EditProgramExerciseDialog(exerciseWithVolume: ex),
                          ),
                        ),
                        ReorderableDragStartListener(
                          index: exercises.indexOf(ex),
                          child: const Icon(
                            Icons.drag_handle,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () => Get.dialog(
                            AlertDialog(
                              title: const Text("Remove Exercise?"),
                              content: Text(
                                'Remove "${ex.exercise.name}" from this day?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: Get.back,
                                  child: const Text("CANCEL"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    controller.removeExerciseFromDay(
                                      day.id,
                                      ex.exercise.id,
                                    );
                                    Get.back();
                                  },
                                  child: const Text("REMOVE"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () => Get.dialog(AddExerciseDialog(dayId: day.id)),
              icon: const Icon(Icons.add),
              label: const Text("Add Exercise"),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDayDialog() {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("New Workout Day"),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "e.g. Push Day"),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              controller.addDay(textController.text);
              Get.back();
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }
}
