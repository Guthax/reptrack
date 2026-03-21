import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/pages/build_program.dart';
import '../controllers/programs_controller.dart';

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
            child: Text(
              'Workouts',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.programs.isEmpty) {
                return const Center(child: Text("No programs yet. Tap + to add one!"));
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
                      icon: const Icon(Icons.delete, color: Colors.blueGrey),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Are you sure you want to delete the program",
                          middleText: "",
                          onCancel: () => {},
                          onConfirm: () {
                            controller.deleteProgram(program);
                            Get.back();
                          },
                        );
                      },
                    ),
                    onTap: () => Get.to(() => BuildProgramPage(program: program)),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final TextEditingController nameController = TextEditingController();

          Get.defaultDialog(
            title: "New Program",
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Enter program name (e.g. Push Pull Legs)",
                ),
                autofocus: true,
              ),
            ),
            textConfirm: "Add",
            textCancel: "Cancel",
            confirmTextColor: Colors.white,
            onConfirm: () async {
              if (nameController.text.trim().isNotEmpty) {
                final newProgram = await controller.addProgram(nameController.text.trim());
                Get.back();
                if (newProgram != null) {
                  Get.to(() => BuildProgramPage(program: newProgram));
                }
              }
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
