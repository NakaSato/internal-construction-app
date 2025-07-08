import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_palette.dart';
import 'text_styles.dart';
import 'component_themes.dart';

/// Refactored application theme configuration following Material 3 design principles
/// This file has been split into separate concerns for better maintainability:
/// - color_palette.dart: Color constants and definitions
/// - design_constants.dart: Spacing, sizing, and UI constants
/// - text_styles.dart: Typography and text styling
/// - component_themes.dart: Widget-specific theme configurations
class AppTheme {
  // === THEME CREATION METHODS ===

  /// Creates the light theme for the application
  static ThemeData get lightTheme {
    final textTheme = SolarTextStyles.createTextTheme(
      onSurface: SolarColorPalette.onSurface,
      fontFamily: SolarTextStyles.fontFamily,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: SolarColorPalette.primaryColor,
      brightness: Brightness.light,
      primary: SolarColorPalette.primaryColor,
      secondary: SolarColorPalette.secondaryColor,
      tertiary: SolarColorPalette.tertiaryColor,
      surface: SolarColorPalette.surfaceColor,
      error: SolarColorPalette.errorColor,
      onSurface: SolarColorPalette.onSurface,
      outline: SolarColorPalette.outline,
      outlineVariant: SolarColorPalette.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Component themes
      elevatedButtonTheme: SolarComponentThemes.elevatedButtonTheme,
      filledButtonTheme: SolarComponentThemes.filledButtonTheme,
      outlinedButtonTheme: SolarComponentThemes.outlinedButtonTheme,
      textButtonTheme: SolarComponentThemes.textButtonTheme,
      inputDecorationTheme: SolarComponentThemes.inputDecorationTheme,
      cardTheme: SolarComponentThemes.cardTheme,
      appBarTheme: SolarComponentThemes.appBarTheme,
      bottomNavigationBarTheme: SolarComponentThemes.bottomNavigationBarTheme,
      dialogTheme: SolarComponentThemes.dialogTheme,
      bottomSheetTheme: SolarComponentThemes.bottomSheetTheme,
      floatingActionButtonTheme: SolarComponentThemes.floatingActionButtonTheme,
      chipTheme: SolarComponentThemes.chipTheme,
      listTileTheme: SolarComponentThemes.listTileTheme,
      switchTheme: SolarComponentThemes.switchTheme,
      checkboxTheme: SolarComponentThemes.checkboxTheme,
      radioTheme: SolarComponentThemes.radioTheme,

      // Additional theme properties
      scaffoldBackgroundColor: SolarColorPalette.backgroundColor,
      canvasColor: SolarColorPalette.surfaceColor,
      dividerColor: SolarColorPalette.outlineVariant,
      focusColor: SolarColorPalette.primaryColor.withValues(alpha: 0.12),
      hoverColor: SolarColorPalette.primaryColor.withValues(alpha: 0.08),
      splashColor: SolarColorPalette.primaryColor.withValues(alpha: 0.12),

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Platform brightness
      brightness: Brightness.light,
    );
  }

  /// Creates the dark theme for the application
  static ThemeData get darkTheme {
    final textTheme = SolarTextStyles.createTextTheme(
      onSurface: SolarColorPalette.darkOnSurface,
      fontFamily: SolarTextStyles.fontFamily,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: SolarColorPalette.primaryColor,
      brightness: Brightness.dark,
      primary: SolarColorPalette.primaryColor,
      secondary: SolarColorPalette.secondaryColor,
      tertiary: SolarColorPalette.tertiaryColor,
      surface: SolarColorPalette.darkSurfaceColor,
      error: SolarColorPalette.errorColor,
      onSurface: SolarColorPalette.darkOnSurface,
      outline: SolarColorPalette.darkOutline,
      outlineVariant: SolarColorPalette.darkOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Component themes (will be adapted for dark mode)
      elevatedButtonTheme: SolarComponentThemes.elevatedButtonTheme,
      filledButtonTheme: SolarComponentThemes.filledButtonTheme,
      outlinedButtonTheme: SolarComponentThemes.outlinedButtonTheme,
      textButtonTheme: SolarComponentThemes.textButtonTheme,
      inputDecorationTheme: SolarComponentThemes.inputDecorationTheme,
      cardTheme: SolarComponentThemes.cardTheme,
      appBarTheme: SolarComponentThemes.appBarTheme.copyWith(
        backgroundColor: SolarColorPalette.darkSurfaceColor,
        foregroundColor: SolarColorPalette.darkOnSurface,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: SolarComponentThemes.bottomNavigationBarTheme.copyWith(
        backgroundColor: SolarColorPalette.darkSurfaceColor,
      ),
      dialogTheme: SolarComponentThemes.dialogTheme.copyWith(backgroundColor: SolarColorPalette.darkSurfaceColor),
      bottomSheetTheme: SolarComponentThemes.bottomSheetTheme.copyWith(
        backgroundColor: SolarColorPalette.darkSurfaceColor,
      ),
      floatingActionButtonTheme: SolarComponentThemes.floatingActionButtonTheme,
      chipTheme: SolarComponentThemes.chipTheme,
      listTileTheme: SolarComponentThemes.listTileTheme,
      switchTheme: SolarComponentThemes.switchTheme,
      checkboxTheme: SolarComponentThemes.checkboxTheme,
      radioTheme: SolarComponentThemes.radioTheme,

      // Additional theme properties for dark mode
      scaffoldBackgroundColor: SolarColorPalette.darkBackgroundColor,
      canvasColor: SolarColorPalette.darkSurfaceColor,
      dividerColor: SolarColorPalette.darkOutlineVariant,
      focusColor: SolarColorPalette.primaryColor.withValues(alpha: 0.12),
      hoverColor: SolarColorPalette.primaryColor.withValues(alpha: 0.08),
      splashColor: SolarColorPalette.primaryColor.withValues(alpha: 0.12),

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Platform brightness
      brightness: Brightness.dark,
    );
  }

  // === UTILITY METHODS ===

  /// Get theme mode based on system settings
  static ThemeMode getThemeMode() {
    return ThemeMode.system;
  }

  /// Get status bar style for light theme
  static SystemUiOverlayStyle get lightStatusBarStyle {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: SolarColorPalette.surfaceColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }

  /// Get status bar style for dark theme
  static SystemUiOverlayStyle get darkStatusBarStyle {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: SolarColorPalette.darkSurfaceColor,
      systemNavigationBarIconBrightness: Brightness.light,
    );
  }

  /// Apply status bar style based on theme
  static void applyStatusBarStyle(ThemeData theme) {
    if (theme.brightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(lightStatusBarStyle);
    } else {
      SystemChrome.setSystemUIOverlayStyle(darkStatusBarStyle);
    }
  }

  // === GRADIENTS ===

  static LinearGradient get primaryGradient {
    return const LinearGradient(
      colors: SolarColorPalette.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get secondaryGradient {
    return const LinearGradient(
      colors: SolarColorPalette.secondaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get solarGradient {
    return const LinearGradient(
      colors: SolarColorPalette.solarGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get energyGradient {
    return const LinearGradient(
      colors: SolarColorPalette.energyGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // === SHADOWS ===

  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(color: SolarColorPalette.shadowLightColor, offset: const Offset(0, 1), blurRadius: 3, spreadRadius: 0),
      BoxShadow(color: SolarColorPalette.shadowLightColor, offset: const Offset(0, 1), blurRadius: 2, spreadRadius: 0),
    ];
  }

  static List<BoxShadow> get elevatedShadow {
    return [
      BoxShadow(color: SolarColorPalette.shadowMediumColor, offset: const Offset(0, 2), blurRadius: 6, spreadRadius: 0),
      BoxShadow(color: SolarColorPalette.shadowLightColor, offset: const Offset(0, 1), blurRadius: 2, spreadRadius: 0),
    ];
  }

  static List<BoxShadow> get dialogShadow {
    return [
      BoxShadow(
        color: SolarColorPalette.shadowMediumColor,
        offset: const Offset(0, 8),
        blurRadius: 16,
        spreadRadius: 0,
      ),
      BoxShadow(color: SolarColorPalette.shadowLightColor, offset: const Offset(0, 4), blurRadius: 8, spreadRadius: 0),
    ];
  }

  // Private constructor to prevent instantiation
  const AppTheme._();
}
