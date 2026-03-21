import 'package:get/get.dart';
import '../persistance/database.dart';

class ProgramsController extends GetxController {
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
      programs.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  Future<Program?> addProgram(String name) async {
    try {
      final database = Get.find<AppDatabase>();
      final id = await database.into(database.programs).insert(
        ProgramsCompanion.insert(name: name),
      );
      await loadPrograms();
      return programs.firstWhere((p) => p.id == id);
    } catch (e) {
      Get.snackbar("Error", "Could not save: $e");
      return null;
    }
  }

  Future<void> deleteProgram(Program program) async {
    try {
      await Get.find<AppDatabase>().deleteProgram(program.id);
      await loadPrograms();
    } catch (e) {
      Get.snackbar("Error", "Could not delete: $e");
    }
  }
}
