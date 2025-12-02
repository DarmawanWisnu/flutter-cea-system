# Testing Guide

This project uses **Black Box Testing** to verify functionality from a user's perspective.

## Quick Start

### 1. Run Widget Tests (Fast, No Device)
Tests individual UI components like screens and widgets.
```bash
cd apps/mobile
flutter test
```

### 2. Run Integration Tests (End-to-End)
Tests complete user flows on a real device or emulator.
**Note:** You must have an emulator running or device connected.
```bash
cd apps/mobile
flutter test integration_test
```

## Documentation

- **[Detailed Testing Guide](docs/testing_guide.md)** - Complete guide on how to write and run tests
- **[Test Directory README](apps/mobile/test/README.md)** - Technical details about test structure

## Test Coverage

We have implemented:
- **Authentication Tests**: Login, Register, Forgot Password flows
- **Monitor Tests**: Sensor display, Mode switching, Manual controls
- **Widget Tests**: UI validation and interaction

For more details, please read the [Detailed Testing Guide](docs/testing_guide.md).
