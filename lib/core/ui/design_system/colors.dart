library app_color_tokens;

import 'package:flutter/material.dart';

/// A P P   C O L O R   T O K E N S
/// Semantic color tokens for the App Project Management app
class AppColorTokens {
  AppColorTokens._();

  // -----------------------------------------------------------------------------
  // Primary Colors
  // -----------------------------------------------------------------------------

  static const Color primary50 = Color(0xFFEFF6FF);
  static const Color primary100 = Color(0xFFDBEAFE);
  static const Color primary200 = Color(0xFFBFDBFE);
  static const Color primary300 = Color(0xFF93C5FD);
  static const Color primary400 = Color(0xFF60A5FA);
  static const Color primary500 = Color(0xFF3B82F6);
  static const Color primary600 = Color(0xFF2563EB); // Main brand color
  static const Color primary700 = Color(0xFF1D4ED8);
  static const Color primary800 = Color(0xFF1E40AF);
  static const Color primary900 = Color(0xFF1E3A8A);

  // -----------------------------------------------------------------------------
  // Secondary Colors (Solar Orange)
  // -----------------------------------------------------------------------------

  static const Color secondary50 = Color(0xFFFFF7ED);
  static const Color secondary100 = Color(0xFFFFEDD5);
  static const Color secondary200 = Color(0xFFFED7AA);
  static const Color secondary300 = Color(0xFFFDBA74);
  static const Color secondary400 = Color(0xFFFB923C);
  static const Color secondary500 = Color(0xFFF97316);
  static const Color secondary600 = Color(0xFFEA580C); // Solar orange
  static const Color secondary700 = Color(0xFFC2410C);
  static const Color secondary800 = Color(0xFF9A3412);
  static const Color secondary900 = Color(0xFF7C2D12);

  // -----------------------------------------------------------------------------
  // Success Colors (Solar Green)
  // -----------------------------------------------------------------------------

  static const Color success50 = Color(0xFFECFDF5);
  static const Color success100 = Color(0xFFD1FAE5);
  static const Color success200 = Color(0xFFA7F3D0);
  static const Color success300 = Color(0xFF6EE7B7);
  static const Color success400 = Color(0xFF34D399);
  static const Color success500 = Color(0xFF10B981);
  static const Color success600 = Color(0xFF059669); // Solar green
  static const Color success700 = Color(0xFF047857);
  static const Color success800 = Color(0xFF065F46);
  static const Color success900 = Color(0xFF064E3B);

  // -----------------------------------------------------------------------------
  // Warning Colors (Solar Gold)
  // -----------------------------------------------------------------------------

  static const Color warning50 = Color(0xFFFEFCE8);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning300 = Color(0xFFFCD34D);
  static const Color warning400 = Color(0xFFFBBF24);
  static const Color warning500 = Color(0xFFF59E0B); // Solar gold
  static const Color warning600 = Color(0xFFD97706);
  static const Color warning700 = Color(0xFFB45309);
  static const Color warning800 = Color(0xFF92400E);
  static const Color warning900 = Color(0xFF78350F);

  // -----------------------------------------------------------------------------
  // Error Colors
  // -----------------------------------------------------------------------------

  static const Color error50 = Color(0xFFFEF2F2);
  static const Color error100 = Color(0xFFFEE2E2);
  static const Color error200 = Color(0xFFFECACA);
  static const Color error300 = Color(0xFFFCA5A5);
  static const Color error400 = Color(0xFFF87171);
  static const Color error500 = Color(0xFFEF4444);
  static const Color error600 = Color(0xFFDC2626);
  static const Color error700 = Color(0xFFB91C1C);
  static const Color error800 = Color(0xFF991B1B);
  static const Color error900 = Color(0xFF7F1D1D);

  // -----------------------------------------------------------------------------
  // Neutral Colors
  // -----------------------------------------------------------------------------

  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // -----------------------------------------------------------------------------
  // Semantic Solar Colors
  // -----------------------------------------------------------------------------

  /// High energy production (bright green)
  static const Color energyHigh = success600;

  /// Medium energy production (solar gold)
  static const Color energyMedium = warning500;

  /// Low energy production (orange)
  static const Color energyLow = secondary600;

  /// No energy production (red)
  static const Color energyNone = error600;

  /// Optimal energy conditions (vibrant green)
  static const Color energyOptimal = Color(0xFF10B981);

  // -----------------------------------------------------------------------------
  // Project Status Colors
  // -----------------------------------------------------------------------------

  /// Active project (blue)
  static const Color statusActive = primary600;

  /// Pending project (orange)
  static const Color statusPending = warning500;

  /// Completed project (green)
  static const Color statusCompleted = success600;

  /// Cancelled project (red)
  static const Color statusCancelled = error600;

  /// On hold project (neutral)
  static const Color statusOnHold = neutral500;

  // -----------------------------------------------------------------------------
  // Background Colors
  // -----------------------------------------------------------------------------

  /// Primary background
  static const Color backgroundPrimary = Color(0xFFFFFFFF);

  /// Secondary background
  static const Color backgroundSecondary = Color(0xFFF8FAFC);

  /// Tertiary background
  static const Color backgroundTertiary = Color(0xFFF1F5F9);

  /// Card background
  static const Color backgroundCard = Color(0xFFFFFFFF);

  /// Modal background
  static const Color backgroundModal = Color(0x80000000);
}
