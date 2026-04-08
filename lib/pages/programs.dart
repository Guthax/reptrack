import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/pages/build_program.dart';
import 'package:reptrack/pages/settings.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/widgets/hint_bubble.dart';
import '../controllers/programs_controller.dart';

/// Page that lists all training programs and allows creating or deleting them.
///
/// Tapping a program navigates to [BuildProgramPage]. Tapping the FAB opens
/// a dialog to create a new program and then immediately navigates to it.
class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgramsController controller = Get.put(ProgramsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.programs.isEmpty) {
                return const Center(
                  child: Text("No programs yet. Tap + to add one!"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: controller.programs.length,
                itemBuilder: (context, index) {
                  final program = controller.programs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          Get.to(() => BuildProgramPage(program: program)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                program.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => Get.dialog(
                                AlertDialog(
                                  title: const Text("Delete Program?"),
                                  content: Text(
                                    'Are you sure you want to delete "${program.name}"?',
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
                                        controller.deleteProgram(program);
                                        Get.back();
                                      },
                                      child: const Text("DELETE"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        final settings = Get.find<SettingsController>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (settings.showAddProgramHint.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: HintBubble(
                  message: 'Tap + to create your first workout program',
                  arrowDirection: HintArrowDirection.down,
                  onDismiss: settings.dismissAddProgramHint,
                ),
              ),
            FloatingActionButton(
              onPressed: () {
                settings.dismissAddProgramHint();
                _showAddProgramDialog(controller);
              },
              child: const Icon(Icons.add),
            ),
          ],
        );
      }),
    );
  }

  /// Shows an [AlertDialog] that lets the user name a new program.
  ///
  /// On confirmation, delegates creation to [controller] and navigates
  /// to [BuildProgramPage] for the newly created program.
  void _showAddProgramDialog(ProgramsController controller) {
    final TextEditingController nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("New Program"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          decoration: const InputDecoration(
            hintText: "Enter program name (e.g. Push Pull Legs)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              nameController.dispose();
            },
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final newProgram = await controller.addProgram(
                  nameController.text.trim(),
                );
                Get.back();
                nameController.dispose();
                if (newProgram != null) {
                  Get.to(() => BuildProgramPage(program: newProgram));
                }
              }
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }
}
