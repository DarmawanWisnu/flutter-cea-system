/// Test Helper Utilities
///
/// Provides reusable helper functions and classes for widget and integration testing.
/// Includes:
/// - Widget wrappers for providers and MaterialApp
/// - Pump and settle helpers
/// - Finder utilities
/// - Mock data generators for telemetry, kits, and users
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class containing static utility methods for widget testing.
class TestHelpers {
  /// Wraps a widget with ProviderScope and MaterialApp for testing.
  static Widget wrapWithProviders(Widget child, {dynamic overrides}) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(home: child),
    );
  }

  /// Wraps a widget with MaterialApp and Scaffold for simple widget testing.
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// Pumps a widget and waits for all animations to complete.
  static Future<void> pumpAndSettleWidget(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  /// Finds a widget by its Key.
  static Finder findByKey(String key) {
    return find.byKey(Key(key));
  }

  /// Finds a widget by its text content.
  static Finder findByText(String text) {
    return find.text(text);
  }

  /// Finds a widget by its Type.
  static Finder findByType<T>() {
    return find.byType(T);
  }

  /// Enters text into a text field and pumps to process.
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Taps a widget and waits for all animations to complete.
  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Waits for a specific duration.
  static Future<void> wait(Duration duration) async {
    await Future.delayed(duration);
  }

  /// Verifies that exactly one widget matches the finder.
  static void expectWidgetExists(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Verifies that no widgets match the finder.
  static void expectWidgetNotExists(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Verifies that exactly [count] widgets match the finder.
  static void expectWidgetsExist(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }
}

/// Mock data generators for testing.
class MockData {
  /// Generates mock telemetry data with default or custom values.
  static Map<String, dynamic> mockTelemetry({
    double ph = 6.5,
    double ppm = 1200.0,
    double humidity = 65.0,
    double temperature = 25.0,
  }) {
    return {
      'ph': ph,
      'ppm': ppm,
      'humidity': humidity,
      'tempC': temperature,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Generates mock kit data with default or custom values.
  static Map<String, dynamic> mockKit({
    String id = 'test-kit-001',
    String name = 'Test Kit',
  }) {
    return {
      'id': id,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Generates mock user data with default or custom values.
  static Map<String, dynamic> mockUser({
    String email = 'test@example.com',
    String uid = 'test-uid-123',
    bool emailVerified = true,
  }) {
    return {'email': email, 'uid': uid, 'emailVerified': emailVerified};
  }

  /// Generates a list of mock kits with the specified count.
  static List<Map<String, dynamic>> mockKitsList({int count = 3}) {
    return List.generate(
      count,
      (index) => mockKit(
        id: 'test-kit-${index.toString().padLeft(3, '0')}',
        name: 'Test Kit $index',
      ),
    );
  }
}
