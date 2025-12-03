import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth;
  AuthService(this._auth);
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  /// Throws [FirebaseAuthException] with user-friendly error codes.
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Sign in error: ${e.code} - ${e.message}');
      }
      rethrow; // Let the UI layer handle with FirebaseErrorHandler
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected sign in error: $e');
      }
      rethrow;
    }
  }

  /// Register a new user with email and password.
  /// Throws [FirebaseAuthException] with user-friendly error codes.
  Future<UserCredential> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Registration error: ${e.code} - ${e.message}');
      }
      rethrow; // Let the UI layer handle with FirebaseErrorHandler
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected registration error: $e');
      }
      rethrow;
    }
  }

  /// Logout user aktif.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      rethrow;
    }
  }

  /// Kirim email reset password.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Password reset error: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected password reset error: $e');
      }
      rethrow;
    }
  }

  /// Kirim email verifikasi ke user aktif.
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Email verification error: $e');
      }
      rethrow;
    }
  }

  /// Reload data user dari server
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Reload user error: $e');
      }
      rethrow;
    }
  }
}
