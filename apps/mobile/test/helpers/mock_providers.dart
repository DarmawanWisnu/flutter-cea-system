import 'package:mockito/mockito.dart';
import 'package:fountaine/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockApiService extends Mock implements ApiService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}
