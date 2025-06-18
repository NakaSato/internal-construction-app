/// Constants used across project detail screens and widgets
class ProjectDetailConstants {
  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 600);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 800);
  
  // UI dimensions
  static const double loadingIndicatorSize = 80.0;
  static const double borderRadius = 16.0;
  static const double cardPadding = 20.0;
  
  // Data pagination
  static const int projectReportsPageSize = 10;
  
  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve slideInCurve = Curves.easeOutCubic;
  
  // Spacing constants
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double smallSpacing = 8.0;
}

/// User role enum with enhanced functionality
enum UserRole {
  admin('ADMIN'),
  manager('MANAGER'),
  user('USER');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.value == role.toUpperCase(),
      orElse: () => UserRole.user,
    );
  }

  bool get hasFullAccess => this == UserRole.admin || this == UserRole.manager;
  bool get isFieldUser => this == UserRole.user;
  
  int get tabCount => hasFullAccess ? 7 : 4;
}
