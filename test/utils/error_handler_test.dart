import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/controllers/programs_controller.dart';
import 'package:reptrack/controllers/tracking_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/error_handler.dart';
import '../test_helpers.dart';

/// Creates an in-memory DB with the schema fully initialised, then drops
/// [table] so every subsequent operation on it throws "no such table".
Future<AppDatabase> _dbWithDroppedTable(String table) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.customStatement('SELECT 1'); // triggers schema creation
  await db.customStatement('DROP TABLE IF EXISTS "$table"');
  return db;
}

void main() {
  setUpAll(setupTestSqlite);

  tearDown(() {
    AppErrorHandler.resetForTest();
    Get.reset();
  });

  // ── formatErrorDetails ────────────────────────────────────────────────────

  group('formatErrorDetails', () {
    test('includes error message', () {
      final result = AppErrorHandler.formatErrorDetails(Exception('boom'));
      expect(result, contains('boom'));
    });

    test('starts with "Error:" prefix', () {
      final result = AppErrorHandler.formatErrorDetails('oops');
      expect(result, startsWith('Error:'));
    });

    test('omits stack trace section when null', () {
      final result = AppErrorHandler.formatErrorDetails('oops');
      expect(result, isNot(contains('Stack trace:')));
    });

    test('includes stack trace section when provided', () {
      StackTrace? captured;
      try {
        throw Exception('test');
      } catch (_, st) {
        captured = st;
      }
      final result = AppErrorHandler.formatErrorDetails('oops', captured);
      expect(result, contains('Stack trace:'));
    });

    test('limits stack trace to at most 10 lines', () {
      StackTrace? captured;
      try {
        throw Exception('test');
      } catch (_, st) {
        captured = st;
      }
      final result = AppErrorHandler.formatErrorDetails('oops', captured);
      // "Error:" line + "Stack trace:" line + up to 10 trace lines = at most 12
      final lines = result.split('\n').where((l) => l.trim().isNotEmpty);
      expect(lines.length, lessThanOrEqualTo(12));
    });

    test('trims trailing whitespace', () {
      final result = AppErrorHandler.formatErrorDetails('oops');
      expect(result, equals(result.trimRight()));
    });
  });

  // ── overrideForTest / resetForTest ────────────────────────────────────────

  group('test override', () {
    test('overrideForTest routes errors to the provided handler', () {
      Object? caught;
      AppErrorHandler.overrideForTest((e, _) => caught = e);
      AppErrorHandler.showSystemError(Exception('injected'));
      expect(caught, isA<Exception>());
    });

    test('overrideForTest passes the stack trace to the handler', () {
      StackTrace? capturedSt;
      AppErrorHandler.overrideForTest((_, st) => capturedSt = st);
      final trace = StackTrace.current;
      AppErrorHandler.showSystemError(Exception('x'), trace);
      expect(capturedSt, same(trace));
    });

    test('resetForTest means the old handler is no longer called', () {
      int callCount = 0;
      AppErrorHandler.overrideForTest((_, _) => callCount++);
      AppErrorHandler.showSystemError(Exception('before'));
      expect(callCount, 1);

      AppErrorHandler.resetForTest();

      // After reset a new override should work cleanly
      bool newCalled = false;
      AppErrorHandler.overrideForTest((_, _) => newCalled = true);
      AppErrorHandler.showSystemError(Exception('after'));
      expect(newCalled, isTrue);
      // Original handler received exactly one call — it was not called again
      expect(callCount, 1);
    });
  });

  // ── ProgramsController ────────────────────────────────────────────────────

  group('ProgramsController error handling', () {
    test('addProgram reports system error on DB failure', () async {
      Get.testMode = true;
      Get.put<AppDatabase>(await _dbWithDroppedTable('programs'));

      Object? caught;
      AppErrorHandler.overrideForTest((e, _) => caught = e);

      final controller = Get.put(ProgramsController());
      await Future.delayed(Duration.zero); // let onInit settle

      final result = await controller.addProgram('Test');
      expect(result, isNull);
      expect(caught, isNotNull);
    });

    test('deleteProgram reports system error on DB failure', () async {
      Get.testMode = true;
      Get.put<AppDatabase>(await _dbWithDroppedTable('programs'));

      Object? caught;
      AppErrorHandler.overrideForTest((e, _) => caught = e);

      final controller = Get.put(ProgramsController());
      await Future.delayed(Duration.zero);

      await controller.deleteProgram(Program(id: 'x', name: 'X'));
      expect(caught, isNotNull);
    });
  });

  // ── BuildProgramController ────────────────────────────────────────────────

  group('BuildProgramController error handling', () {
    test('addDay reports system error on DB failure', () async {
      Get.testMode = true;
      Get.put<AppDatabase>(await _dbWithDroppedTable('workout_days'));

      Object? caught;
      AppErrorHandler.overrideForTest((e, _) => caught = e);

      final controller = BuildProgramController('prog-1', 'Test');
      await controller.addDay('Day 1');
      expect(caught, isNotNull);
    });

    test('deleteDay reports system error on DB failure', () async {
      Get.testMode = true;
      Get.put<AppDatabase>(await _dbWithDroppedTable('workout_days'));

      Object? caught;
      AppErrorHandler.overrideForTest((e, _) => caught = e);

      final controller = BuildProgramController('prog-1', 'Test');
      await controller.deleteDay('day-1');
      expect(caught, isNotNull);
    });

    test('getAvailableExercises returns empty list on DB failure', () async {
      Get.testMode = true;
      Get.put<AppDatabase>(await _dbWithDroppedTable('exercises'));

      AppErrorHandler.overrideForTest((_, _) {});

      final controller = BuildProgramController('prog-1', 'Test');
      final result = await controller.getAvailableExercises();
      expect(result, isEmpty);
    });
  });

  // ── TrackingController ────────────────────────────────────────────────────

  group('TrackingController error handling', () {
    test('logBodyweight reports system error on DB failure', () async {
      Get.testMode = true;
      Get.put<AppDatabase>(await _dbWithDroppedTable('bodyweight_entries'));

      Object? caught;
      AppErrorHandler.overrideForTest((e, _) => caught = e);

      final controller = TrackingController();
      await controller.logBodyweight(75.0);
      expect(caught, isNotNull);
    });

    test('deleteBodyweight reports system error on DB failure', () async {
      Get.testMode = true;
      Get.put<AppDatabase>(await _dbWithDroppedTable('bodyweight_entries'));

      Object? caught;
      AppErrorHandler.overrideForTest((e, _) => caught = e);

      final controller = TrackingController();
      await controller.deleteBodyweight('bw-1');
      expect(caught, isNotNull);
    });
  });
}
