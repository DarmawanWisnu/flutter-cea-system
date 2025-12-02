# Black Box Testing Guide for Flutter CEA System

## Overview

This document provides a comprehensive guide to the black box testing implementation for the Flutter CEA System mobile application. Black box testing focuses on testing the application's functionality from a user's perspective without requiring knowledge of internal implementation details.

## What is Black Box Testing?

**Black box testing** is a software testing method where the tester evaluates the functionality of an application without looking at its internal code structure. The tester only interacts with the application's user interface and verifies that it behaves as expected based on given inputs and expected outputs.

### Key Characteristics:
- Tests are based on requirements and specifications
- No knowledge of internal code structure required
- Focuses on user interactions and expected behaviors
- Tests inputs and outputs
- Validates user workflows and scenarios

## Test Structure

Our black box testing implementation consists of three main types of tests:

### 1. Widget Tests (`test/widgets/`)

Widget tests verify individual UI components in isolation. These tests ensure that:
- UI elements are displayed correctly
- Form validation works as expected
- User interactions trigger appropriate responses
- Component state changes correctly

**Location:** `apps/mobile/test/widgets/`

**Files:**
- `login_widget_test.dart` - Tests for login screen components
- `monitor_widget_test.dart` - Tests for monitor screen components

### 2. Integration Tests (`integration_test/`)

Integration tests verify complete user flows across multiple screens. These tests simulate real user journeys and ensure that:
- Navigation between screens works correctly
- Complete workflows function end-to-end
- Multiple components work together properly
- User scenarios execute successfully

**Location:** `apps/mobile/integration_test/`

**Files:**
- `app_test.dart` - Basic app initialization tests
- `auth_flow_test.dart` - Complete authentication flow tests
- `monitor_flow_test.dart` - Complete monitor screen flow tests

### 3. Test Helpers (`test/helpers/`)

Helper utilities that support testing by providing:
- Mock data generators
- Test widget wrappers
- Common test actions
- Mock providers for dependencies

**Location:** `apps/mobile/test/helpers/`

**Files:**
- `test_helpers.dart` - Common test utilities and mock data
- `mock_providers.dart` - Mock implementations of providers

## Running Tests

### Prerequisites

1. Ensure you have Flutter installed and configured
2. Navigate to the mobile app directory:
   ```bash
   cd apps/mobile
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running Widget Tests

Widget tests run quickly and don't require a device or emulator.

**Run all widget tests:**
```bash
flutter test
```

**Run specific widget test file:**
```bash
flutter test test/widgets/login_widget_test.dart
flutter test test/widgets/monitor_widget_test.dart
```

**Run tests with coverage:**
```bash
flutter test --coverage
```

This generates a coverage report in `coverage/lcov.info`.

### Running Integration Tests

Integration tests require a device or emulator to be running.

**Start an emulator or connect a device first**, then run:

**Run all integration tests:**
```bash
flutter test integration_test
```

**Run specific integration test:**
```bash
flutter test integration_test/auth_flow_test.dart
flutter test integration_test/monitor_flow_test.dart
```

**Run on specific device:**
```bash
flutter test integration_test/auth_flow_test.dart -d <device_id>
```

## Test Coverage

### Authentication Flow Tests

**File:** `integration_test/auth_flow_test.dart`

Tests covered:
- ✅ Display of all login screen elements
- ✅ Email field validation (required, format)
- ✅ Password field validation (required)
- ✅ Password visibility toggle
- ✅ Navigation to registration screen
- ✅ Navigation to forgot password screen
- ✅ Valid credential input acceptance
- ✅ Loading indicator display during sign-in

### Monitor Screen Flow Tests

**File:** `integration_test/monitor_flow_test.dart`

Tests covered:
- ✅ Display of all sensor gauges (pH, PPM, Humidity, Temperature)
- ✅ Sensor values with correct units
- ✅ Kit selector dropdown
- ✅ Mode & Control section display
- ✅ Switching from Auto to Manual mode
- ✅ Switching from Manual to Auto mode
- ✅ Manual control buttons functionality
- ✅ Kit status indicator
- ✅ Last update timestamp
- ✅ Complete user flow simulation

### Login Widget Tests

**File:** `test/widgets/login_widget_test.dart`

Tests covered:
- ✅ Display of all UI elements
- ✅ Empty email validation
- ✅ Invalid email format validation
- ✅ Empty password validation
- ✅ Password visibility toggle
- ✅ Navigation to register screen
- ✅ Navigation to forgot password screen
- ✅ Valid input acceptance

### Monitor Widget Tests

**File:** `test/widgets/monitor_widget_test.dart`

Tests covered:
- ✅ Monitor screen title display
- ✅ All sensor gauges display
- ✅ Your Kit section display
- ✅ Mode & Control section display
- ✅ Manual control buttons visibility in manual mode
- ✅ Manual control buttons hidden in auto mode
- ✅ Mode toggling functionality
- ✅ Kit dropdown display

## Adding New Tests

### Adding a Widget Test

1. Create a new test file in `test/widgets/`:
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import '../helpers/test_helpers.dart';
   
   void main() {
     group('Your Component Tests', () {
       testWidgets('should do something', (WidgetTester tester) async {
         // Arrange
         await TestHelpers.pumpAndSettleWidget(
           tester,
           TestHelpers.wrapWithProviders(YourWidget()),
         );
         
         // Act
         // Perform actions
         
         // Assert
         expect(find.text('Expected Text'), findsOneWidget);
       });
     });
   }
   ```

### Adding an Integration Test

1. Create a new test file in `integration_test/`:
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:integration_test/integration_test.dart';
   
   void main() {
     IntegrationTestWidgetsFlutterBinding.ensureInitialized();
     
     group('Your Flow Tests', () {
       testWidgets('should complete user flow', (WidgetTester tester) async {
         // Arrange
         // Set up your test
         
         // Act
         // Simulate user actions
         
         // Assert
         // Verify expected outcomes
       });
     });
   }
   ```

## Best Practices for Black Box Testing

### 1. Test from User Perspective
- Focus on what the user sees and does
- Don't test internal implementation details
- Verify visible UI elements and user interactions

### 2. Use Descriptive Test Names
```dart
// Good
testWidgets('should display error when email is empty', ...)

// Bad
testWidgets('test1', ...)
```

### 3. Follow Arrange-Act-Assert Pattern
```dart
testWidgets('should toggle password visibility', (tester) async {
  // Arrange - Set up the test
  await tester.pumpWidget(LoginScreen());
  
  // Act - Perform the action
  await tester.tap(find.byIcon(Icons.visibility_off));
  await tester.pump();
  
  // Assert - Verify the result
  expect(find.byIcon(Icons.visibility), findsOneWidget);
});
```

### 4. Test Both Happy and Unhappy Paths
- Test successful scenarios (valid inputs)
- Test error scenarios (invalid inputs, edge cases)
- Test boundary conditions

### 5. Keep Tests Independent
- Each test should be able to run independently
- Don't rely on the state from previous tests
- Clean up after each test if necessary

## Troubleshooting

### Tests Fail to Run

**Problem:** `flutter test` command fails

**Solution:**
1. Run `flutter pub get` to ensure dependencies are installed
2. Check that you're in the correct directory (`apps/mobile`)
3. Verify Flutter is properly installed: `flutter doctor`

### Integration Tests Can't Find Device

**Problem:** Integration tests fail with "No devices found"

**Solution:**
1. Start an emulator or connect a physical device
2. Verify device is connected: `flutter devices`
3. Specify device explicitly: `flutter test integration_test -d <device_id>`

### Widget Not Found in Tests

**Problem:** `expect(find.text('...'), findsOneWidget)` fails

**Solution:**
1. Add `await tester.pumpAndSettle()` after actions
2. Check for typos in the text you're searching for
3. Use `await tester.pump()` multiple times if animations are involved
4. Print widget tree for debugging: `debugDumpApp()`

## For Your Thesis

### Documenting Black Box Testing

When documenting this testing approach in your thesis, include:

1. **Definition and Purpose**
   - Explain what black box testing is
   - Why it's appropriate for your application
   - How it differs from white box testing

2. **Test Coverage**
   - List all test scenarios covered
   - Explain the rationale for chosen test cases
   - Show test coverage statistics

3. **Test Results**
   - Include screenshots of successful test runs
   - Document any bugs found during testing
   - Show before/after fixes

4. **Testing Methodology**
   - Explain your test structure (widget + integration)
   - Describe the testing workflow
   - Document how tests are organized

### Generating Test Reports

**Generate coverage report:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Then open `coverage/html/index.html` in a browser to see detailed coverage.

**Capture test output:**
```bash
flutter test > test_results.txt 2>&1
```

## References

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Integration Testing in Flutter](https://docs.flutter.dev/testing/integration-tests)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Black Box Testing Principles](https://en.wikipedia.org/wiki/Black-box_testing)

## Summary

This black box testing implementation provides comprehensive coverage of the Flutter CEA System's core functionality. The tests verify user interactions, form validation, navigation, and complete user workflows without requiring knowledge of internal code structure. This approach ensures the application works correctly from an end-user perspective, which is essential for validating the system's usability and reliability.
