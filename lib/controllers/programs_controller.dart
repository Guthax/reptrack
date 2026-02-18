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
      programs.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addProgram() async {
    await  Get.find<AppDatabase>().addProgram('New Program ${programs.length + 1}');
    await loadPrograms(); // Refresh the list
  }
}