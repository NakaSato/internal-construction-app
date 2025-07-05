library app_design_tokens;

/// App UI System - Design Tokens
///
/// This file contains all the design tokens used throughout the App Project Management app.
/// These tokens ensure consistency in spacing, colors, typography, and other design elements.

/// A P P   D E S I G N   T O K E N S
/// Centralized design system for the App Project Management app
class AppDesignTokens {
  // Private constructor to prevent instantiation
  AppDesignTokens._();

  // -----------------------------------------------------------------------------
  // Spacing Tokens
  // -----------------------------------------------------------------------------

  /// Base spacing unit (4dp) - All spacing should be multiples of this
  static const double _baseUnit = 4.0;

  /// Micro spacing - for very tight layouts
  static const double spacingXxs = _baseUnit * 1; // 4dp

  /// Extra small spacing - for compact elements
  static const double spacingXs = _baseUnit * 2; // 8dp

  /// Small spacing - for related elements
  static const double spacingSm = _baseUnit * 3; // 12dp

  /// Medium spacing - standard spacing
  static const double spacingMd = _baseUnit * 4; // 16dp

  /// Large spacing - for sections
  static const double spacingLg = _baseUnit * 6; // 24dp

  /// Extra large spacing - for major sections
  static const double spacingXl = _baseUnit * 8; // 32dp

  /// Extra extra large spacing - for screen padding
  static const double spacingXxl = _baseUnit * 12; // 48dp

  /// Maximum spacing - for major layout gaps
  static const double spacingXxxl = _baseUnit * 16; // 64dp

  // -----------------------------------------------------------------------------
  // Border Radius Tokens
  // -----------------------------------------------------------------------------

  /// No radius - for sharp corners
  static const double radiusNone = 0.0;

  /// Small radius - for small elements
  static const double radiusSm = 6.0;

  /// Medium radius - standard radius
  static const double radiusMd = 8.0;

  /// Large radius - for cards and containers
  static const double radiusLg = 12.0;

  /// Extra large radius - for prominent elements
  static const double radiusXl = 16.0;

  /// Extra extra large radius - for special containers
  static const double radiusXxl = 20.0;

  /// Maximum radius - for pills and rounded buttons
  static const double radiusMax = 24.0;

  /// Circular radius - for avatars and icons
  static const double radiusCircular = 50.0;

  // -----------------------------------------------------------------------------
  // Elevation Tokens
  // -----------------------------------------------------------------------------

  /// No elevation - for flat surfaces
  static const double elevationNone = 0.0;

  /// Subtle elevation - for slight depth
  static const double elevationXs = 1.0;

  /// Small elevation - for cards
  static const double elevationSm = 2.0;

  /// Medium elevation - for floating elements
  static const double elevationMd = 4.0;

  /// Large elevation - for modals
  static const double elevationLg = 8.0;

  /// Extra large elevation - for overlays
  static const double elevationXl = 12.0;

  /// Maximum elevation - for tooltips
  static const double elevationMax = 16.0;

  // -----------------------------------------------------------------------------
  // Size Tokens
  // -----------------------------------------------------------------------------

  /// Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  /// Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;

  /// Button heights
  static const double buttonSm = 32.0;
  static const double buttonMd = 40.0;
  static const double buttonLg = 48.0;
  static const double buttonXl = 56.0;

  /// Input field heights
  static const double inputSm = 36.0;
  static const double inputMd = 44.0;
  static const double inputLg = 52.0;

  // -----------------------------------------------------------------------------
  // Animation Tokens
  // -----------------------------------------------------------------------------

  /// Fast animations - for micro-interactions
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Standard animations - for most UI transitions
  static const Duration animationMedium = Duration(milliseconds: 250);

  /// Slow animations - for complex transitions
  static const Duration animationSlow = Duration(milliseconds: 400);

  /// Extra slow animations - for page transitions
  static const Duration animationExtraSlow = Duration(milliseconds: 600);

  // -----------------------------------------------------------------------------
  // Typography Scale
  // -----------------------------------------------------------------------------

  /// Font sizes following Material Design guidelines
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeXxxl = 24.0;
  static const double fontSize4xl = 28.0;
  static const double fontSize5xl = 32.0;
  static const double fontSize6xl = 36.0;
  static const double fontSize7xl = 48.0;

  /// Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  /// Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingExtraWide = 1.0;

  // -----------------------------------------------------------------------------
  // Breakpoints
  // -----------------------------------------------------------------------------

  /// Mobile breakpoint
  static const double breakpointMobile = 375.0;

  /// Tablet breakpoint
  static const double breakpointTablet = 768.0;

  /// Desktop breakpoint
  static const double breakpointDesktop = 1024.0;

  /// Large desktop breakpoint
  static const double breakpointLargeDesktop = 1440.0;

  // -----------------------------------------------------------------------------
  // Content Widths
  // -----------------------------------------------------------------------------

  /// Maximum content width for readability
  static const double contentMaxWidth = 1200.0;

  /// Form maximum width
  static const double formMaxWidth = 400.0;

  /// Card maximum width
  static const double cardMaxWidth = 320.0;

  // -----------------------------------------------------------------------------
  // Z-Index Tokens
  // -----------------------------------------------------------------------------

  /// Base z-index
  static const int zIndexBase = 0;

  /// Dropdown z-index
  static const int zIndexDropdown = 10;

  /// Modal z-index
  static const int zIndexModal = 20;

  /// Tooltip z-index
  static const int zIndexTooltip = 30;

  /// Overlay z-index
  static const int zIndexOverlay = 40;
}
