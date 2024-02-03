import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/profile.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';
import 'package:reptrack/schedules/schedules.dart';
import 'package:reptrack/pages/track.dart';
import 'package:reptrack/pages/workout.dart';

void main() {
  Get.put(SchedulesController());
  runApp(const ReptrackApp());
}

class ReptrackApp extends StatelessWidget {
  const ReptrackApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const AppNavigator(),
    );
  }
}


class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.blue,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.white,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.date_range),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.fitness_center)),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.auto_graph),
            ),
            label: 'Track',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.person),
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        SchedulesPage(),
        WorkoutPage(),
        TrackPage(),
        ProfilePage(),
      ][currentPageIndex],
    );
  }
}