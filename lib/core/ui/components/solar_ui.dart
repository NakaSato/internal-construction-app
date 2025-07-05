library solar_ui_components;

/// Solar UI System - Component Library
///
/// This file provides a centralized export for all Solar UI components.
/// Import this file to access the complete Solar UI component library.

// Solar Design System
export '../design_system/design_system.dart';

// Button Components
export 'buttons/solar_button.dart';

// Card Components
export 'cards/solar_card.dart';

// Input Components
export 'inputs/solar_input_field.dart';

// Chip & Badge Components
export 'chips/solar_chip.dart';

// Navigation Components
export 'navigation/solar_navigation.dart';

// Layout Components
export 'layout/solar_layout.dart';

/// Solar UI Library
///
/// A comprehensive collection of UI components for the Solar Project Management app.
///
/// ## Usage
///
/// ```dart
/// import 'package:solar_project_management/core/ui/components/solar_ui.dart';
///
/// // Use any Solar UI component
/// SolarPrimaryButton(
///   onPressed: () {},
///   child: Text('Click me'),
/// )
///
/// SolarCard(
///   child: Text('Card content'),
/// )
///
/// SolarTextField(
///   labelText: 'Enter text',
///   onChanged: (value) {},
/// )
/// ```
///
/// ## Component Categories
///
/// ### Buttons
/// - `SolarButton` - Base button component with variants
/// - `SolarPrimaryButton` - Primary action button
/// - `SolarSecondaryButton` - Secondary action button
/// - `SolarOutlinedButton` - Outlined button
/// - `SolarTextButton` - Text-only button
///
/// ### Cards
/// - `SolarCard` - Base card component with variants
/// - `SolarProjectCard` - Specialized project card
/// - `SolarEnergyCard` - Energy metrics card
/// - `SolarStatusCard` - Status display card
/// - `SolarGlassCard` - Semi-transparent overlay card
/// - `SolarCardGrid` - Responsive card grid layout
///
/// ### Inputs
/// - `SolarTextField` - Text input with validation
/// - `SolarDropdownField` - Dropdown selection
/// - `SolarSearchField` - Search input with clear action
///
/// ### Chips & Badges
/// - `SolarChip` - Base chip component with variants
/// - `SolarStatusChip` - Status indicator chip
/// - `SolarEnergyChip` - Energy level chip
/// - `SolarBadge` - Notification badge
/// - `SolarNotificationBadge` - Specialized notification badge
/// - `SolarPriorityBadge` - Priority indicator badge
///
/// ### Navigation
/// - `SolarBottomNavigationBar` - Bottom navigation
/// - `SolarNavigationRail` - Side navigation rail
/// - `SolarTabBar` - Tab navigation
/// - `SolarAppBar` - Application bar
/// - `SolarBreadcrumb` - Navigation breadcrumb
/// - `SolarDrawer` - Navigation drawer
///
/// ### Layout
/// - `SolarPageLayout` - Full page layout wrapper
/// - `SolarSection` - Content section with header
/// - `SolarGridLayout` - Responsive grid layout
/// - `SolarResponsiveLayout` - Responsive breakpoint layout
/// - `SolarSplitLayout` - Main/aside split layout
/// - `SolarStackLayout` - Vertical/horizontal stack
/// - `SolarContainer` - Themed container
/// - `SolarSpacer` - Consistent spacing widgets
///
/// ## Design Tokens
///
/// Access design tokens for consistent spacing, colors, and sizing:
///
/// ```dart
/// // Spacing
/// AppDesignTokens.spacingMd
/// AppDesignTokens.spacingLg
///
/// // Colors
/// AppColorTokens.primary600
/// AppColorTokens.energyHigh
///
/// // Radius
/// AppDesignTokens.radiusMd
/// AppDesignTokens.radiusLg
///
/// // Elevation
/// AppDesignTokens.elevationSm
/// AppDesignTokens.elevationMd
/// ```
///
/// ## Theming
///
/// All components automatically use the app's theme. Access theme values:
///
/// ```dart
/// final theme = Theme.of(context);
/// final colorScheme = theme.colorScheme;
/// final textTheme = theme.textTheme;
/// ```
class SolarUI {
  const SolarUI._();

  /// Current version of the Solar UI library
  static const String version = '1.0.0';

  /// Design system documentation URL
  static const String docsUrl = 'https://docs.solar-ui.dev';

  /// Component library information
  static const Map<String, dynamic> info = {
    'name': 'Solar UI',
    'version': version,
    'description': 'UI component library for Solar Project Management',
    'components': {'buttons': 5, 'cards': 5, 'inputs': 3, 'chips': 6, 'navigation': 6, 'layout': 8},
    'tokens': {'spacing': 10, 'colors': 50, 'radius': 8, 'elevation': 7, 'typography': 15},
  };
}
