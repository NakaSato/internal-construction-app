/// Application-wide constants and configuration values
class AppConstants {
  // App Information
  static const String appName = 'Flutter Architecture App';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
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
