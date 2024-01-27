import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/profile.dart';
import 'package:reptrack/pages/schedules.dart';
import 'package:reptrack/pages/track.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(ChangeNotifierProvider(
  create: (context) => AppState(),
  child: const ReptrackApp()
));

class ReptrackApp extends StatelessWidget {
  const ReptrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
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
              child: Icon(Icons.person),
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        SchedulesPage(),
        SchedulesPage(),
        TrackPage(),
        ProfilePage(),
      ][currentPageIndex],
    );
  }
}
