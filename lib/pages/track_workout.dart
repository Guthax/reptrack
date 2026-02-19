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

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            "$dayName (${controller.currentPageIndex.value + 1}/${controller.exercisesWithVolume.length})")),
        // --- Added Finish Button ---
        actions: [
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Use a high-contrast color like Green or Blue
        backgroundColor: Colors.green.shade600, 
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: () => _showFinishDialog(context),
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
                onPageChanged: controller.currentPageIndex,
                itemCount: controller.exercisesWithVolume.length,
                itemBuilder: (context, index) {
                  return ExerciseSwipeCard(item: controller.exercisesWithVolume[index]);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper to confirm finishing the workout
  void _showFinishDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Finish Workout?",
      middleText: "Are you sure you want to end this session?",
      textConfirm: "Finish",
      textCancel: "Keep Training",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Navigate back to the very first screen (Home)
        // If you have a named route for home, use Get.offAllNamed('/home');
        Get.offAll(() => const HomePage()); // Replace with your actual Home Widget
      },
    );
  }
}