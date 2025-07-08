import 'package:flutter/material.dart';

/// Comprehensive color palette following Material 3 design principles
class SolarColorPalette {
  // === PRIMARY COLOR PALETTE ===
  static const Color primaryColor = Color(0xFF1976D2); // Material Blue 700
  static const Color primaryLight = Color(0xFF42A5F5); // Material Blue 400
  static const Color primaryDark = Color(0xFF0D47A1); // Material Blue 900
  static const Color primaryContainer = Color(0xFFE3F2FD); // Material Blue 50

  // === SECONDARY COLOR PALETTE ===
  static const Color secondaryColor = Color(0xFF26A69A); // Material Teal 400
  static const Color secondaryLight = Color(0xFF4DB6AC); // Material Teal 300
  static const Color secondaryDark = Color(0xFF00695C); // Material Teal 800
  static const Color secondaryContainer = Color(0xFFE0F2F1); // Material Teal 50

  // === TERTIARY COLOR PALETTE ===
  static const Color tertiaryColor = Color(0xFF7B1FA2); // Material Purple 700
  static const Color tertiaryLight = Color(0xFFAB47BC); // Material Purple 400
  static const Color tertiaryDark = Color(0xFF4A148C); // Material Purple 900
  static const Color tertiaryContainer = Color(0xFFF3E5F5); // Material Purple 50

  // === NEUTRAL COLOR PALETTE ===
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F2FA);
  static const Color surfaceContainer = Color(0xFFF3EDF7);
  static const Color surfaceContainerHigh = Color(0xFFECE6F0);
  static const Color surfaceContainerHighest = Color(0xFFE6E0E9);
  static const Color backgroundColor = Color(0xFFFEF7FF);

  // === SEMANTIC COLORS ===
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color warningColor = Color(0xFFEF6C00);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color infoColor = Color(0xFF0277BD);
  static const Color infoContainer = Color(0xFFB3E5FC);

  // === TEXT COLORS ===
  static const Color onSurface = Color(0xFF1D1B20);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // === SOLAR PROJECT SPECIFIC COLORS ===
  static const Color solarGold = Color(0xFFFFA726);
  static const Color solarGoldLight = Color(0xFFFFB74D);
  static const Color solarGoldDark = Color(0xFFFF8F00);
  static const Color energyGreen = Color(0xFF4CAF50);
  static const Color energyGreenLight = Color(0xFF66BB6A);
  static const Color energyGreenDark = Color(0xFF388E3C);

  // === STATUS COLORS ===
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusInactive = Color(0xFF9E9E9E);
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusError = Color(0xFFF44336);
  static const Color statusWarning = Color(0xFFFF9800);

  // === SHADOW COLORS ===
  static const Color shadowColor = Color(0xFF000000);
  static const Color shadowLightColor = Color(0x1A000000);
  static const Color shadowMediumColor = Color(0x33000000);
  static const Color shadowDarkColor = Color(0x66000000);

  // === GRADIENT COLORS ===
  static const List<Color> primaryGradient = [primaryColor, primaryLight];

  static const List<Color> secondaryGradient = [secondaryColor, secondaryLight];

  static const List<Color> solarGradient = [solarGold, solarGoldLight];

  static const List<Color> energyGradient = [energyGreen, energyGreenLight];

  // === DARK MODE COLORS ===
  static const Color darkSurfaceColor = Color(0xFF141218);
  static const Color darkBackgroundColor = Color(0xFF101014);
  static const Color darkOnSurface = Color(0xFFE6E0E9);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);

  // Private constructor to prevent instantiation
  const SolarColorPalette._();
}
