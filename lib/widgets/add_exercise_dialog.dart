import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/persistance/database.dart';

class AddExerciseDialog extends StatefulWidget {
  final int dayId;
  const AddExerciseDialog({super.key, required this.dayId});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  // Use standard controllers to avoid Rx lag in text fields
  final TextEditingController searchController = TextEditingController();
  final TextEditingController setsController = TextEditingController(text: "3");
  final TextEditingController repsController = TextEditingController(text: "10");

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
      title: Obx(() => Text(selectedExercise.value == null 
          ? "Select Exercise" 
          : "Set Volume")),
      content: SizedBox(
        width: double.maxFinite,
        child: Obx(() {
          // STEP 1: If no exercise is selected, show ONLY the search list
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
                    filteredExercises.assignAll(allExercises.where((e) =>
                        e.name.toLowerCase().contains(val.toLowerCase())));
                  },
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
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
                            // Fetch equipment first
                            final equips = await Get.find<AppDatabase>()
                                .getEquipmentForExercise(ex.id);
                            
                            // Then update state
                            availableEquipment.assignAll(equips);
                            selectedEquipmentId.value = equips.length == 1 
                                ? equips.first.id 
                                : null;
                            selectedExercise.value = ex;
                            
                            // Kill keyboard
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          // STEP 2: Exercise is selected, show ONLY the equipment/volume form
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selection Summary Chip
              Chip(
                label: Text(selectedExercise.value!.name),
                onDeleted: () {
                  selectedExercise.value = null;
                  selectedEquipmentId.value = null;
                },
                deleteIcon: const Icon(Icons.close),
              ),
              const SizedBox(height: 20),
              
              // Equipment Choice
              const Text("Equipment Type", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableEquipment.map((e) {
                  return ChoiceChip(
                    label: Text(e.name),
                    selected: selectedEquipmentId.value == e.id,
                    onSelected: (val) => selectedEquipmentId.value = val ? e.id : null,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 25),
              
              // Volume Inputs
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      decoration: const InputDecoration(labelText: "Sets", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      decoration: const InputDecoration(labelText: "Reps", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        Obx(() {
          // Final validation
          bool isValid = selectedExercise.value != null && 
                         selectedEquipmentId.value != null;
          
          return ElevatedButton(
            onPressed: !isValid ? null : () {
              controller.addExerciseToDay(
                widget.dayId,
                selectedExercise.value!,
                selectedEquipmentId.value!,
                int.tryParse(setsController.text) ?? 0,
                int.tryParse(repsController.text) ?? 0,
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