import 'package:flutter/material.dart';

/// A widget to display error messages with improved formatting and styling
class ErrorMessageWidget extends StatelessWidget {
  const ErrorMessageWidget({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.backgroundColor,
    this.textColor,
    this.maxLines,
  });

  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final isMultiLine = message.contains('\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: textColor ?? Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    textColor ?? Theme.of(context).colorScheme.onErrorContainer,
                height: isMultiLine ? 1.4 : null,
              ),
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// A snackbar helper for showing API errors with improved formatting
class ApiErrorSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final isMultiLine = message.contains('\n');
    final defaultDuration = isMultiLine
        ? const Duration(seconds: 8)
        : const Duration(seconds: 4);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: textColor ?? Theme.of(context).colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? Theme.of(context).colorScheme.onError,
                  height: isMultiLine ? 1.4 : null,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration ?? defaultDuration,
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}
