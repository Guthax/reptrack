import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reptrack/pages/build_program.dart';
import 'package:reptrack/utils/app_theme.dart';
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
      appBar: AppBar(title: const Text('Programs')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Workouts', style: TextStyle(fontSize: 18)),
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.programs.length,
                itemBuilder: (context, index) {
                  final program = controller.programs[index];
                  return ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(program.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        Get.dialog(
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
                        );
                      },
                    ),
                    onTap: () =>
                        Get.to(() => BuildProgramPage(program: program)),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProgramDialog(controller),
        child: const Icon(Icons.add),
      ),
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
              nameController.dispose();
              Get.back();
            },
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final newProgram = await controller.addProgram(
                  nameController.text.trim(),
                );
                nameController.dispose();
                Get.back();
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
