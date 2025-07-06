import 'package:flutter/material.dart';

/// UI constants for the Project Management feature
/// These constants help maintain consistency across the feature and make it easier
/// to update spacing, animations, and other UI values from a single location.
class ProjectManagementUIConstants {
  // Private constructor to prevent instantiation
  ProjectManagementUIConstants._();

  // Standard spacing values (following 4dp grid system)
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingDefault = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingXLarge = 24.0;

  // Common padding values
  static const EdgeInsets paddingDefault = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(20.0);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(24.0);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(
    vertical: 12.0,
  );
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(
    vertical: 24.0,
  );

  // Bottom sheet constants
  static const double bottomSheetInitialSize = 0.6;
  static const double bottomSheetMaxSize = 0.9;
  static const double bottomSheetMinSize = 0.3;
  static const double bottomSheetDetailInitialSize = 0.7;
  static const double bottomSheetDetailMinSize = 0.5;

  // App bar constants
  static const double appBarExpandedHeight = 240.0;

  // Card and container constants
  static const double cardElevation = 3.0;
  static const double containerMinHeight = 48.0;
  static const double progressIndicatorHeight = 12.0;

  // Grid constants
  static const double gridCardAspectRatio = 0.75;
  static const double nearScrollThreshold = 0.9;

  // Animation and opacity constants
  static const double opacityDisabled = 0.5;
  static const double opacitySubtle = 0.3;
  static const double opacityLight = 0.2;
  static const double opacityBackground = 0.7;
  static const double opacityMedium = 0.8;

  // Progress and budget constants
  static const double progressDivider = 100.0;
  static const double budgetClampMax = 1.5;
  static const double budgetClampMin = 0.0;
  static const double budgetZero = 0.0;

  // Date formatting constants
  static const int daysInMonth = 30;
  static const int daysInYear = 365;

  // Icon sizes
  static const double iconSizeLarge = 48.0;
  static const double iconSizeDefault = 24.0;

  // Text line height
  static const double textLineHeight = 1.5;

  // Common error messages
  static const String errorFailedToCreate = 'Failed to create project';
  static const String errorFailedToUpdate = 'Failed to update project';
  static const String errorFailedToDelete = 'Failed to delete project';
  static const String errorFailedToLoad = 'Failed to load projects';

  // Common success messages
  static const String successProjectCreated = 'Project created successfully';
  static const String successProjectUpdated = 'Project updated successfully';
  static const String successProjectDeleted = 'Project deleted successfully';
}
