import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/pages/settings.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/widgets/add_exercise_dialog.dart';
import 'package:reptrack/widgets/edit_program_exercise_dialog.dart';
import 'package:reptrack/widgets/hint_bubble.dart';
import 'package:reptrack/widgets/workout_information_dialog.dart';

/// Page for editing the workout days and exercises of a [Program].
///
/// Workout days are displayed as reorderable expansion tiles; each tile
/// contains a reorderable list of [ExerciseWithVolume] entries.
///
/// A fresh [BuildProgramController] is force-registered on each navigation
/// to ensure stale state from a previous program is never reused.
class BuildProgramPage extends StatelessWidget {
  /// The program being edited.
  final Program program;

  late final BuildProgramController controller;

  /// Creates a [BuildProgramPage] for [program].
  ///
  /// Deletes any previously registered [BuildProgramController] before
  /// registering a new one, preventing stale-controller bugs when the user
  /// navigates between different programs.
  BuildProgramPage({super.key, required this.program}) {
    if (Get.isRegistered<BuildProgramController>()) {
      Get.delete<BuildProgramController>(force: true);
    }
    controller = Get.put(BuildProgramController(program.id, program.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => GestureDetector(
            onTap: () => _showRenameProgramDialog(),
            child: Text('Edit ${controller.programName}'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.find<SettingsController>().dismissAddDayHint();
              _showAddDayDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
      ),
      body: Obx(() {
        final settings = Get.find<SettingsController>();
        final hint = settings.showAddDayHint.value
            ? Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                  child: HintBubble(
                    message: 'Tap + to add a workout day',
                    arrowDirection: HintArrowDirection.up,
                    onDismiss: settings.dismissAddDayHint,
                  ),
                ),
              )
            : null;

        if (controller.daysWithExercises.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hint != null) hint,
              const Expanded(
                child: Center(child: Text("No workout days added yet.")),
              ),
            ],
          );
        }

        return Column(
          children: [
            if (hint != null) hint,
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 8,
                ),
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
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Builds an expansion tile card for a single [entry] (workout day + exercises).
  ///
  /// Includes a drag handle for day reordering, an info icon, and a nested
  /// reorderable list of exercises with edit/delete controls.
  Widget _buildDayCard(WorkoutDayWithExercises entry, int index) {
    final day = entry.workoutDay;
    final exercises = entry.exercises;
    final settings = Get.find<SettingsController>();

    return KeyedSubtree(
      key: ValueKey(day.id),
      child: Obx(() {
        final hintVisible = settings.showExpandDayHint.value;
        final showHint = index == 0 && hintVisible;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showHint)
              Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 4),
                child: HintBubble(
                  message:
                      'Tap the arrow to see your workout and add exercises',
                  arrowDirection: HintArrowDirection.down,
                  onDismiss: settings.dismissExpandDayHint,
                ),
              ),
            GestureDetector(
              onLongPress: () => Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text('Rename'),
                        onTap: () {
                          Get.back();
                          _showRenameDayDialog(day.id, day.dayName);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        title: const Text('Delete'),
                        onTap: () {
                          Get.back();
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Delete Day?'),
                              content: Text(
                                'Delete "${day.dayName}" and all its exercises?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: Get.back,
                                  child: const Text('CANCEL'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    controller.deleteDay(day.id);
                                    Get.back();
                                  },
                                  child: const Text('DELETE'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  onExpansionChanged: (_) => settings.dismissExpandDayHint(),
                  title: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showRenameDayDialog(day.id, day.dayName),
                        child: Text(
                          day.dayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Get.dialog(
                          WorkoutInformationDialog(dayWithExercises: entry),
                        ),
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
                              leading: ex.isCardio
                                  ? const Icon(
                                      Icons.directions_run,
                                      size: 36,
                                      color: AppColors.secondary,
                                    )
                                  : (ex.equipment!.iconName == 'no_equipment'
                                        ? const Icon(
                                            Icons.accessibility_new,
                                            size: 36,
                                            color: AppColors.secondary,
                                          )
                                        : SvgPicture.asset(
                                            'assets/icons/equipments/${ex.equipment!.iconName}.svg',
                                            width: 36,
                                            height: 36,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.secondary,
                                              BlendMode.srcIn,
                                            ),
                                          )),
                              title: Text(
                                ex.exercise.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: ex.isCardio
                                  ? Text('Cardio • ${ex.volume.durationLabel}')
                                  : ex.isHybrid
                                  ? Text(
                                      '${ex.equipment != null ? '${ex.equipment!.name} • ' : ''}${ex.volume.setsDistancesLabel}',
                                    )
                                  : Text(
                                      '${ex.primaryMuscleGroup != null ? '${ex.primaryMuscleGroup} • ' : ''}${ex.equipment!.name} • ${ex.volume.setsRepsLabel}',
                                    ),
                              trailing: ReorderableDragStartListener(
                                index: exercises.indexOf(ex),
                                child: const Icon(
                                  Icons.drag_handle,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              onTap: () => Get.dialog(
                                EditProgramExerciseDialog(
                                  exerciseWithVolume: ex,
                                ),
                              ),
                              onLongPress: () => Get.bottomSheet(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      Get.context!,
                                    ).colorScheme.surface,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(
                                          Icons.edit_outlined,
                                          color: AppColors.primary,
                                        ),
                                        title: const Text('Edit'),
                                        onTap: () {
                                          Get.back();
                                          Get.dialog(
                                            EditProgramExerciseDialog(
                                              exerciseWithVolume: ex,
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                        ),
                                        title: const Text('Remove'),
                                        onTap: () {
                                          Get.back();
                                          Get.dialog(
                                            AlertDialog(
                                              title: const Text(
                                                'Remove Exercise?',
                                              ),
                                              content: Text(
                                                'Remove "${ex.exercise.name}" from this day?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: Get.back,
                                                  child: const Text('CANCEL'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors.error,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                  onPressed: () {
                                                    controller
                                                        .removeExerciseFromDay(
                                                          ex.volume,
                                                        );
                                                    Get.back();
                                                  },
                                                  child: const Text('REMOVE'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        onPressed: () =>
                            Get.dialog(AddExerciseDialog(dayId: day.id)),
                        icon: const Icon(Icons.add),
                        label: const Text("Add Exercise"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showRenameProgramDialog() {
    final textController = TextEditingController(
      text: controller.programName.value,
    );
    Get.dialog(
      AlertDialog(
        title: const Text("Rename Program"),
        content: TextField(
          controller: textController,
          autofocus: true,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          decoration: const InputDecoration(hintText: "Program name"),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              controller.renameProgram(textController.text);
              Get.back();
            },
            child: const Text("RENAME"),
          ),
        ],
      ),
    );
  }

  void _showRenameDayDialog(String dayId, String currentName) {
    final textController = TextEditingController(text: currentName);
    Get.dialog(
      AlertDialog(
        title: const Text("Rename Day"),
        content: TextField(
          controller: textController,
          autofocus: true,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          decoration: const InputDecoration(hintText: "Day name"),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              controller.renameDay(dayId, textController.text);
              Get.back();
            },
            child: const Text("RENAME"),
          ),
        ],
      ),
    );
  }

  /// Shows an [AlertDialog] that lets the user name a new workout day.
  ///
  /// Delegates creation to [BuildProgramController.addDay].
  void _showAddDayDialog() {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("New Workout Day"),
        content: TextField(
          controller: textController,
          autofocus: true,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
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
