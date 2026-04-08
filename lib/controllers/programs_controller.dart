import 'package:get/get.dart';
import '../persistance/database.dart';
import '../utils/error_handler.dart';

/// Controller for the Programs screen.
///
/// Manages the full list of training programs and exposes create/delete
/// operations. State is re-fetched from [AppDatabase] after every mutation
/// rather than maintained via a stream, so [loadPrograms] is called
/// explicitly where needed.
class ProgramsController extends GetxController {
  /// Reactive list of all programs stored in the database.
  var programs = <Program>[].obs;

  /// Whether an async database operation is in progress.
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrograms();
  }

  /// Fetches all programs from the database and refreshes [programs].
  Future<void> loadPrograms() async {
    try {
      isLoading(true);
      final data = await Get.find<AppDatabase>().getAllPrograms();
      programs.assignAll(data);
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    } finally {
      isLoading(false);
    }
  }

  /// Creates a new program named [name], refreshes the list, and returns
  /// the newly created [Program].
  ///
  /// Returns `null` and shows an error snackbar if the insert fails.
  Future<Program?> addProgram(String name) async {
    try {
      final database = Get.find<AppDatabase>();
      final id = await database.addProgram(name);
      await loadPrograms();
      return programs.firstWhere((p) => p.id == id);
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
      return null;
    }
  }

  /// Deletes [program] from the database and refreshes the list.
  ///
  /// Shows an error dialog if the deletion fails.
  Future<void> deleteProgram(Program program) async {
    try {
      await Get.find<AppDatabase>().deleteProgram(program.id);
      await loadPrograms();
    } catch (e, st) {
      AppErrorHandler.showSystemError(e, st);
    }
  }
}
