import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/widgets/exercise_history_card_widget.dart';
import 'package:reptrack/widgets/edit_exercise_dialog.dart';
import 'package:reptrack/widgets/swap_exercise_dialog.dart';

class ExerciseSwipeCard extends StatelessWidget {
  final ExerciseWithVolume item;
  final int exerciseIndex;
  ExerciseSwipeCard({
    super.key,
    required this.item,
    required this.exerciseIndex,
  });

  final RxList<Equipment> alternatives = <Equipment>[].obs;

  void _loadAlternatives() async {
    final db = Get.find<AppDatabase>();
    final list = await db.getEquipmentForExercise(item.exercise.id);
    alternatives.assignAll(list);
  }

  @override
  Widget build(BuildContext context) {
    _loadAlternatives();
    final controller = Get.find<ActiveWorkoutController>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.exercise.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.primaryMuscleGroup ?? "General",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.secondary,
                    ),
                    onPressed: () async {
                      final updated = await Get.dialog<Exercise>(
                        EditExerciseDialog(exercise: item.exercise),
                      );
                      if (updated != null) {
                        controller.updateExerciseInMemory(
                          exerciseIndex,
                          updated,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.comment_outlined,
                      color: AppColors.secondary,
                    ),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => _ExerciseCommentDialog(
                        exerciseId: item.exercise.id,
                        initialComment: item.exercise.note,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.find_replace,
                      color: AppColors.secondary,
                    ),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => SwapExerciseDialog(
                        exerciseIndex: exerciseIndex,
                        exerciseId: item.exercise.id,
                        exerciseName: item.exercise.name,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: AppColors.secondary),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ExerciseHistoryDialog(
                        exerciseId: item.exercise.id,
                        exerciseName: item.exercise.name,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                "SWITCH EQUIPMENT",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDisabled,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: alternatives.map((e) {
                    final isSelected =
                        controller.selectedEquipments[exerciseIndex] == e.id;
                    return ChoiceChip(
                      label: Text(e.name),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (val) {
                        if (val) {
                          controller.selectedEquipments[exerciseIndex] = e.id;
                        }
                      },
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 30),

              // --- LOGGING SECTION ---
              // --- LOGGING SECTION ---
              Expanded(
                child: Obx(() {
                  // Explicitly observe completedSets so that logging/unlogging
                  // triggers a rebuild of the list (e.g. Dismissible direction).
                  controller.completedSets.length;

                  final currentEquipId =
                      controller.selectedEquipments[exerciseIndex] ??
                      item.equipment.id;
                  final plannedSetsReps = item.volume.setsRepsList;
                  final totalSets = controller.getTotalSetsForExercise(
                    exerciseIndex,
                    plannedSetsReps.length,
                    currentEquipId,
                  );

                  return ListView.builder(
                    itemCount: totalSets + 1,
                    itemBuilder: (context, index) {
                      // 1. Render the Add Button at the very end
                      if (index == totalSets) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                          child: OutlinedButton.icon(
                            onPressed: () => controller.addExtraSet(
                              exerciseIndex,
                              currentEquipId,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text("ADD EXTRA SET"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.outline),
                              shape: const RoundedRectangleBorder(),
                            ),
                          ),
                        );
                      }

                      // 2. Render the Set Rows
                      final setNum = index + 1;
                      final isExtraSet = setNum > plannedSetsReps.length;
                      final isSaved = controller.isSetCompleted(
                        exerciseIndex,
                        currentEquipId,
                        setNum,
                      );

                      // NEW FIX: Is this the very last set in the entire list?
                      final isLastSet = setNum == totalSets;

                      // Include equipmentId so state resets when equipment changes
                      final itemKey = Key(
                        "set_${exerciseIndex}_${currentEquipId}_$setNum",
                      );

                      return Dismissible(
                        key: itemKey,
                        // Only allow swipe-to-delete if it's an extra set, NOT saved, AND it's the bottom-most set
                        direction: (isExtraSet && !isSaved && isLastSet)
                            ? DismissDirection.startToEnd
                            : DismissDirection.none,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          controller.removeExtraSet(
                            exerciseIndex,
                            currentEquipId,
                          );
                        },
                        child: SetLogRow(
                          key: itemKey,
                          setNum: setNum,
                          exerciseIndex: exerciseIndex,
                          exerciseId: item.exercise.id,
                          equipmentId: currentEquipId,
                          plannedReps: isExtraSet
                              ? (plannedSetsReps.isNotEmpty
                                    ? plannedSetsReps.last
                                    : 12)
                              : plannedSetsReps[setNum - 1],
                          plannedWeight: item.volume.weight,
                          restSeconds: item.volume.restTimer ?? 60,
                          totalPlannedSets: plannedSetsReps.length,
                        ),
                      );
                    },
                  );
                }),
              ),
              // --- TIMER FOOTER ---
              Obx(() {
                final timeLeft = controller.remainingRestTime.value;
                if (timeLeft <= 0) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Rest Timer: ${timeLeft}s",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => controller.skipRestTimer(),
                        child: const Text("SKIP"),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCommentDialog extends StatefulWidget {
  final String exerciseId;
  final String? initialComment;

  const _ExerciseCommentDialog({required this.exerciseId, this.initialComment});

  @override
  State<_ExerciseCommentDialog> createState() => _ExerciseCommentDialogState();
}

class _ExerciseCommentDialogState extends State<_ExerciseCommentDialog> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(
      text: widget.initialComment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exercise Note'),
      content: TextField(
        controller: _commentController,
        maxLines: 4,
        inputFormatters: [LengthLimitingTextInputFormatter(500)],
        decoration: const InputDecoration(
          hintText: 'Add a note for this exercise...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () async {
            final db = Get.find<AppDatabase>();
            final note = _commentController.text.trim();
            final savedNote = note.isEmpty ? null : note;
            await db.updateExerciseNote(widget.exerciseId, savedNote);
            Get.find<ActiveWorkoutController>().updateExerciseNoteInMemory(
              widget.exerciseId,
              savedNote,
            );
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}

class SetLogRow extends StatefulWidget {
  final int setNum;
  final int exerciseIndex;
  final String exerciseId;
  final String equipmentId;
  final int plannedReps;
  final double plannedWeight;
  final int restSeconds;
  final int totalPlannedSets;

  const SetLogRow({
    super.key,
    required this.setNum,
    required this.exerciseIndex,
    required this.exerciseId,
    required this.equipmentId,
    required this.plannedReps,
    required this.plannedWeight,
    required this.restSeconds,
    required this.totalPlannedSets,
  });

  @override
  State<SetLogRow> createState() => _SetLogRowState();
}

class _SetLogRowState extends State<SetLogRow> {
  late TextEditingController repsController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ActiveWorkoutController>();

    final lastSessionSet = controller.getLastLoggedSet(
      widget.exerciseIndex,
      widget.equipmentId,
    );
    final pastWorkoutSet = controller.getPastSetData(
      widget.exerciseId,
      widget.setNum,
      widget.equipmentId,
    );

    String initialReps = widget.plannedReps.toString();
    double initialWeightKg = widget.plannedWeight;

    if (lastSessionSet != null) {
      // FIX: Extraction of .value from Drift Companion Value wrapper
      initialReps = lastSessionSet.reps.value.toString();
      initialWeightKg = lastSessionSet.weight.value;
    } else if (pastWorkoutSet != null) {
      initialReps = pastWorkoutSet.reps.toString();
      initialWeightKg = pastWorkoutSet.weight;
    }

    final settings = Get.find<SettingsController>();
    final displayWeight = settings.displayWeight(initialWeightKg);
    final initialWeight = displayWeight == displayWeight.truncateToDouble()
        ? displayWeight.toInt().toString()
        : displayWeight.toStringAsFixed(1);

    repsController = TextEditingController(text: initialReps);
    weightController = TextEditingController(text: initialWeight);
  }

  @override
  void dispose() {
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return Obx(() {
      final bool isSaved = controller.completedSets.contains(
        "${widget.exerciseIndex}-${widget.equipmentId}-${widget.setNum}",
      );

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSaved
              ? AppColors.success.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSaved ? AppColors.success : AppColors.outline,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isSaved ? AppColors.success : AppColors.outline,
              child: Text(
                "${widget.setNum}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: weightController,
                enabled: !isSaved,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  MaxValueInputFormatter(100000),
                ],
                decoration: InputDecoration(
                  labelText: Get.find<SettingsController>().unitLabel
                      .toUpperCase(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: repsController,
                enabled: !isSaved,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  MaxValueInputFormatter(100000),
                ],
                decoration: const InputDecoration(
                  labelText: "Reps",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  isDense: true,
                ),
              ),
            ),
            if (isSaved)
              IconButton(
                icon: const Icon(Icons.check_circle),
                color: AppColors.success,
                tooltip: 'Long press to unlog',
                onPressed: () {},
                onLongPress: () async {
                  await controller.unlogSet(
                    exerciseIndex: widget.exerciseIndex,
                    exerciseId: widget.exerciseId,
                    equipmentId: widget.equipmentId,
                    setNum: widget.setNum,
                  );
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: AppColors.textDisabled,
                onPressed: () async {
                  await controller.logSet(
                    exerciseIndex: widget.exerciseIndex,
                    exerciseId: widget.exerciseId,
                    equipmentId: widget.equipmentId,
                    reps: int.tryParse(repsController.text) ?? 0,
                    weight: Get.find<SettingsController>().toKg(
                      double.tryParse(weightController.text) ?? 0,
                    ),
                    setNum: widget.setNum,
                    restSeconds: widget.restSeconds,
                  );

                  final allDone =
                      List.generate(
                        widget.totalPlannedSets,
                        (i) => i + 1,
                      ).every(
                        (s) => controller.isSetCompleted(
                          widget.exerciseIndex,
                          widget.equipmentId,
                          s,
                        ),
                      );

                  if (allDone) {
                    final current = controller.currentPageIndex.value;
                    final total = controller.exercisesWithVolume.length;
                    if (current < total - 1) {
                      controller.pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
              ),
          ],
        ),
      );
    });
  }
}
