import 'package:flutter/material.dart';
import 'package:spendsense/widgets/error_dialog.dart';
import 'package:spendsense/widgets/error_view.dart';

class ErrorService {
  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryButtonPressed,
  }) {
    ErrorDialog.show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      onPrimaryButtonPressed: onPrimaryButtonPressed,
      secondaryButtonText: secondaryButtonText,
      onSecondaryButtonPressed: onSecondaryButtonPressed,
    );
  }

  static void showDatabaseError(BuildContext context, {VoidCallback? onRetry}) {
    showError(
      context: context,
      title: 'Database Error',
      message: 'An error occurred while accessing the database. Please try again.',
      primaryButtonText: 'Retry',
      onPrimaryButtonPressed: onRetry,
      secondaryButtonText: 'Cancel',
    );
  }

  static void showNetworkError(BuildContext context, {VoidCallback? onRetry}) {
    showError(
      context: context,
      title: 'Network Error',
      message: 'Please check your internet connection and try again.',
      primaryButtonText: 'Retry',
      onPrimaryButtonPressed: onRetry,
      secondaryButtonText: 'Cancel',
    );
  }

  static void showValidationError(BuildContext context, String message) {
    showError(
      context: context,
      title: 'Validation Error',
      message: message,
      primaryButtonText: 'OK',
    );
  }

  static void showUnexpectedError(BuildContext context, {VoidCallback? onRetry}) {
    showError(
      context: context,
      title: 'Unexpected Error',
      message: 'An unexpected error occurred. Please try again.',
      primaryButtonText: 'Retry',
      onPrimaryButtonPressed: onRetry,
      secondaryButtonText: 'Cancel',
    );
  }

  static void showOfflineError(BuildContext context) {
    showError(
      context: context,
      title: 'Offline Mode',
      message: 'You are currently offline. Some features may be limited.',
      primaryButtonText: 'OK',
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    return error.toString();
  }

  static dynamic handleError(dynamic error) {
    print('Error occurred: $error');
    return error;
  }

  static Widget buildErrorView(String message, {VoidCallback? onRetry}) {
    return ErrorView(
      message: message,
      onRetry: onRetry,
    );
  }

  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    // TODO: Implement proper error logging service
    print('Error: $message');
    print('Details: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
} 