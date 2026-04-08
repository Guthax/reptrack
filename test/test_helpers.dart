import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

/// Configures the sqlite3 dynamic library path for the current platform.
///
/// On Linux the default open attempt looks for `libsqlite3.so`, which may not
/// exist as an unversioned symlink. This helper redirects to the versioned
/// `.so.0` file that ships with most distributions.
void setupTestSqlite() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }
}
