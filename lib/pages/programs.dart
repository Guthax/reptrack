import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/pages/build_program.dart';
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
    // Added the trailing icon here
    trailing: IconButton(
      icon: const Icon(Icons.edit, color: Colors.blueGrey),
      onPressed: () {
        // Navigate to the build page for this specific program
        Get.to(() => BuildProgramPage(program: program));
      },
    ),
    // Optional: Making the whole tile clickable too
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
    // Create a local controller for the text field
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
      // Inside ProgramsPage floatingActionButton onPressed:
onConfirm: () async {
  if (nameController.text.trim().isNotEmpty) {
    // 1. Add the program and get the result
    final newProgram = await controller.addProgram(nameController.text.trim());
    
    // 2. Close the dialog
    Get.back(); 

    // 3. If successful, navigate to the edit page
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