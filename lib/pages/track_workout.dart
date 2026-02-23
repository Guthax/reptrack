import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/main.dart';
import 'package:reptrack/widgets/exercise_workout_card.dart';

class TrackWorkoutPage extends StatelessWidget {
  final int dayId;
  final String dayName;

  const TrackWorkoutPage({super.key, required this.dayId, required this.dayName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActiveWorkoutController(dayId));

    // We use PopScope to intercept the back button/gesture
    return PopScope(
      canPop: false, // Prevent immediate pop
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitWarning();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(
              "$dayName (${controller.currentPageIndex.value + 1}/${controller.exercisesWithVolume.length})")),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.exercisesWithVolume.isEmpty) return const Center(child: Text("No exercises found."));

          return Column(
            children: [
              Obx(() => LinearProgressIndicator(
                    value: controller.exercisesWithVolume.isEmpty
                        ? 0
                        : (controller.currentPageIndex.value + 1) /
                            controller.exercisesWithVolume.length,
                  )),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (index) => controller.currentPageIndex.value = index,
                  itemCount: controller.exercisesWithVolume.length,
                  itemBuilder: (context, index) {
                    return ExerciseSwipeCard(item: controller.exercisesWithVolume[index]);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Dialog for the AppBar FINISH button
  void _showFinishDialog() {
    Get.defaultDialog(
      title: "Finish Workout?",
      middleText: "All your logged sets are saved. Ready to wrap up?",
      textConfirm: "Finish",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green.shade600,
      onConfirm: () {
        Get.offAll(() => const HomePage());
      },
    );
  }

  // Dialog for the BACK button/gesture
  void _showExitWarning() {
    Get.defaultDialog(
      title: "Leave Workout?",
      middleText: "Your progress is saved, but the session will end. Are you sure you want to go back?",
      textConfirm: "Leave",
      textCancel: "Stay",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade600,
      onConfirm: () {
        Get.offAll(() => const HomePage());
      },
    );
  }
}