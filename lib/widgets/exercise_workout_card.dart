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

double distanceUnitToMeters(double value, String unit) {
  switch (unit) {
    case 'km':
      return value * 1000;
    case 'mi':
      return value * 1609.344;
    case 'ft':
      return value * 0.3048;
    default:
      return value;
  }
}

double metersToDistanceUnit(double meters, String unit) {
  switch (unit) {
    case 'km':
      return meters / 1000;
    case 'mi':
      return meters / 1609.344;
    case 'ft':
      return meters / 0.3048;
    default:
      return meters;
  }
}

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
    if (!item.isCardio) _loadAlternatives();
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
                          item.isCardio
                              ? 'Cardio'
                              : item.isHybrid
                              ? 'Hybrid'
                              : (item.primaryMuscleGroup ?? 'General'),
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (!item.isCardio)
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
                  if (!item.isCardio)
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
                        isCardio: item.isCardio,
                        isHybrid: item.isHybrid,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 30),

              if (item.isCardio)
                Expanded(
                  child: CardioLogSection(
                    item: item,
                    exerciseIndex: exerciseIndex,
                  ),
                )
              else if (item.isHybrid)
                Expanded(
                  child: HybridLogSection(
                    item: item,
                    exerciseIndex: exerciseIndex,
                    alternatives: alternatives,
                  ),
                )
              else ...[
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
                Expanded(
                  child: Obx(() {
                    controller.completedSets.length;

                    final currentEquipId =
                        controller.selectedEquipments[exerciseIndex] ??
                        item.equipment?.id ??
                        '';
                    final plannedSetsReps = item.volume.setsRepsList;
                    final totalSets = controller.getTotalSetsForExercise(
                      exerciseIndex,
                      plannedSetsReps.length,
                      currentEquipId,
                    );

                    return ListView.builder(
                      itemCount: totalSets + 1,
                      itemBuilder: (context, index) {
                        if (index == totalSets) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 20,
                            ),
                            child: OutlinedButton.icon(
                              onPressed: () => controller.addExtraSet(
                                exerciseIndex,
                                currentEquipId,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text("ADD EXTRA SET"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(
                                  color: AppColors.outline,
                                ),
                                shape: const RoundedRectangleBorder(),
                              ),
                            ),
                          );
                        }

                        final setNum = index + 1;
                        final isExtraSet = setNum > plannedSetsReps.length;
                        final isSaved = controller.isSetCompleted(
                          exerciseIndex,
                          currentEquipId,
                          setNum,
                        );
                        final isLastSet = setNum == totalSets;
                        final itemKey = Key(
                          "set_${exerciseIndex}_${currentEquipId}_$setNum",
                        );

                        return Dismissible(
                          key: itemKey,
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
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Cardio logging section with duration (h/m/s), optional distance with unit, and log/undo.
class CardioLogSection extends StatefulWidget {
  final ExerciseWithVolume item;
  final int exerciseIndex;

  const CardioLogSection({
    super.key,
    required this.item,
    required this.exerciseIndex,
  });

  @override
  State<CardioLogSection> createState() => _CardioLogSectionState();
}

class _CardioLogSectionState extends State<CardioLogSection> {
  late TextEditingController hoursController;
  late TextEditingController minutesController;
  late TextEditingController secondsController;
  late TextEditingController distanceController;
  final RxString distanceUnit = 'km'.obs;

  @override
  void initState() {
    super.initState();
    final planned = widget.item.volume.seconds ?? 0;
    hoursController = TextEditingController(text: (planned ~/ 3600).toString());
    minutesController = TextEditingController(
      text: ((planned % 3600) ~/ 60).toString(),
    );
    secondsController = TextEditingController(text: (planned % 60).toString());
    final controller = Get.find<ActiveWorkoutController>();
    final lastSet = controller.lastCardioSets[widget.item.exercise.id];
    if (lastSet != null) distanceUnit.value = lastSet.distanceUnit;
    final lastDist = lastSet?.distanceMeters == null
        ? null
        : metersToDistanceUnit(lastSet!.distanceMeters!, lastSet.distanceUnit);
    distanceController = TextEditingController(
      text: lastDist == null
          ? ''
          : (lastDist == lastDist.truncateToDouble()
                ? lastDist.toInt().toString()
                : lastDist.toStringAsFixed(2)),
    );
  }

  @override
  void dispose() {
    hoursController.dispose();
    minutesController.dispose();
    secondsController.dispose();
    distanceController.dispose();
    super.dispose();
  }

  /// Converts the entered distance value to meters based on the selected unit.
  double? _toMeters(String text) {
    final value = double.tryParse(text.trim());
    if (value == null) return null;
    return distanceUnitToMeters(value, distanceUnit.value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return Obx(() {
      final isDone = controller.isCardioCompleted(widget.exerciseIndex);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.item.volume.durationLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "Target: ${widget.item.volume.durationLabel}",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (widget.item.volume.distancePlanned != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "Target distance: ${widget.item.volume.distancePlanned!.toStringAsFixed(1)} ${widget.item.volume.distancePlannedUnit}",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const Text(
            "DURATION",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textDisabled,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: hoursController,
                  enabled: !isDone,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MaxValueInputFormatter(23),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Hours",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: minutesController,
                  enabled: !isDone,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MaxValueInputFormatter(59),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Minutes",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: secondsController,
                  enabled: !isDone,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MaxValueInputFormatter(59),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Seconds",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "DISTANCE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textDisabled,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: distanceController,
                  enabled: !isDone,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Distance (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => _DistanceUnitSelector(
                  selected: distanceUnit.value,
                  enabled: !isDone,
                  onChanged: (unit) => distanceUnit.value = unit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDone ? AppColors.success : AppColors.outline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.check_circle_outline,
                  color: isDone ? AppColors.success : AppColors.textDisabled,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isDone ? "Logged" : "Not logged",
                    style: TextStyle(
                      color: isDone
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isDone)
                  TextButton(
                    onPressed: () => controller.unlogCardio(
                      exerciseIndex: widget.exerciseIndex,
                      exerciseId: widget.item.exercise.id,
                    ),
                    child: const Text("UNDO"),
                  )
                else
                  FilledButton.icon(
                    onPressed: () {
                      final hours = int.tryParse(hoursController.text) ?? 0;
                      final minutes = int.tryParse(minutesController.text) ?? 0;
                      final seconds = int.tryParse(secondsController.text) ?? 0;
                      final distText = distanceController.text.trim();
                      controller.logCardio(
                        exerciseIndex: widget.exerciseIndex,
                        exerciseId: widget.item.exercise.id,
                        durationSeconds: hours * 3600 + minutes * 60 + seconds,
                        distanceMeters: distText.isEmpty
                            ? null
                            : _toMeters(distText),
                        distanceUnit: distanceUnit.value,
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("LOG"),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

/// Hybrid exercise logging section with equipment selector, unit selector, and per-set rows.
class HybridLogSection extends StatefulWidget {
  final ExerciseWithVolume item;
  final int exerciseIndex;
  final RxList<Equipment> alternatives;

  const HybridLogSection({
    super.key,
    required this.item,
    required this.exerciseIndex,
    required this.alternatives,
  });

  @override
  State<HybridLogSection> createState() => _HybridLogSectionState();
}

class _HybridLogSectionState extends State<HybridLogSection> {
  final RxString distanceUnit = 'm'.obs;

  @override
  void initState() {
    super.initState();
    final lastSet = Get.find<ActiveWorkoutController>()
        .lastHybridSets[widget.item.exercise.id]
        ?.firstOrNull;
    distanceUnit.value =
        lastSet?.distanceUnit ?? widget.item.volume.distanceUnit;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            children: widget.alternatives.map((e) {
              final isSelected =
                  controller.selectedEquipments[widget.exerciseIndex] == e.id;
              return ChoiceChip(
                label: Text(e.name),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (val) {
                  if (val) {
                    controller.selectedEquipments[widget.exerciseIndex] = e.id;
                  }
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              "DISTANCE UNIT",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textDisabled,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => _DistanceUnitSelector(
                selected: distanceUnit.value,
                enabled: true,
                onChanged: (unit) => distanceUnit.value = unit,
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        Expanded(
          child: Obx(() {
            controller.completedSets.length;
            final currentEquipId =
                controller.selectedEquipments[widget.exerciseIndex] ??
                widget.item.equipment?.id ??
                '';
            final plannedDistances = widget.item.volume.setsDistancesList;
            final totalSets = controller.getTotalSetsForExercise(
              widget.exerciseIndex,
              plannedDistances.length,
              currentEquipId,
            );

            return ListView.builder(
              itemCount: totalSets + 1,
              itemBuilder: (context, index) {
                if (index == totalSets) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                    child: OutlinedButton.icon(
                      onPressed: () => controller.addExtraSet(
                        widget.exerciseIndex,
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

                final setNum = index + 1;
                final isExtraSet = setNum > plannedDistances.length;
                final isSaved = controller.isSetCompleted(
                  widget.exerciseIndex,
                  currentEquipId,
                  setNum,
                );
                final isLastSet = setNum == totalSets;
                final itemKey = Key(
                  "hset_${widget.exerciseIndex}_${currentEquipId}_$setNum",
                );

                return Dismissible(
                  key: itemKey,
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
                  onDismissed: (_) => controller.removeExtraSet(
                    widget.exerciseIndex,
                    currentEquipId,
                  ),
                  child: Obx(
                    () => HybridSetRow(
                      key: itemKey,
                      setNum: setNum,
                      exerciseIndex: widget.exerciseIndex,
                      exerciseId: widget.item.exercise.id,
                      equipmentId: currentEquipId,
                      plannedDistance: isExtraSet
                          ? (plannedDistances.isNotEmpty
                                ? plannedDistances.last
                                : 100.0)
                          : plannedDistances[setNum - 1],
                      plannedWeight: widget.item.volume.weight,
                      distanceUnit: distanceUnit.value,
                      restSeconds: widget.item.volume.restTimer ?? 60,
                      totalPlannedSets: plannedDistances.length,
                    ),
                  ),
                );
              },
            );
          }),
        ),
        Obx(() {
          final timeLeft = controller.remainingRestTime.value;
          if (timeLeft <= 0) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}

/// Compact unit selector for distance input (m / km / mi).
class _DistanceUnitSelector extends StatelessWidget {
  final String selected;
  final bool enabled;
  final void Function(String) onChanged;

  const _DistanceUnitSelector({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const units = ['m', 'km', 'ft', 'mi'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: units.map((unit) {
        final isSelected = selected == unit;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: ChoiceChip(
            label: Text(unit),
            selected: isSelected,
            showCheckmark: false,
            onSelected: enabled ? (_) => onChanged(unit) : null,
            labelStyle: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.black : AppColors.textSecondary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        );
      }).toList(),
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

/// A single strength set row with weight and reps inputs.
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
  double _currentKg = 0;
  late Worker _unitWorker;

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
      initialReps = lastSessionSet.reps.value.toString();
      initialWeightKg = lastSessionSet.weight.value;
    } else if (pastWorkoutSet != null) {
      initialReps = pastWorkoutSet.reps.toString();
      initialWeightKg = pastWorkoutSet.weight;
    }

    _currentKg = initialWeightKg;
    final settings = Get.find<SettingsController>();
    final displayWeight = settings.displayWeight(_currentKg);
    final initialWeight = displayWeight == displayWeight.truncateToDouble()
        ? displayWeight.toInt().toString()
        : displayWeight.toStringAsFixed(1);

    repsController = TextEditingController(text: initialReps);
    weightController = TextEditingController(text: initialWeight);

    _unitWorker = ever(settings.useImperial, (bool nowImperial) {
      // useImperial already flipped; text still shows the OLD unit.
      final parsed = double.tryParse(weightController.text);
      if (parsed != null) {
        // Convert text (old unit) → kg.
        _currentKg = nowImperial ? parsed : parsed / 2.20462;
      }
      final d = settings.displayWeight(_currentKg);
      weightController.text = d == d.truncateToDouble()
          ? d.toInt().toString()
          : d.toStringAsFixed(1);
    });
  }

  @override
  void dispose() {
    _unitWorker.dispose();
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final bool isSaved = controller.completedSets.contains(
        "${widget.exerciseIndex}-${widget.equipmentId}-${widget.setNum}",
      );
      final unitLabel = settings.useImperial.value ? 'LBS' : 'KG';

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
                  labelText: unitLabel,
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

/// A single hybrid set row with weight and distance inputs.
class HybridSetRow extends StatefulWidget {
  final int setNum;
  final int exerciseIndex;
  final String exerciseId;
  final String equipmentId;
  final double plannedDistance;
  final double plannedWeight;
  final String distanceUnit;
  final int restSeconds;
  final int totalPlannedSets;

  const HybridSetRow({
    super.key,
    required this.setNum,
    required this.exerciseIndex,
    required this.exerciseId,
    required this.equipmentId,
    required this.plannedDistance,
    required this.plannedWeight,
    required this.distanceUnit,
    required this.restSeconds,
    required this.totalPlannedSets,
  });

  @override
  State<HybridSetRow> createState() => _HybridSetRowState();
}

class _HybridSetRowState extends State<HybridSetRow> {
  late TextEditingController weightController;
  late TextEditingController distanceController;
  double _currentKg = 0;
  late Worker _unitWorker;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ActiveWorkoutController>();
    final past = controller.getPastHybridSetData(
      widget.exerciseId,
      widget.setNum,
      widget.equipmentId,
    );

    final settings = Get.find<SettingsController>();
    _currentKg = past?.weight ?? widget.plannedWeight;
    final displayWeight = settings.displayWeight(_currentKg);
    final initialWeight = displayWeight == displayWeight.truncateToDouble()
        ? displayWeight.toInt().toString()
        : displayWeight.toStringAsFixed(1);

    double rawDist;
    if (past != null && past.distanceUnit != widget.distanceUnit) {
      final meters = distanceUnitToMeters(past.distance, past.distanceUnit);
      rawDist = metersToDistanceUnit(meters, widget.distanceUnit);
    } else {
      rawDist = past?.distance ?? widget.plannedDistance;
    }
    final initialDist = rawDist == rawDist.truncateToDouble()
        ? rawDist.toInt().toString()
        : rawDist.toStringAsFixed(1);

    weightController = TextEditingController(text: initialWeight);
    distanceController = TextEditingController(text: initialDist);

    _unitWorker = ever(settings.useImperial, (bool nowImperial) {
      // useImperial already flipped; text still shows the OLD unit.
      final parsed = double.tryParse(weightController.text);
      if (parsed != null) {
        _currentKg = nowImperial ? parsed : parsed / 2.20462;
      }
      final d = settings.displayWeight(_currentKg);
      weightController.text = d == d.truncateToDouble()
          ? d.toInt().toString()
          : d.toStringAsFixed(1);
    });
  }

  @override
  void dispose() {
    _unitWorker.dispose();
    weightController.dispose();
    distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final bool isSaved = controller.completedSets.contains(
        "${widget.exerciseIndex}-${widget.equipmentId}-${widget.setNum}",
      );
      final unitLabel = settings.useImperial.value ? 'LBS' : 'KG';

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
                  labelText: unitLabel,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: distanceController,
                enabled: !isSaved,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  MaxValueInputFormatter(100000),
                ],
                decoration: InputDecoration(
                  labelText: widget.distanceUnit,
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
                  await controller.unlogHybridSet(
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
                  await controller.logHybridSet(
                    exerciseIndex: widget.exerciseIndex,
                    exerciseId: widget.exerciseId,
                    equipmentId: widget.equipmentId,
                    weight: Get.find<SettingsController>().toKg(
                      double.tryParse(weightController.text) ?? 0,
                    ),
                    distance: double.tryParse(distanceController.text) ?? 0,
                    distanceUnit: widget.distanceUnit,
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
