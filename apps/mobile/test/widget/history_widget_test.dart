/// History Screen Widget Tests
///
/// Tests the HistoryScreen widget for proper rendering of telemetry history.
/// Uses mock API provider to avoid external dependencies.
/// Covers:
/// - AppBar elements (back button, title)
/// - Empty state handling when no kit selected
/// - Floating action button for notifications
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/history/history_screen.dart';
import 'package:fountaine/providers/provider/api_provider.dart';

import '../helpers/test_overflow_handler.dart';

/// Creates wrapper with ProviderScope for testing HistoryScreen.
Widget wrapHistoryForTest(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  /// Creates test overrides for API provider.
  createTestOverrides() {
    return <Override>[
      apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
    ];
  }

  group('History Screen Widget Tests', () {
    /// Warmup test to initialize Flutter test environment.
    testWidgets('warmup', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(true, isTrue);
    });

    /// Verifies back button is present in AppBar.
    testWidgets('should display back button in AppBar', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapHistoryForTest(const HistoryScreen(), createTestOverrides()),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    /// Verifies History title is displayed in AppBar.
    testWidgets('should display History title in AppBar', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapHistoryForTest(const HistoryScreen(), createTestOverrides()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('History'), findsOneWidget);
    });

    /// Verifies empty state message when no kit is selected.
    testWidgets('should display No kit selected when no kit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapHistoryForTest(const HistoryScreen(), createTestOverrides()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No kit selected'), findsOneWidget);
    });

    /// Verifies FAB with notification icon is displayed.
    testWidgets('should display floating action button for notifications', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapHistoryForTest(const HistoryScreen(), createTestOverrides()),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });
}
