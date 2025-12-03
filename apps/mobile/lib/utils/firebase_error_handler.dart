import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Centralized Firebase error handler that converts Firebase exceptions
/// into user-friendly error messages.
class FirebaseErrorHandler {
  /// Converts a Firebase exception into a user-friendly error message.
  /// 
  /// Returns a tuple of (title, message) for display in dialogs or snackbars.
  static (String title, String message) handleAuthException(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthException(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseException(error);
    } else {
      return ('Error', 'An unexpected error occurred: ${error.toString()}');
    }
  }

  /// Handles FirebaseAuthException specifically
  static (String title, String message) _handleFirebaseAuthException(
    FirebaseAuthException e,
  ) {
    if (kDebugMode) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
    }

    switch (e.code) {
      // Network-related errors
      case 'network-request-failed':
        return (
          'No Internet Connection',
          'Unable to connect to the server. Please check your internet connection and try again.',
        );

      // Authentication errors
      case 'user-not-found':
        return (
          'Account Not Found',
          'No account exists with this email address. Please check your email or create a new account.',
        );

      case 'wrong-password':
        return (
          'Incorrect Password',
          'The password you entered is incorrect. Please try again or reset your password.',
        );

      case 'invalid-email':
        return (
          'Invalid Email',
          'The email address is not valid. Please enter a valid email address.',
        );

      case 'user-disabled':
        return (
          'Account Disabled',
          'This account has been disabled. Please contact support for assistance.',
        );

      case 'email-already-in-use':
        return (
          'Email Already Registered',
          'An account with this email already exists. Please sign in or use a different email.',
        );

      case 'weak-password':
        return (
          'Weak Password',
          'The password is too weak. Please use a stronger password with at least 6 characters.',
        );

      case 'operation-not-allowed':
        return (
          'Operation Not Allowed',
          'This sign-in method is not enabled. Please contact support.',
        );

      case 'invalid-credential':
        return (
          'Invalid Credentials',
          'The credentials provided are invalid or have expired. Please try again.',
        );

      case 'too-many-requests':
        return (
          'Too Many Attempts',
          'Too many unsuccessful login attempts. Please try again later or reset your password.',
        );

      case 'requires-recent-login':
        return (
          'Re-authentication Required',
          'This operation requires recent authentication. Please sign in again.',
        );

      // Default case
      default:
        return (
          'Authentication Error',
          e.message ?? 'An authentication error occurred. Please try again.',
        );
    }
  }

  /// Handles general FirebaseException
  static (String title, String message) _handleFirebaseException(
    FirebaseException e,
  ) {
    if (kDebugMode) {
      print('FirebaseException: ${e.code} - ${e.message}');
    }

    switch (e.code) {
      case 'unavailable':
        return (
          'Service Unavailable',
          'The Firebase service is currently unavailable. Please try again later.',
        );

      case 'permission-denied':
        return (
          'Permission Denied',
          'You do not have permission to perform this action.',
        );

      default:
        return (
          'Firebase Error',
          e.message ?? 'A Firebase error occurred. Please try again.',
        );
    }
  }

  /// Extracts just the error message (without title) for simple displays
  static String getErrorMessage(dynamic error) {
    final (_, message) = handleAuthException(error);
    return message;
  }

  /// Checks if an error is network-related
  static bool isNetworkError(dynamic error) {
    if (error is FirebaseAuthException) {
      return error.code == 'network-request-failed';
    }
    if (error is FirebaseException) {
      return error.code == 'unavailable';
    }
    return false;
  }

  /// Provides actionable suggestions based on error type
  static String getSuggestion(dynamic error) {
    if (isNetworkError(error)) {
      return 'Try:\n'
          '• Check your WiFi or mobile data connection\n'
          '• Disable VPN if enabled\n'
          '• Try again in a few moments';
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
        case 'user-not-found':
          return 'Try:\n'
              '• Double-check your email and password\n'
              '• Use "Forgot Password" to reset your password';

        case 'too-many-requests':
          return 'Try:\n'
              '• Wait a few minutes before trying again\n'
              '• Reset your password if you\'ve forgotten it';

        default:
          return 'If the problem persists, please contact support.';
      }
    }

    return 'If the problem persists, please contact support.';
  }
}
