import 'package:flutter/foundation.dart';

/// Utility class for common helper functions
class AppUtils {
  /// Check if the app is running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Check if the app is running in release mode
  static bool get isReleaseMode => kReleaseMode;

  /// Check if the app is running in profile mode
  static bool get isProfileMode => kProfileMode;

  /// Validate email address format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 8 characters, one uppercase, one lowercase, one number
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  /// Format file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Check if a file extension is supported for images
  static bool isSupportedImageFormat(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Capitalize first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Convert snake_case to Title Case
  static String snakeToTitleCase(String text) {
    return text.split('_').map((word) => capitalize(word)).join(' ');
  }

  /// Debounce function calls
  static void debounce(String key, Duration duration, VoidCallback callback) {
    _DebounceManager.debounce(key, duration, callback);
  }

  /// Private constructor to prevent instantiation
  AppUtils._();
}

/// Internal class for managing debounced function calls
class _DebounceManager {
  static final Map<String, Timer?> _timers = {};

  static void debounce(String key, Duration duration, VoidCallback callback) {
    _timers[key]?.cancel();
    _timers[key] = Timer(duration, callback);
  }
}

/// Timer class for debouncing (simplified implementation)
class Timer {
  final Duration duration;
  final VoidCallback callback;
  bool _isActive = true;

  Timer(this.duration, this.callback) {
    Future.delayed(duration, () {
      if (_isActive) {
        callback();
      }
    });
  }

  void cancel() {
    _isActive = false;
  }
}
