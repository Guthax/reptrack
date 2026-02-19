import 'package:get/get.dart';
import '../persistance/database.dart';

class ProgramsController extends GetxController {
  
  // .obs makes the list observable
  var programs = <Program>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    try {
      isLoading(true);
      final data = await Get.find<AppDatabase>().getAllPrograms();

      final existingExercises = await Get.find<AppDatabase>().getAllExercises();
      if (existingExercises.isEmpty) {
        await Get.find<AppDatabase>().seedDatabase();
      }

      programs.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  // inside programs_controller.dart
  Future<Program?> addProgram(String name) async {
    try {
      final database = Get.find<AppDatabase>();
      
      // 1. Insert and get the full Program object back
      // (Assuming your database helper has a method like this, or use the return value of insert)
      final id = await database.into(database.programs).insert(
        ProgramsCompanion.insert(name: name),
      );

      await loadPrograms(); 

      // Find the newly created program in our list
      return programs.firstWhere((p) => p.id == id);
    } catch (e) {
      Get.snackbar("Error", "Could not save: $e");
      return null;
    }
  }
}