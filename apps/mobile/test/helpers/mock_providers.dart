import 'package:mockito/mockito.dart';
import 'package:fountaine/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This file provides simple mock classes for testing.
// For more complex mocking scenarios, use Mockito's @GenerateMocks annotation
// and run: flutter pub run build_runner build

/// Simple mock API Service for testing
/// You can use this in tests or generate a more sophisticated mock with Mockito
class MockApiService extends Mock implements ApiService {}

/// Simple mock Firebase Auth for testing
/// You can use this in tests or generate a more sophisticated mock with Mockito
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// Simple mock Firebase User for testing
/// You can use this in tests or generate a more sophisticated mock with Mockito
class MockFirebaseUser extends Mock implements User {}

/// Simple mock User Credential for testing
/// You can use this in tests or generate a more sophisticated mock with Mockito
class MockUserCredential extends Mock implements UserCredential {}

// To generate more sophisticated mocks with proper type safety, add this annotation:
// @GenerateMocks([ApiService, FirebaseAuth, User, UserCredential])
// Then run: flutter pub run build_runner build
