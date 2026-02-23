import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/pages/programs.dart';
import 'package:reptrack/pages/tracking.dart';
import 'package:reptrack/pages/workout.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/persistance/seed_data.dart';
import 'controllers/navigation_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  Get.put(db, permanent: true);
  await seedDatabase(db);
  
  runApp(const MainApp());
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace MaterialApp with GetMaterialApp
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final NavigationController navRepo = Get.put(NavigationController());

    final List<Widget> pages = const [
      ProgramsPage(),
      WorkoutPage(),
      TrackingPage(),
    ];

    return Scaffold(
      // Use Obx to listen for changes in the controller
      body: Obx(() => pages[navRepo.selectedIndex.value]),
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