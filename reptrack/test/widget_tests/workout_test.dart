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

  testWidgets('test workout scroll widget', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: WorkoutPage(),
        ),
      ),
    );

    final listFinder = find.byType(Scrollable).first;
    final itemFinder = find.textContaining(mockAppState.schedules[0].workouts[1].exercises[0]!.exercise!.name!, findRichText: true);

    // Scroll until the item to be found appears.
    await tester.scrollUntilVisible(
      itemFinder,
      500.0,
      scrollable: listFinder,
    );

    expect(itemFinder, findsOneWidget);
  });

}