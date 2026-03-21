import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/create_exercise_controller.dart';
import 'package:reptrack/utils/app_theme.dart';

class CreateExerciseDialog extends StatefulWidget {
  const CreateExerciseDialog({super.key});

  @override
  State<CreateExerciseDialog> createState() => _CreateExerciseDialogState();
}

class _CreateExerciseDialogState extends State<CreateExerciseDialog> {
  late CreateExerciseController controller;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController muscleGroupController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateExerciseController());
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
      title: const Text('Create New Exercise'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Name (Required)
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

              // Muscle Group (Optional)
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
              Obx(
                () => controller.muscleGroups.isEmpty
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
                          hintText: 'Select or type muscle group',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: controller.muscleGroups.map((group) {
                          return DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          );
                        }).toList(),
                        onChanged: (value) {
                          muscleGroupController.text = value ?? '';
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Equipment Types (Required)
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
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.availableEquipment.map((equipment) {
                    return FilterChip(
                      label: Text(equipment.name),
                      selected: controller.selectedEquipmentIds.contains(
                        equipment.id,
                      ),
                      showCheckmark: false,
                      onSelected: (_) {
                        controller.toggleEquipment(equipment.id);
                      },
                      backgroundColor: AppColors.surfaceVariant,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color:
                            controller.selectedEquipmentIds.contains(
                              equipment.id,
                            )
                            ? Colors.black
                            : null,
                        fontWeight:
                            controller.selectedEquipmentIds.contains(
                              equipment.id,
                            )
                            ? FontWeight.w600
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Note (Optional)
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
          onPressed: () async {
            final exercise = await controller.createExercise(
              name: nameController.text,
              muscleGroup: muscleGroupController.text.isEmpty
                  ? null
                  : muscleGroupController.text,
              note: noteController.text.isEmpty ? null : noteController.text,
              equipmentIds: controller.selectedEquipmentIds.toSet(),
            );

            if (exercise != null && mounted) {
              Get.back(result: exercise);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
