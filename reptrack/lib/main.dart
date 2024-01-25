import 'package:flutter/material.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/profile.dart';
import 'package:reptrack/pages/schedules.dart';
import 'package:reptrack/pages/track.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(const NavigationBarApp());

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  AppState globalState = AppState();

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
              child: Icon(Icons.person_off_outlined),
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        SchedulesPage(globalState),
        SchedulesPage(globalState),
        TrackPage(),
        ProfilePage(),
      ][currentPageIndex],
    );
  }
}
