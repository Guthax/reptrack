import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../persistance/database.dart';

class BuildProgramPage extends StatelessWidget {
  final Program program;

  const BuildProgramPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${program.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Editing Program ID: ${program.id}"),
            const SizedBox(height: 20),
            const Text("Here you can add exercises later!"),
          ],
        ),
      ),
    );
  }
}