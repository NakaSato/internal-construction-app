import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enhanced logging utility with categorized log levels and better formatting
class LogUtils {
  // Log level constants
  static const String _successPrefix = '✅';
  static const String _errorPrefix = '❌';
  static const String _warningPrefix = '⚠️';
  static const String _infoPrefix = '🔵';
  static const String _debugPrefix = '🔧';
  static const String _criticalPrefix = '🚨';

  /// Logs success messages in development mode
  static void logSuccess(String context, String message) {
    if (kDebugMode) {
      debugPrint('$_successPrefix [$context] $message');
    }
  }

  /// Logs error messages with optional stack trace
  static void logError(String context, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_errorPrefix [$context] $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
    // In production, send to crash reporting service
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// Logs warning messages
  static void logWarning(String context, String message) {
    if (kDebugMode) {
      debugPrint('$_warningPrefix [$context] $message');
    }
  }

  /// Logs informational messages
  static void logInfo(String context, String message) {
    if (kDebugMode) {
      debugPrint('$_infoPrefix [$context] $message');
    }
  }

  /// Logs debug messages (for development only)
  static void logDebug(String context, String message) {
    if (kDebugMode) {
      debugPrint('$_debugPrefix [$context] $message');
    }
  }

  /// Logs critical errors that require immediate attention
  static void logCritical(String context, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_criticalPrefix [$context] $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
    // In production, send to crash reporting with high priority
  }

  /// Logs lifecycle events for app monitoring
  static void logLifecycle(String event) {
    if (kDebugMode) {
      debugPrint('📱 [LIFECYCLE] $event');
    }
    // In production, send to analytics
  }

  /// Logs dependency injection events
  static void logDI(String message) {
    if (kDebugMode) {
      debugPrint('🔧 [DI] $message');
    }
  }

  /// Logs BLoC/state management events
  static void logBloc(String blocName, String event) {
    if (kDebugMode) {
      debugPrint('🔄 [BLOC:$blocName] $event');
    }
  }

  /// Logs API calls and responses
  static void logApi(String method, String endpoint, {int? statusCode, String? message}) {
    if (kDebugMode) {
      final status = statusCode != null ? ' [$statusCode]' : '';
      final msg = message != null ? ' - $message' : '';
      debugPrint('🌐 [API] $method $endpoint$status$msg');
    }
  }

  /// Logs cache operations
  static void logCache(String operation, String key) {
    if (kDebugMode) {
      debugPrint('💾 [CACHE] $operation: $key');
    }
  }

  /// Logs real-time events
  static void logRealtime(String event, String message) {
    if (kDebugMode) {
      debugPrint('⚡ [REALTIME:$event] $message');
    }
  }
}

/// Enhanced validation utilities with consistent error messages
class ValidationUtils {
  // Error message constants
  static const String emailRequiredError = 'Email address is required';
  static const String emailInvalidError = 'Please enter a valid email address';
  static const String passwordRequiredError = 'Password is required';
  static const String passwordTooShortError = 'Password must be at least 8 characters';
  static const String passwordWeakError = 'Password must contain uppercase, lowercase, and number';
  static const String requiredFieldError = 'This field is required';

  /// Validates email address format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return emailRequiredError;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return emailInvalidError;
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return passwordRequiredError;
    }

    if (value.length < 8) {
      return passwordTooShortError;
    }

    // Check for at least one uppercase, lowercase, and number
    final strongPasswordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!strongPasswordRegex.hasMatch(value)) {
      return passwordWeakError;
    }

    return null;
  }

  /// Validates required fields
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : requiredFieldError;
    }
    return null;
  }

  /// Validates numeric input
  static String? validateNumeric(String? value, {String? fieldName, double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return validateRequired(value, fieldName);
    }

    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return '${fieldName ?? 'Value'} must be a valid number';
    }

    if (min != null && numValue < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }

    if (max != null && numValue > max) {
      return '${fieldName ?? 'Value'} must not exceed $max';
    }

    return null;
  }

  /// Validates phone number format
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Basic phone number validation (can be enhanced for specific regions)
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}

/// Enhanced UI utilities for consistent user experience
class UIUtils {
  // Animation constants
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing constants
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // Border radius constants
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;

  /// Shows a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows a warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[const SizedBox(height: spacingMD), Text(message)],
          ],
        ),
      ),
    );
  }

  /// Dismisses any open dialogs
  static void dismissDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Shows a confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelText)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(confirmText)),
        ],
      ),
    );
    return result ?? false;
  }

  /// Dismisses the keyboard
  static void dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
