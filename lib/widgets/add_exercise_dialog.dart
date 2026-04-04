import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/fuzzy_search.dart';
import 'package:reptrack/widgets/create_exercise_dialog.dart';
import 'package:reptrack/widgets/edit_exercise_dialog.dart';

/// Dialog for adding an exercise to a workout day.
///
/// Presents a two-step flow:
/// 1. **Select** — fuzzy-search the exercise list; optionally create or edit
///    an exercise inline.
/// 2. **Configure** — choose equipment, per-set rep targets, and rest timer.
///
/// On confirmation, delegates to [BuildProgramController.addExerciseToDay].
class AddExerciseDialog extends StatefulWidget {
  /// The workout day ID that the selected exercise will be added to.
  final String dayId;

  const AddExerciseDialog({super.key, required this.dayId});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController timerController = TextEditingController(
    text: "0",
  );
  final List<TextEditingController> setControllers = [
    TextEditingController(text: "12"),
    TextEditingController(text: "12"),
    TextEditingController(text: "12"),
  ];

  final Rx<Exercise?> selectedExercise = Rx<Exercise?>(null);
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;
  final Rx<String?> selectedEquipmentId = Rx<String?>(null);

  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Loads all available exercises via [BuildProgramController] and
  /// initialises [filteredExercises].
  void _loadInitialData() async {
    final controller = Get.find<BuildProgramController>();
    allExercises = await controller.getAvailableExercises();
    filteredExercises.assignAll(allExercises);
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
                    ? "Select Exercise"
                    : "Set Volume",
              ),
            ),
          ),
          Obx(() {
            if (selectedExercise.value == null) {
              return IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                tooltip: 'Create new exercise',
                onPressed: () async {
                  final newExercise = await Get.dialog<Exercise>(
                    const CreateExerciseDialog(),
                  );
                  if (newExercise != null) {
                    allExercises.add(newExercise);
                    filteredExercises.assignAll(allExercises);
                  }
                },
              );
            }
            return IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
              tooltip: 'Edit exercise',
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
                    hintText: "Search e.g. Bench Press...",
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
                    constraints: BoxConstraints(
                      maxHeight:
                          (MediaQuery.sizeOf(context).height -
                              MediaQuery.viewInsetsOf(context).bottom) *
                          0.35,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: filteredExercises.length,
                      itemBuilder: (ctx, i) {
                        final ex = filteredExercises[i];
                        return ListTile(
                          title: Text(ex.name),
                          onTap: () async {
                            final equips = await Get.find<AppDatabase>()
                                .getEquipmentForExercise(ex.id);

                            availableEquipment.assignAll(equips);
                            selectedEquipmentId.value = equips.length == 1
                                ? equips.first.id
                                : null;
                            selectedExercise.value = ex;

                            if (context.mounted) {
                              FocusScope.of(context).unfocus();
                            }
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
                Chip(
                  label: Text(selectedExercise.value!.name),
                  onDeleted: () {
                    selectedExercise.value = null;
                    selectedEquipmentId.value = null;
                  },
                  deleteIcon: const Icon(Icons.close),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Equipment Type",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                            "Set ${i + 1}",
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              MaxValueInputFormatter(100000),
                            ],
                            decoration: const InputDecoration(
                              labelText: "Reps",
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
                  label: const Text("ADD SET"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: timerController,
                  decoration: const InputDecoration(
                    labelText: "Rest Timer (seconds)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MaxValueInputFormatter(100000),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        Obx(() {
          final bool isValid =
              selectedExercise.value != null &&
              selectedEquipmentId.value != null;

          return ElevatedButton(
            onPressed: !isValid
                ? null
                : () {
                    controller.addExerciseToDay(
                      widget.dayId,
                      selectedExercise.value!,
                      selectedEquipmentId.value!,
                      setControllers
                          .map((c) => int.tryParse(c.text) ?? 0)
                          .toList(),
                      int.tryParse(timerController.text),
                    );
                    Get.back();
                  },
            child: const Text("Confirm"),
          );
        }),
      ],
    );
  }
}
