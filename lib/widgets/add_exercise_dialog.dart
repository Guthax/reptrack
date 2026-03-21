import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/fuzzy_search.dart';

class AddExerciseDialog extends StatefulWidget {
  final int dayId;
  const AddExerciseDialog({super.key, required this.dayId});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController setsController = TextEditingController(text: "3");
  final TextEditingController repsController = TextEditingController(
    text: "10",
  );
  final TextEditingController timerController = TextEditingController(
    text: "60",
  );

  final Rx<Exercise?> selectedExercise = Rx<Exercise?>(null);
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;
  final Rx<int?> selectedEquipmentId = Rx<int?>(null);

  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final controller = Get.find<BuildProgramController>();
    allExercises = await controller.getAvailableExercises();
    filteredExercises.assignAll(allExercises);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BuildProgramController>();

    return AlertDialog(
      title: Obx(
        () => Text(
          selectedExercise.value == null ? "Select Exercise" : "Set Volume",
        ),
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
                          subtitle: Text(ex.muscleGroup ?? ""),
                          onTap: () async {
                            final equips = await Get.find<AppDatabase>()
                                .getEquipmentForExercise(ex.id);

                            availableEquipment.assignAll(equips);
                            selectedEquipmentId.value = equips.length == 1
                                ? equips.first.id
                                : null;
                            selectedExercise.value = ex;

                            if (mounted) FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
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
                children: availableEquipment.map((e) {
                  return ChoiceChip(
                    label: Text(e.name),
                    selected: selectedEquipmentId.value == e.id,
                    onSelected: (val) =>
                        selectedEquipmentId.value = val ? e.id : null,
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        labelText: "Sets",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: "Reps",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
              ),
            ],
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
                      int.tryParse(setsController.text) ?? 0,
                      int.tryParse(repsController.text) ?? 0,
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
