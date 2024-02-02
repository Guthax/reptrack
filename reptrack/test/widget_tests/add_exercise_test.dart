import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reptrack/global_states.dart'; // Import your real app state class
import 'package:reptrack/main.dart'; // Import your main app file or the file where AddExercisePage is defined
import 'package:reptrack/pages/add_exercise.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:search_page/search_page.dart';

import '../mocks/app_state_mock.dart';
// Create a mock for the app state
void main() {
  // Mock your dependencies
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();
  });

  testWidgets('test search exercise', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: AddExerciseDialog(),
        ),
      ),
    );

    String searchText = "ups";
    //when(mockAppState.exercises).thenReturn(<Exercise>[Exercise("test")]);
    // Trigger a rebuild
    expect(find.text('Search for an exercise'), findsOneWidget);
    await tester.tap(find.text('Search for an exercise'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Search exercises'), findsOneWidget);
    await tester.enterText(find.byType(TextField), searchText);
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining(searchText), findsExactly(4));

  });

  testWidgets('test search and press exercise', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: AddExerciseDialog(),
        ),
      ),
    );

    String searchText = "ups";
    //when(mockAppState.exercises).thenReturn(<Exercise>[Exercise("test")]);
    // Trigger a rebuild
    expect(find.text('Search for an exercise'), findsOneWidget);
    await tester.tap(find.text('Search for an exercise'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Search exercises'), findsOneWidget);
    await tester.enterText(find.byType(TextField), searchText);
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining(searchText), findsExactly(4));
    await tester.tap(find.textContaining(searchText).at(1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Push ups'), findsOneWidget);
  });


  testWidgets('test exercise details', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: AddExerciseDialog(),
        ),
      ),
    );

    expect(find.text('Enter the amount of sets'), findsOneWidget);
    expect(find.text('Enter the amount of reps'), findsOneWidget);

  });
}
