/// Mock Providers for Testing
///
/// Provides Mockito-based mock implementations of key services.
/// Use these with Riverpod provider overrides to isolate tests from:
/// - Network calls (ApiService)
/// - Firebase authentication (FirebaseAuth, User, UserCredential)
import 'package:mockito/mockito.dart';
import 'package:fountaine/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mock implementation of ApiService for testing API calls.
class MockApiService extends Mock implements ApiService {}

/// Mock implementation of FirebaseAuth for testing authentication.
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// Mock implementation of Firebase User for testing user state.
class MockFirebaseUser extends Mock implements User {}

/// Mock implementation of UserCredential for testing auth results.
class MockUserCredential extends Mock implements UserCredential {}
