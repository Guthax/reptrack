import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reptrack/global_states.dart'; // Import your real app state class
import 'package:reptrack/pages/add_schedule.dart';
import 'package:reptrack/pages/add_workout.dart';
import 'package:reptrack/schemas/schemas.dart';
import '../mocks/app_state_mock.dart';

void main() {
  // Mock your dependencies
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();
  });

  testWidgets('test fields', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: AddSchedulePage(),
        ),
      ),
    );

    expect(find.text('Enter a name for the training schedule'), findsOneWidget);
    expect(find.text('Enter a number of weeks for this schedule to last'), findsOneWidget);
  });

  testWidgets('test buttons', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: AddSchedulePage(),
        ),
      ),
    );

    expect(find.text('Add workout day'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

}