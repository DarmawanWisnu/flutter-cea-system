# Testing

This directory contains all tests for the Flutter CEA System mobile application.

## Test Structure

```
test/
├── helpers/              # Test utilities and mocks
│   ├── test_helpers.dart    # Common test utilities
│   └── mock_providers.dart  # Mock providers for testing
├── widgets/              # Widget tests (component-level)
│   ├── login_widget_test.dart
│   └── monitor_widget_test.dart
└── widget_test.dart      # Legacy test file

integration_test/         # Integration tests (end-to-end)
├── app_test.dart
├── auth_flow_test.dart
└── monitor_flow_test.dart
```

## Quick Start

### Run Widget Tests
```bash
flutter test
```

### Run Integration Tests
```bash
# Start an emulator or connect a device first
flutter test integration_test
```

### Run Specific Test
```bash
flutter test test/widgets/login_widget_test.dart
flutter test integration_test/auth_flow_test.dart
```

### Generate Coverage Report
```bash
flutter test --coverage
```

## Test Types

### Widget Tests
- Fast execution
- Test individual components
- No device/emulator required
- Located in `test/widgets/`

### Integration Tests
- Test complete user flows
- Require device/emulator
- Simulate real user interactions
- Located in `integration_test/`

## Documentation

For detailed testing documentation, see:
- [Testing Guide](../../docs/testing_guide.md) - Comprehensive testing documentation

## Black Box Testing

All tests in this directory follow **black box testing** principles:
- Tests are written from the user's perspective
- No knowledge of internal implementation required
- Focus on inputs, outputs, and user interactions
- Verify expected behaviors and workflows

## Adding New Tests

1. **Widget Test:** Create file in `test/widgets/`
2. **Integration Test:** Create file in `integration_test/`
3. Use helpers from `test/helpers/` for common operations
4. Follow the Arrange-Act-Assert pattern
5. Use descriptive test names

## Common Commands

```bash
# Run all tests
flutter test

# Run with verbose output
flutter test --verbose

# Run specific file
flutter test test/widgets/login_widget_test.dart

# Run integration tests on specific device
flutter test integration_test -d <device_id>

# List available devices
flutter devices
```

## Troubleshooting

- **Tests fail to run:** Run `flutter pub get` first
- **Device not found:** Start emulator or connect device
- **Widget not found:** Add `await tester.pumpAndSettle()` after actions

For more help, see the [Testing Guide](../../docs/testing_guide.md).
