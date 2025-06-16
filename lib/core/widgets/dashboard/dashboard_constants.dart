/// Dashboard-related constants
class DashboardConstants {
  /// Default padding used throughout the dashboard
  static const double defaultPadding = 16.0;

  /// Small spacing between elements
  static const double smallSpacing = 8.0;

  /// Medium spacing between sections
  static const double mediumSpacing = 16.0;

  /// Large spacing between major sections
  static const double largeSpacing = 20.0;

  /// Border radius for cards and containers
  static const double borderRadius = 12.0;

  /// Border radius for smaller elements
  static const double smallBorderRadius = 8.0;

  /// Refresh delay for loading indicators
  static const Duration refreshDelay = Duration(milliseconds: 800);

  /// Snackbar display duration
  static const Duration snackbarDuration = Duration(seconds: 2);

  /// Search hint text
  static const String searchHintText = 'Enter a project name';

  /// Filter coming soon message
  static const String filterComingSoonMessage = 'Filter options coming soon!';

  /// Refresh error message prefix
  static const String refreshErrorPrefix = 'Error refreshing dashboard: ';
}
