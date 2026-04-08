import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app_theme.dart';

/// The developer e-mail shown in the error report dialog.
///
/// Update this to your own address before publishing.
const _kDeveloperEmail = 'dev@reptrack.app';

/// Handles unexpected system errors (database failures, I/O errors, etc.).
///
/// Call [showSystemError] from any `catch` block that catches an error the
/// user cannot resolve themselves (e.g. a failed SQLite write). For
/// user-facing validation errors (empty name, duplicate entry) keep using
/// [AppSnackbar] instead.
///
/// The [_handler] hook is intended for tests only — override it in a
/// `setUp` block and reset it in `tearDown`.
abstract final class AppErrorHandler {
  static void Function(Object, StackTrace?)? _handler;

  /// Replaces the error display with [handler] for testing.
  ///
  /// Must be paired with [resetForTest] in `tearDown`.
  @visibleForTesting
  static void overrideForTest(void Function(Object, StackTrace?) handler) {
    _handler = handler;
  }

  /// Restores the default production behaviour after a test.
  @visibleForTesting
  static void resetForTest() {
    _handler = null;
  }

  /// Shows a dialog describing [error] and advising the user to send a report.
  ///
  /// Pass [stackTrace] when available so the developer can identify the source.
  static void showSystemError(Object error, [StackTrace? stackTrace]) {
    if (_handler != null) {
      _handler!(error, stackTrace);
      return;
    }
    _showDialog(error, stackTrace);
  }

  static void _showDialog(Object error, StackTrace? stackTrace) {
    final details = formatErrorDetails(error, stackTrace);

    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text('Something went wrong'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'An unexpected error occurred. Please copy the details below '
                'and send them to the developer.',
              ),
              const SizedBox(height: 4),
              const Text(
                _kDeveloperEmail,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: SelectableText(
                  details,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('CLOSE')),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: details));
              Get.back();
              AppSnackbar.success('Error details copied to clipboard');
            },
            child: const Text('COPY'),
          ),
        ],
      ),
    );
  }

  /// Formats [error] and the first 10 lines of [stackTrace] into a
  /// human-readable string suitable for clipboard or display.
  static String formatErrorDetails(Object error, [StackTrace? stackTrace]) {
    final buffer = StringBuffer()..writeln('Error: $error');
    if (stackTrace != null) {
      final lines = stackTrace
          .toString()
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .take(10);
      buffer.writeln('Stack trace:');
      for (final line in lines) {
        buffer.writeln(line);
      }
    }
    return buffer.toString().trimRight();
  }
}
