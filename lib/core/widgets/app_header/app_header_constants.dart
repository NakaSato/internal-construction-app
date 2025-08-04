import '../../theme/app_theme.dart';

/// Constants and configuration for the app header
class AppHeaderConstants {
  // Size constants
  static const double toolbarHeightOffset = SolarSpacing.sm;
  static const double avatarRadius = 22.0;
  static const double iconSize = 22.0;
  static const double iconPadding = SolarSpacing.md;
  static const double iconBorderRadius = SolarBorderRadius.md;
  static const double verifiedIconSize = 16.0;
  static const double onlineIndicatorSize = 6.0;

  // Animation constants
  static const Duration animationDuration = Duration(milliseconds: 800);
  static const Duration badgeAnimationDuration = Duration(milliseconds: 600);
  static const Duration scaleAnimationDuration = Duration(milliseconds: 400);
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration pulseAnimationDuration = Duration(milliseconds: 1500);
  static const Duration notificationIconAnimationDuration = Duration(milliseconds: 300);

  // Spacing constants
  static const double searchIconRightSpacing = SolarSpacing.sm;
  static const double notificationIconRightSpacing = SolarSpacing.md;
  static const double customActionLeftSpacing = SolarSpacing.sm;
  static const double customActionRightSpacing = SolarSpacing.xs;
  static const double userInfoSpacing = SolarSpacing.md;
  static const double verifiedIconSpacing = SolarSpacing.xs;
  static const double onlineIndicatorSpacing = SolarSpacing.xs;

  // Numeric constants
  static const int maxNotificationCount = 99;
  static const double scaleAnimationStart = 0.8;
  static const double scaleAnimationRange = 0.2;

  // Private constructor to prevent instantiation
  const AppHeaderConstants._();
}
