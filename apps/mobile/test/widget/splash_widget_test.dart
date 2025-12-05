import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fountaine/features/splash/splash_screen.dart';

void main() {
  group('Splash Screen Widget Tests', () {
    testWidgets('should display Fountaine branding text', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      // Use pump instead of pumpAndSettle because of animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Fountaine'), findsOneWidget);
    });

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

      // Find Scaffold and verify background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF00E676));
    });

    testWidgets('should display logo image', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should have Image widgets
      expect(find.byType(Image), findsWidgets);
    });

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

      // Should have FadeTransition widgets for animation
      expect(find.byType(FadeTransition), findsWidgets);
    });

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

    testWidgets('should have Stack layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      await tester.pump();

      expect(find.byType(Stack), findsOneWidget);
    });
  });
}
