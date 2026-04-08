import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/pages/onboarding.dart';
import 'package:reptrack/pages/programs.dart';
import 'package:reptrack/pages/tracking.dart';
import 'package:reptrack/pages/workout.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/seed_data.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/error_handler.dart';
import 'controllers/navigation_controller.dart';

/// Controller for the post-workout confetti celebration overlay.
///
/// Registered as a permanent GetX singleton in [main] so it survives
/// navigation resets. Call [celebrate] after finishing a workout.
class CelebrationController extends GetxController {
  /// The confetti animation controller; disposed in [onClose].
  final confetti = ConfettiController(duration: const Duration(seconds: 3));

  /// Starts the confetti burst animation.
  void celebrate() => confetti.play();

  @override
  void onClose() {
    confetti.dispose();
    super.onClose();
  }
}

/// Application entry point.
///
/// Registers permanent singletons ([AppDatabase], [CelebrationController]),
/// seeds the database with initial data, then runs [MainApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  Get.put(db, permanent: true);
  Get.put(CelebrationController(), permanent: true);
  final settings = Get.put(SettingsController(), permanent: true);
  await settings.load();
  Object? seedError;
  StackTrace? seedSt;
  try {
    await seedDatabase(db);
  } catch (e, st) {
    seedError = e;
    seedSt = st;
  }
  runApp(const MainApp());
  if (seedError != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppErrorHandler.showSystemError(seedError!, seedSt);
    });
  }
}

/// Root widget; configures [GetMaterialApp] with the app theme.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: settings.isFirstLaunch.value
          ? const OnboardingPage()
          : const HomePage(),
    );
  }
}

/// Shell page that hosts the bottom navigation bar and the three main tabs.
///
/// Uses [NavigationController] to drive the visible tab reactively.
/// The confetti overlay is rendered on top of all tabs via a [Stack].
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
