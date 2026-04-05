import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/main.dart';
import 'package:reptrack/pages/settings.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/widgets/add_workout_exercise_dialog.dart';
import 'package:reptrack/widgets/exercise_workout_card.dart';

/// Page that drives an active workout session.
///
/// Renders a horizontally swipeable [PageView] of exercise cards and a
/// progress indicator. Back-navigation is intercepted to warn the user
/// before ending the session early.
class TrackWorkoutPage extends StatelessWidget {
  /// The database ID of the workout day being performed.
  final String dayId;

  /// The display name of the workout day shown in the app bar.
  final String dayName;

  const TrackWorkoutPage({
    super.key,
    required this.dayId,
    required this.dayName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActiveWorkoutController(dayId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitWarning();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(
              "$dayName (${controller.currentPageIndex.value + 1}/${controller.exercisesWithVolume.length})",
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add exercise',
              onPressed: () => Get.dialog(const AddWorkoutExerciseDialog()),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => Get.to(() => const SettingsPage()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => _showFinishDialog(),
                child: const Text(
                  "FINISH",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.exercisesWithVolume.isEmpty) {
              return const Center(child: Text("No exercises found."));
            }

            return Column(
              children: [
                Obx(
                  () => LinearProgressIndicator(
                    value: controller.exercisesWithVolume.isEmpty
                        ? 0
                        : (controller.currentPageIndex.value + 1) /
                              controller.exercisesWithVolume.length,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: (index) =>
                        controller.currentPageIndex.value = index,
                    itemCount: controller.exercisesWithVolume.length,
                    itemBuilder: (context, index) {
                      return ExerciseSwipeCard(
                        item: controller.exercisesWithVolume[index],
                        exerciseIndex: index,
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before finishing the workout.
  ///
  /// On confirmation, navigates to [HomePage] and triggers the celebration
  /// confetti via [CelebrationController].
  void _showFinishDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Finish Workout?"),
        content: const Text(
          "All your logged sets are saved. Ready to wrap up?",
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Get.back();
              Get.offAll(() => const HomePage());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.find<CelebrationController>().celebrate();
              });
            },
            child: const Text("FINISH"),
          ),
        ],
      ),
    );
  }

  /// Shows a warning dialog when the user attempts to leave mid-workout.
  ///
  /// Choosing LEAVE navigates back to [HomePage]; STAY dismisses the dialog.
  void _showExitWarning() {
    Get.dialog(
      AlertDialog(
        title: const Text("Leave Workout?"),
        content: const Text(
          "Your progress is saved, but the session will end. Are you sure you want to go back?",
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("STAY")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.offAll(() => const HomePage()),
            child: const Text("LEAVE"),
          ),
        ],
      ),
    );
  }
}
