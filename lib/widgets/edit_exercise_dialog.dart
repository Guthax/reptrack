import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';

// ignore_for_file: use_build_context_synchronously

class EditExerciseDialog extends StatefulWidget {
  final Exercise exercise;

  const EditExerciseDialog({super.key, required this.exercise});

  @override
  State<EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<EditExerciseDialog> {
  final AppDatabase db = Get.find<AppDatabase>();

  late final TextEditingController nameController;
  late final TextEditingController muscleGroupController;
  late final TextEditingController noteController;

  List<String> muscleGroups = [];
  List<Equipment> availableEquipment = [];
  Set<int> selectedEquipmentIds = {};

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.exercise.name);
    muscleGroupController = TextEditingController(
      text: widget.exercise.muscleGroup ?? '',
    );
    noteController = TextEditingController(text: widget.exercise.note ?? '');
    _loadData();
  }

  Future<void> _loadData() async {
    final groups = await db.select(db.muscleGroups).get();
    final equips = await db.select(db.equipments).get();
    final currentEquips = await db.getEquipmentForExercise(widget.exercise.id);

    if (mounted) {
      setState(() {
        muscleGroups = groups.map((g) => g.name).toList();
        availableEquipment = equips;
        selectedEquipmentIds = currentEquips.map((e) => e.id).toSet();
        _loaded = true;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    muscleGroupController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Exercise'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      content: !_loaded
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exercise Name *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'e.g. Bench Press',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Muscle Group',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    muscleGroups.isEmpty
                        ? TextField(
                            controller: muscleGroupController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Chest',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            initialValue: muscleGroupController.text.isEmpty
                                ? null
                                : muscleGroupController.text,
                            decoration: InputDecoration(
                              hintText: 'Select muscle group',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: muscleGroups.map((group) {
                              return DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              );
                            }).toList(),
                            onChanged: (value) {
                              muscleGroupController.text = value ?? '';
                            },
                          ),
                    const SizedBox(height: 20),
                    const Text(
                      'Equipment Types *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableEquipment.map((equipment) {
                        final selected = selectedEquipmentIds.contains(
                          equipment.id,
                        );
                        return FilterChip(
                          label: Text(equipment.name),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (_) => setState(() {
                            if (selected) {
                              selectedEquipmentIds.remove(equipment.id);
                            } else {
                              selectedEquipmentIds.add(equipment.id);
                            }
                          }),
                          backgroundColor: AppColors.surfaceVariant,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selected ? Colors.black : null,
                            fontWeight: selected ? FontWeight.w600 : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Note',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about this exercise...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          onPressed: !_loaded
              ? null
              : () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    AppSnackbar.error('Exercise name is required');
                    return;
                  }
                  if (selectedEquipmentIds.isEmpty) {
                    AppSnackbar.error(
                      'Please select at least one equipment type',
                    );
                    return;
                  }
                  if (name.toLowerCase() !=
                      widget.exercise.name.toLowerCase()) {
                    final existing = await db.getExerciseByName(name);
                    if (existing != null) {
                      AppSnackbar.error('"$name" already exists');
                      return;
                    }
                  }
                  final muscleGroup = muscleGroupController.text.trim();
                  final note = noteController.text.trim();
                  await db.updateExerciseDetails(
                    widget.exercise.id,
                    name,
                    muscleGroup.isEmpty ? null : muscleGroup,
                    note.isEmpty ? null : note,
                    selectedEquipmentIds,
                  );
                  AppSnackbar.success('"$name" updated');
                  Get.back(
                    result: Exercise(
                      id: widget.exercise.id,
                      name: name,
                      muscleGroup: muscleGroup.isEmpty ? null : muscleGroup,
                      note: note.isEmpty ? null : note,
                      timer: widget.exercise.timer,
                    ),
                  );
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
