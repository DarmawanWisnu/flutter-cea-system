/// Splash Screen Widget Tests
///
/// Tests the SplashScreen widget for proper rendering of app branding.
/// Covers:
/// - Fountaine branding text
/// - Loading indicator text
/// - Background color (green theme)
/// - Logo image display
/// - Fade transition animations
/// - Layout structure (SafeArea, Stack)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fountaine/features/splash/splash_screen.dart';

void main() {
  group('Splash Screen Widget Tests', () {
    /// Verifies Fountaine branding text is displayed.
    testWidgets('should display Fountaine branding text', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Fountaine'), findsOneWidget);
    });

    /// Verifies Loading text is displayed.
    testWidgets('should display Loading text', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Loading...'), findsOneWidget);
    });

    /// Verifies green background color is applied.
    testWidgets('should have green background color', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF00E676));
    });

    /// Verifies logo images are displayed.
    testWidgets('should display logo image', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Image), findsWidgets);
    });

    /// Verifies FadeTransition animations are used.
    testWidgets('should have FadeTransition animations', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();

      expect(find.byType(FadeTransition), findsWidgets);
    });

    /// Verifies SafeArea is used for device notch handling.
    testWidgets('should use SafeArea', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    /// Verifies Stack layout is used for layered content.
    testWidgets('should have Stack layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();

      expect(find.byType(Stack), findsWidgets);
    });
  });
}
