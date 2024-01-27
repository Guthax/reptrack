import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/workout.dart';
import '../mocks/app_state_mock.dart';

void main() {
  // Mock your dependencies
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();
  });

  testWidgets('test date widget', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: WorkoutPage(),
        ),
      ),
    );

    DateTime now = DateTime.now();
    String dateString = "Todays date: ${now.day}-${now.month}-${now.year}";
    expect(find.text(dateString), findsOneWidget);
  });

  testWidgets('test start button widget', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: WorkoutPage(),
        ),
      ),
    );
    expect(find.text("START"), findsOneWidget);
  });

  testWidgets('test workout list widget', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: WorkoutPage(),
        ),
      ),
    );

    expect(find.text(mockAppState.schedules[0].name), findsOneWidget);
  });

  testWidgets('test workout list widget', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: WorkoutPage(),
        ),
      ),
    );

    expect(find.text("Day: ${mockAppState.schedules[0].workouts[0].day.toString()}", findRichText: true), findsOneWidget);
  });

}