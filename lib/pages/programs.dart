import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/programs_controller.dart'; // Import your controller

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
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
            // Obx listens for changes in controller.programs
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
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addProgram,
        child: const Icon(Icons.add),
      ),
    );
  }
}