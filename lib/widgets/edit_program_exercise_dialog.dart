import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/fuzzy_search.dart';
import 'package:reptrack/widgets/edit_exercise_dialog.dart';

/// Dialog for editing an existing [ExerciseWithVolume] entry in a program day.
///
/// Pre-populates the exercise, equipment, rep scheme, and rest timer from
/// [exerciseWithVolume]. The user can optionally swap the exercise by
/// searching the list. On confirmation, delegates to
/// [BuildProgramController.updateExerciseInDay].
class EditProgramExerciseDialog extends StatefulWidget {
  /// The exercise entry being edited.
  final ExerciseWithVolume exerciseWithVolume;

  const EditProgramExerciseDialog({
    super.key,
    required this.exerciseWithVolume,
  });

  @override
  State<EditProgramExerciseDialog> createState() =>
      _EditProgramExerciseDialogState();
}

class _EditProgramExerciseDialogState extends State<EditProgramExerciseDialog> {
  final TextEditingController searchController = TextEditingController();
  late final TextEditingController timerController;
  late final List<TextEditingController> setControllers;

  late final Rx<Exercise?> selectedExercise;
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;
  late final Rx<int?> selectedEquipmentId;

  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    final vol = widget.exerciseWithVolume;
    selectedExercise = Rx<Exercise?>(vol.exercise);
    selectedEquipmentId = Rx<int?>(vol.volume.equipmentId);
    timerController = TextEditingController(
      text: vol.volume.restTimer?.toString() ?? '60',
    );
    setControllers = vol.volume.setsRepsList
        .map((r) => TextEditingController(text: r.toString()))
        .toList();
    if (setControllers.isEmpty) {
      setControllers.add(TextEditingController(text: '12'));
    }
    _loadInitialData();
  }

  /// Fetches all exercises and the current exercise's equipment options,
  /// pre-populating [filteredExercises] and [availableEquipment].
  Future<void> _loadInitialData() async {
    final controller = Get.find<BuildProgramController>();
    allExercises = await controller.getAvailableExercises();
    filteredExercises.assignAll(allExercises);

    final equips = await Get.find<AppDatabase>().getEquipmentForExercise(
      widget.exerciseWithVolume.exercise.id,
    );
    availableEquipment.assignAll(equips);
  }

  @override
  void dispose() {
    searchController.dispose();
    timerController.dispose();
    for (final c in setControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BuildProgramController>();

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Obx(
              () => Text(
                selectedExercise.value == null
                    ? 'Select Exercise'
                    : 'Edit Exercise',
              ),
            ),
          ),
          Obx(() {
            if (selectedExercise.value == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
              tooltip: 'Edit exercise details',
              onPressed: () async {
                final updated = await Get.dialog<Exercise>(
                  EditExerciseDialog(exercise: selectedExercise.value!),
                );
                if (updated != null) {
                  selectedExercise.value = updated;
                  final equips = await Get.find<AppDatabase>()
                      .getEquipmentForExercise(updated.id);
                  availableEquipment.assignAll(equips);
                  if (!equips.any((e) => e.id == selectedEquipmentId.value)) {
                    selectedEquipmentId.value = equips.length == 1
                        ? equips.first.id
                        : null;
                  }
                  final idx = allExercises.indexWhere(
                    (e) => e.id == updated.id,
                  );
                  if (idx != -1) allExercises[idx] = updated;
                  filteredExercises.assignAll(allExercises);
                }
              },
            );
          }),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Obx(() {
          if (selectedExercise.value == null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search e.g. Bench Press...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    filteredExercises.assignAll(
                      fuzzyFilter(allExercises, val, (e) => e.name),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredExercises.length,
                      itemBuilder: (ctx, i) {
                        final ex = filteredExercises[i];
                        return ListTile(
                          title: Text(ex.name),
                          subtitle: Text(ex.muscleGroup ?? ''),
                          onTap: () async {
                            final equips = await Get.find<AppDatabase>()
                                .getEquipmentForExercise(ex.id);
                            availableEquipment.assignAll(equips);
                            selectedEquipmentId.value = equips.length == 1
                                ? equips.first.id
                                : null;
                            selectedExercise.value = ex;
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Chip(
                        avatar: SvgPicture.asset(
                          'assets/icons/equipments/${widget.exerciseWithVolume.equipment.icon_name}.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.secondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Obx(
                          () => Text(
                            selectedExercise.value?.name ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onDeleted: () {
                          selectedExercise.value = null;
                          selectedEquipmentId.value = null;
                          searchController.clear();
                          filteredExercises.assignAll(allExercises);
                        },
                        deleteIcon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Equipment Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    children: availableEquipment.map((e) {
                      return ChoiceChip(
                        label: Text(e.name),
                        selected: selectedEquipmentId.value == e.id,
                        showCheckmark: false,
                        onSelected: (val) =>
                            selectedEquipmentId.value = val ? e.id : null,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 25),
                ...setControllers.asMap().entries.map((entry) {
                  final i = entry.key;
                  final ctrl = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            'Set ${i + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Reps',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        if (setControllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.error,
                            ),
                            onPressed: () => setState(() {
                              setControllers[i].dispose();
                              setControllers.removeAt(i);
                            }),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() {
                    setControllers.add(
                      TextEditingController(text: setControllers.last.text),
                    );
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('ADD SET'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: timerController,
                  decoration: const InputDecoration(
                    labelText: 'Rest Timer (seconds)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          );
        }),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        Obx(() {
          final bool isValid =
              selectedExercise.value != null &&
              selectedEquipmentId.value != null;
          return ElevatedButton(
            onPressed: !isValid
                ? null
                : () {
                    controller.updateExerciseInDay(
                      widget.exerciseWithVolume.volume.id,
                      selectedExercise.value!,
                      selectedEquipmentId.value!,
                      setControllers
                          .map((c) => int.tryParse(c.text) ?? 0)
                          .toList(),
                      int.tryParse(timerController.text),
                    );
                    Get.back();
                  },
            child: const Text('Save'),
          );
        }),
      ],
    );
  }
}
