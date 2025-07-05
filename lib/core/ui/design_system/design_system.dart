library app_design_system;

/// **App Design System**
///
/// Complete design system for the App Project Management application.
/// This provides a comprehensive, cohesive design language that ensures
/// consistency across all UI components and screens.
///
/// ## 🎨 What's Included
///
/// ### Design Tokens (`AppDesignTokens`)
/// - **Spacing**: 4dp grid system for consistent layouts
/// - **Typography**: Font sizes, line heights, letter spacing
/// - **Border Radius**: Consistent corner radius values
/// - **Elevation**: Shadow depth levels
/// - **Sizing**: Icon, avatar, button, and input dimensions
/// - **Animation**: Duration constants for smooth transitions
/// - **Layout**: Breakpoints, content widths, z-index values
///
/// ### Color System (`AppColorTokens`)
/// - **Brand Colors**: Primary blue and secondary solar orange
/// - **Semantic Colors**: Success green, warning gold, error red
/// - **Neutral Scale**: Complete grayscale for text and backgrounds
/// - **Solar-Specific**: Energy level and project status indicators
/// - **Accessibility**: WCAG AA compliant contrast ratios
///
/// ## 🚀 Quick Start
///
/// ```dart
/// import 'package:your_app/core/ui/design_system/design_system.dart';
///
/// // Use spacing tokens
/// SizedBox(height: AppDesignTokens.spacingMd)
///
/// // Use colors
/// Container(color: AppColorTokens.primary600)
///
/// // Use sizing
/// Icon(size: AppDesignTokens.iconMd)
/// ```
///
/// ## 📚 Best Practices
///
/// - **Always use tokens** instead of hardcoded values
/// - **Follow semantic naming** for colors (e.g., `statusActive` not `blue`)
/// - **Maintain consistency** across all components
/// - **Test accessibility** with different color contrasts
/// - **Keep it simple** - don't create too many variations

// Core Design Tokens
export 'tokens.dart';

// Color System
export 'colors.dart';
