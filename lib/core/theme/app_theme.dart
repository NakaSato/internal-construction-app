import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// SolarAppTheme: Centralized Style Definitions for Solar Project Management App
// -----------------------------------------------------------------------------
// This file provides a centralized theme for the Solar Project Management app,
// integrated directly with Flutter's ThemeData system. It uses extensions to
// provide easy access to custom colors and text styles.
//
// How to use:
// 1. In your `main.dart`, set the `theme` property of your `MaterialApp`:
//
//    MaterialApp(
//      title: 'Solar Manager',
//      theme: SolarAppTheme.themeData,
//      home: YourHomePage(),
//    );
//
// 2. Access styles throughout your app via the BuildContext:
//    - Colors: Theme.of(context).colorScheme.primary
//    - Custom Colors: Theme.of(context).colorScheme.solarGold
//    - Text Styles: Theme.of(context).textTheme.displayHeading
//    - Spacing: SolarSpacing.md
// -----------------------------------------------------------------------------

/// C L A S S: SolarAppTheme
/// Assembles the color scheme, text theme, and component themes into a
/// complete ThemeData object optimized for solar project management.
class SolarAppTheme {
  static final ThemeData themeData = ThemeData(
    // --- Font Family ---
    fontFamily: 'Inter',
    useMaterial3: true,

    // --- Color Scheme ---
    // Solar-themed colors with energy and sustainability focus
    colorScheme: _lightColorScheme,

    // --- Text Theme ---
    // Professional text styles for technical documentation and reports
    textTheme: _textTheme,

    // --- Component Themes ---
    cardTheme: CardThemeData(
      elevation: 0,
      color: _lightColorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: _lightColorScheme.border, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: SolarSpacing.sm),
      shadowColor: _lightColorScheme.shadow,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surface,
      contentPadding: const EdgeInsets.all(16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: _lightColorScheme.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: _lightColorScheme.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: _lightColorScheme.error, width: 1),
      ),
      labelStyle: _textTheme.label,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _lightColorScheme.onPrimary,
        backgroundColor: _lightColorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: _textTheme.linkButton.copyWith(color: Colors.white),
        elevation: 2,
        shadowColor: _lightColorScheme.primary.withOpacity(0.3),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightColorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        textStyle: _textTheme.linkButton,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightColorScheme.primary,
        side: BorderSide(color: _lightColorScheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: _textTheme.linkButton,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: _lightColorScheme.surfaceTint,
      iconTheme: IconThemeData(color: _lightColorScheme.onSurface),
      titleTextStyle: _textTheme.displayHeading.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      centerTitle: false,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: _lightColorScheme.surfaceContainerHighest,
      labelStyle: _textTheme.body,
      secondaryLabelStyle: _textTheme.body,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    ),
  );
}

// -----------------------------------------------------------------------------
// Private Theme Definitions
// -----------------------------------------------------------------------------

/// Defines the solar application's core color scheme with energy-focused colors.
const ColorScheme _lightColorScheme = ColorScheme.light(
  // --- Primary Colors (Solar Blue/Orange) ---
  primary: Color(0xFF2563EB), // Solar Blue
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFDBEAFE),
  onPrimaryContainer: Color(0xFF1E3A8A),

  // --- Secondary Colors (Solar Gold/Orange) ---
  secondary: Color(0xFFEA580C), // Solar Orange
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFFED7AA),
  onSecondaryContainer: Color(0xFF9A3412),

  // --- Tertiary Colors (Solar Green for sustainability) ---
  tertiary: Color(0xFF059669), // Solar Green
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFD1FAE5),
  onTertiaryContainer: Color(0xFF064E3B),

  // --- Surface Colors ---
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF0F172A),
  surfaceContainerLowest: Color(0xFFFAFAFA),
  surfaceContainerLow: Color(0xFFF1F5F9),
  surfaceContainer: Color(0xFFE2E8F0),
  surfaceContainerHigh: Color(0xFFCBD5E1),
  surfaceContainerHighest: Color(0xFFB1C5E3),

  // --- Background Colors ---
  background: Color(0xFFF8FAFC),
  onBackground: Color(0xFF0F172A),

  // --- Error Colors ---
  error: Color(0xFFDC2626),
  onError: Colors.white,
  errorContainer: Color(0xFFFEE2E2),
  onErrorContainer: Color(0xFF991B1B),

  // --- Additional Colors ---
  outline: Color(0xFFCBD5E1),
  outlineVariant: Color(0xFFE2E8F0),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF1E293B),
  onInverseSurface: Color(0xFFF1F5F9),
  inversePrimary: Color(0xFF93C5FD),
  surfaceTint: Color(0xFF2563EB),
);

/// Defines the application's core text theme optimized for technical content.
final TextTheme _textTheme = TextTheme(
  // --- Display Styles ---
  displayLarge: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F172A),
    letterSpacing: -0.5,
  ),
  displayMedium: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F172A),
    letterSpacing: -0.3,
  ),
  displaySmall: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    letterSpacing: 0,
  ),

  // --- Headline Styles ---
  headlineLarge: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    letterSpacing: 0,
  ),
  headlineMedium: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    letterSpacing: 0.15,
  ),
  headlineSmall: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    letterSpacing: 0.15,
  ),

  // --- Title Styles ---
  titleLarge: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    letterSpacing: 0.1,
  ),
  titleMedium: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    letterSpacing: 0.1,
  ),
  titleSmall: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    letterSpacing: 0.1,
  ),

  // --- Body Styles ---
  bodyLarge: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0xFF334155),
    letterSpacing: 0.15,
    height: 1.5,
  ),
  bodyMedium: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF475569),
    letterSpacing: 0.25,
    height: 1.4,
  ),
  bodySmall: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Color(0xFF64748B),
    letterSpacing: 0.4,
    height: 1.3,
  ),

  // --- Label Styles ---
  labelLarge: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF475569),
    letterSpacing: 0.1,
  ),
  labelMedium: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF64748B),
    letterSpacing: 0.5,
  ),
  labelSmall: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFF64748B),
    letterSpacing: 0.5,
  ),
).apply(fontFamily: 'Inter');

// -----------------------------------------------------------------------------
// Theme Extensions
// -----------------------------------------------------------------------------

/// E X T E N S I O N: SolarColorScheme
/// Adds custom, solar-specific color properties to Flutter's `ColorScheme`.
extension SolarColorScheme on ColorScheme {
  // --- Solar Brand Colors ---
  Color get solarBlue => const Color(0xFF2563EB);
  Color get solarOrange => const Color(0xFFEA580C);
  Color get solarGold => const Color(0xFFF59E0B);
  Color get solarGreen => const Color(0xFF059669);

  // --- Energy Status Colors ---
  Color get energyHigh => const Color(0xFF10B981); // High energy/efficiency
  Color get energyMedium => const Color(0xFFF59E0B); // Medium energy
  Color get energyLow => const Color(0xFFEF4444); // Low energy/issues
  Color get energyOptimal => const Color(0xFF8B5CF6); // Optimal performance

  // --- Project Status Colors ---
  Color get statusActive => const Color(0xFF10B981);
  Color get statusPending => const Color(0xFFF59E0B);
  Color get statusCompleted => const Color(0xFF6366F1);
  Color get statusCancelled => const Color(0xFFEF4444);
  Color get statusDraft => const Color(0xFF6B7280);

  // --- Report Status Colors ---
  Color get reportSubmitted => const Color(0xFF3B82F6);
  Color get reportApproved => const Color(0xFF10B981);
  Color get reportRejected => const Color(0xFFEF4444);
  Color get reportDraft => const Color(0xFF6B7280);

  // --- Background Variants ---
  Color get border => const Color(0xFFE2E8F0);
  Color get cardBackground => const Color(0xFFFFFFFF);
  Color get sectionBackground => const Color(0xFFF8FAFC);

  // --- Gradient Colors ---
  Color get primaryGradientStart => const Color(0xFF1D4ED8);
  Color get primaryGradientEnd => const Color(0xFF2563EB);
  Color get secondaryGradientStart => const Color(0xFFDC2626);
  Color get secondaryGradientEnd => const Color(0xFFEA580C);
  Color get successGradientStart => const Color(0xFF047857);
  Color get successGradientEnd => const Color(0xFF059669);
}

/// E X T E N S I O N: SolarTextTheme
/// Adds custom, semantic text styles to Flutter's `TextTheme`.
extension SolarTextTheme on TextTheme {
  // --- Display Styles ---
  TextStyle get displayHeading => displayLarge!;
  TextStyle get pageTitle => displayMedium!;
  TextStyle get sectionHeading => displaySmall!;

  // --- Content Styles ---
  TextStyle get cardTitle => headlineMedium!;
  TextStyle get cardSubtitle => titleMedium!;
  TextStyle get body => bodyMedium!;
  TextStyle get caption => bodySmall!;
  TextStyle get label => labelMedium!;

  // --- Component Styles ---
  TextStyle get buttonText =>
      const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1);

  TextStyle get linkButton => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2563EB),
    letterSpacing: 0.1,
  );

  TextStyle get statusBadge =>
      const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5);

  TextStyle get metricValue =>
      const TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.3);

  TextStyle get metricLabel => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF64748B),
    letterSpacing: 0.5,
  );

  // --- Technical Text Styles ---
  TextStyle get technicalData => const TextStyle(
    fontFamily: 'JetBrains Mono', // Monospace for technical data
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF334155),
    letterSpacing: 0,
  );

  TextStyle get errorText => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFFDC2626),
    letterSpacing: 0.25,
  );
}

/// C L A S S: SolarSpacing
/// Defines the spacing constants for consistent layout throughout the solar app.
class SolarSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// C L A S S: SolarBorderRadius
/// Defines the border radius constants for consistent component styling.
class SolarBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double round = 50.0;
}

/// C L A S S: SolarElevation
/// Defines the elevation constants for consistent depth and shadows.
class SolarElevation {
  static const double none = 0.0;
  static const double sm = 1.0;
  static const double md = 2.0;
  static const double lg = 4.0;
  static const double xl = 8.0;
  static const double xxl = 12.0;
}

// -----------------------------------------------------------------------------
// Theme Extensions for BuildContext
// -----------------------------------------------------------------------------

/// E X T E N S I O N: SolarThemeExtension
/// Provides easy access to theme properties through BuildContext,
/// maintaining compatibility with existing code patterns.
extension SolarThemeExtension on BuildContext {
  /// Get the current theme data
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme (includes all solar colors via extension)
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the current text theme (includes all solar text styles via extension)
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if the current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get semantic colors for quick access
  Color get successColor => colorScheme.energyHigh;
  Color get warningColor => colorScheme.energyMedium;
  Color get errorColor => colorScheme.error;
  Color get infoColor => colorScheme.solarBlue;
}

/// C L A S S: SolarDecorations
/// Helper methods for creating consistent decorations throughout the app.
class SolarDecorations {
  /// Creates a gradient decoration with solar colors
  static BoxDecoration createGradientDecoration({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    double? borderRadius,
    double elevation = 0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(begin: begin, end: end, colors: colors),
      borderRadius: BorderRadius.circular(borderRadius ?? SolarBorderRadius.md),
      boxShadow: elevation > 0 ? createElevationShadow(elevation) : null,
    );
  }

  /// Creates a card decoration with solar styling
  static BoxDecoration createCardDecoration({
    required Color color,
    double elevation = 0,
    double? borderRadius,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius ?? SolarBorderRadius.lg),
      border: borderColor != null ? Border.all(color: borderColor, width: borderWidth) : null,
      boxShadow: elevation > 0 ? createElevationShadow(elevation) : null,
    );
  }

  /// Creates elevation shadow based on Material 3 specifications
  static List<BoxShadow> createElevationShadow(double elevation) {
    if (elevation <= 0) return [];

    final double blur = elevation * 2;
    final double offset = elevation / 2;

    return [
      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: blur, offset: Offset(0, offset)),
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: blur / 2, offset: Offset(0, offset / 2)),
    ];
  }

  // Private constructor to prevent instantiation
  SolarDecorations._();
}
