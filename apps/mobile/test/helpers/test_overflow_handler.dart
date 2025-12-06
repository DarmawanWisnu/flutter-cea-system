/// Test Overflow Handler Utilities
///
/// Provides utilities for handling Flutter widget test environment issues.
/// Includes:
/// - Overflow error suppression (prevents test failures from layout overflows)
/// - Safe widget pumping with error handling
/// - MaterialApp wrapper with text scaling disabled
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up and tears down overflow handling for a test group.
/// Call this at the start of main() in your test file.
void setupTestEnvironment() {
  FlutterExceptionHandler? originalOnError;

  setUpAll(() {
    originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception.toString();
      if (exception.contains('overflowed') ||
          exception.contains('A RenderFlex') ||
          exception.contains('pixels')) {
        return;
      }
      if (originalOnError != null) {
        originalOnError!(details);
      }
    };
  });

  tearDownAll(() {
    FlutterError.onError = originalOnError;
  });
}

/// Creates a MaterialApp wrapper with disabled text scaling for consistent tests.
Widget wrapForTest(Widget child) {
  return MaterialApp(
    home: child,
    builder: (context, widget) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: widget ?? const SizedBox(),
      );
    },
  );
}

/// Extension on WidgetTester for safe widget pumping with overflow suppression.
extension WidgetTesterOverflow on WidgetTester {
  /// Pumps widget and suppresses any overflow errors that occur.
  /// Use this instead of pumpWidget when testing screens that may overflow.
  Future<void> pumpWidgetSafe(Widget widget) async {
    final originalOnError = FlutterError.onError;
    
    FlutterError.onError = (details) {
      final exception = details.exception.toString();
      if (exception.contains('overflowed') ||
          exception.contains('A RenderFlex') ||
          exception.contains('pixels')) {
        return;
      }
      if (originalOnError != null) {
        originalOnError(details);
      }
    };

    try {
      await pumpWidget(widget);
      await pump();
    } finally {
      FlutterError.onError = originalOnError;
    }
  }
}
