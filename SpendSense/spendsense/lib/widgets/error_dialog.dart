import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.error_outline,
        size: 48,
        color: theme.colorScheme.error,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
      content: Text(message),
      actions: [
        if (secondaryButtonText != null)
          TextButton(
            onPressed: onSecondaryButtonPressed ?? () => Navigator.of(context).pop(),
            child: Text(secondaryButtonText!),
          ),
        if (primaryButtonText != null)
          FilledButton(
            onPressed: onPrimaryButtonPressed ?? () => Navigator.of(context).pop(),
            child: Text(primaryButtonText!),
          ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryButtonPressed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        onPrimaryButtonPressed: onPrimaryButtonPressed,
        secondaryButtonText: secondaryButtonText,
        onSecondaryButtonPressed: onSecondaryButtonPressed,
      ),
    );
  }
} 