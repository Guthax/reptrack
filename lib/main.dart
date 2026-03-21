import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/pages/programs.dart';
import 'package:reptrack/pages/tracking.dart';
import 'package:reptrack/pages/workout.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/seed_data.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'controllers/navigation_controller.dart';

class CelebrationController extends GetxController {
  final confetti = ConfettiController(duration: const Duration(seconds: 3));

  void celebrate() => confetti.play();

  @override
  void onClose() {
    confetti.dispose();
    super.onClose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  Get.put(db, permanent: true);
  Get.put(CelebrationController(), permanent: true);
  await seedDatabase(db);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navRepo = Get.put(NavigationController());

    final List<Widget> pages = const [
      ProgramsPage(),
      WorkoutPage(),
      TrackingPage(),
    ];

    final celebration = Get.find<CelebrationController>();

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => pages[navRepo.selectedIndex.value]),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: celebration.confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              gravity: 0.3,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.success,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: navRepo.selectedIndex.value,
          onTap: navRepo.changeIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Programs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Workout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes),
              label: 'Track',
            ),
          ],
        ),
      ),
    );
  }
}
