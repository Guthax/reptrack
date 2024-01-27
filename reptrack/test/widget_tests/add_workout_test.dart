import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reptrack/global_states.dart'; // Import your real app state class
import 'package:reptrack/main.dart'; // Import your main app file or the file where AddExercisePage is defined
import 'package:reptrack/pages/add_exercise.dart';
import 'package:reptrack/pages/add_workout.dart';
import 'package:reptrack/schemas/schemas.dart';
import 'package:search_page/search_page.dart';
// Create a mock for the app state
class MockAppState extends Mock implements AppState {
  @override
  List<Exercise> get exercises =>  <Exercise>[Exercise("Push ups"), Exercise("Sit ups"), Exercise("Pull ups")];
}

void main() {
  // Mock your dependencies
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();
  });

  testWidgets('test buttons', (WidgetTester tester) async {
    // Provide the mock app state to the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: AddWorkoutPage(),
        ),
      ),
    );

    expect(find.text('Add exercise'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

}