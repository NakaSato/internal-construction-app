import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'design_constants.dart';

/// Typography styles following Material 3 design system
class SolarTextStyles {
  // === FONT FAMILY ===
  static const String fontFamily = 'Inter';

  // === TEXT STYLES ===
  static TextTheme createTextTheme({Color? onSurface, String? fontFamily}) {
    final textColor = onSurface ?? SolarColorPalette.onSurface;
    final textFontFamily = fontFamily ?? SolarTextStyles.fontFamily;

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: SolarTypography.displayLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.12,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: SolarTypography.displayMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.16,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: SolarTypography.displaySmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.22,
        color: textColor,
        fontFamily: textFontFamily,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: SolarTypography.headlineLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: SolarTypography.headlineMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.29,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: SolarTypography.headlineSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: textColor,
        fontFamily: textFontFamily,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: SolarTypography.titleLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: SolarTypography.titleMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: SolarTypography.titleSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: textColor,
        fontFamily: textFontFamily,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: SolarTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: SolarTypography.bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: SolarTypography.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: textColor,
        fontFamily: textFontFamily,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: SolarTypography.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: SolarTypography.labelMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
        color: textColor,
        fontFamily: textFontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: SolarTypography.labelSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
        color: textColor,
        fontFamily: textFontFamily,
      ),
    );
  }

  // === CUSTOM TEXT STYLES ===
  static TextStyle get caption => TextStyle(
    fontSize: SolarTypography.bodySmall,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: SolarColorPalette.onSurfaceVariant,
    fontFamily: fontFamily,
  );

  static TextStyle get overline => TextStyle(
    fontSize: SolarTypography.labelSmall,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.45,
    color: SolarColorPalette.onSurfaceVariant,
    fontFamily: fontFamily,
  );

  static TextStyle get button => TextStyle(
    fontSize: SolarTypography.labelLarge,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: SolarColorPalette.onSurface,
    fontFamily: fontFamily,
  );

  // === SOLAR PROJECT SPECIFIC TEXT STYLES ===
  static TextStyle get projectTitle => TextStyle(
    fontSize: SolarTypography.titleLarge,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.27,
    color: SolarColorPalette.onSurface,
    fontFamily: fontFamily,
  );

  static TextStyle get projectSubtitle => TextStyle(
    fontSize: SolarTypography.bodyMedium,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.43,
    color: SolarColorPalette.onSurfaceVariant,
    fontFamily: fontFamily,
  );

  static TextStyle get projectStatus => TextStyle(
    fontSize: SolarTypography.labelMedium,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.33,
    fontFamily: fontFamily,
  );

  static TextStyle get projectMetric => TextStyle(
    fontSize: SolarTypography.headlineMedium,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.29,
    color: SolarColorPalette.primaryColor,
    fontFamily: fontFamily,
  );

  static TextStyle get projectMetricLabel => TextStyle(
    fontSize: SolarTypography.labelMedium,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: SolarColorPalette.onSurfaceVariant,
    fontFamily: fontFamily,
  );

  // Private constructor to prevent instantiation
  const SolarTextStyles._();
}
