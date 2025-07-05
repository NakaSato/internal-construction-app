/// Application-wide constants and configuration values
///
/// This file contains constants that are used across multiple features
/// and should remain stable across the application lifecycle.
class AppConstants {
  // App Information
  static const String appName = 'INVERTAL SOLAR';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String refreshTokenKey = 'refresh_token';

  // Image Configuration
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 80;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];

  // Location Configuration
  static const double locationAccuracy = 100.0; // meters
  static const Duration locationUpdateInterval = Duration(seconds: 5);

  // Calendar Configuration
  static const int calendarViewDays = 7;
  static const Duration appointmentDefaultDuration = Duration(hours: 1);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Private constructor to prevent instantiation
  AppConstants._();
}

/// App-wide string constants
class AppStrings {
  // Navigation
  static const String home = 'Home';
  static const String projects = 'Projects';
  static const String calendar = 'Calendar';
  static const String reports = 'Reports';
  static const String profile = 'Profile';

  // Common Actions
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String create = 'Create';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String confirm = 'Confirm';

  // Validation Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
}

/// Numeric constants used throughout the app
class AppNumbers {
  static const int maxRetryAttempts = 3;
  static const int itemsPerPage = 20;
  static const double maxImageSize = 5.0; // MB
  static const int maxFileNameLength = 100;
}
