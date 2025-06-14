import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive application theme configuration following Material 3 design principles
class AppTheme {
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
  static const Color tertiaryContainer = Color(
    0xFFF3E5F5,
  ); // Material Purple 50

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

  // === ELEVATION & SHADOWS ===
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  // === BORDER RADIUS VALUES ===
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 28.0;

  // === SPACING VALUES ===
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // === TYPOGRAPHY ===
  static const String fontFamily =
      'SF Pro Display'; // iOS style font, fallback to system

  static const TextTheme _textTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
      color: onSurface,
      fontFamily: fontFamily,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.29,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.33,
      color: onSurface,
      fontFamily: fontFamily,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.27,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.50,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.43,
      color: onSurface,
      fontFamily: fontFamily,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      color: onSurfaceVariant,
      fontFamily: fontFamily,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.43,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.33,
      color: onSurface,
      fontFamily: fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.45,
      color: onSurface,
      fontFamily: fontFamily,
    ),
  );

  // === DARK THEME COLORS ===
  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkSurfaceContainer = Color(0xFF211F26);
  static const Color darkSurfaceContainerHigh = Color(0xFF2B2930);
  static const Color darkSurfaceContainerHighest = Color(0xFF36343B);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);
  static const Color darkInverseSurface = Color(0xFFE6E1E5);
  static const Color darkOnInverseSurface = Color(0xFF322F35);
  static const Color darkInversePrimary = Color(0xFF1976D2);

  // === LIGHT THEME ===
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // === COLOR SCHEME ===
    colorScheme: const ColorScheme.light(
      // Primary colors
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: primaryDark,

      // Secondary colors
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: secondaryDark,

      // Tertiary colors
      tertiary: tertiaryColor,
      onTertiary: Colors.white,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: tertiaryDark,

      // Error colors
      error: errorColor,
      onError: Colors.white,
      errorContainer: errorContainer,
      onErrorContainer: Color(0xFF410002),

      // Surface colors
      surface: surfaceColor,
      onSurface: onSurface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,

      // Outline colors
      outline: outline,
      outlineVariant: outlineVariant,

      // Inverse colors
      inverseSurface: Color(0xFF322F35),
      onInverseSurface: Color(0xFFF5EFF7),
      inversePrimary: primaryLight,

      // Shadow
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    ),

    // === SYSTEM UI OVERLAY STYLE ===
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _textTheme.titleLarge?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: onSurface, size: 24),
      actionsIconTheme: const IconThemeData(color: onSurface, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    // === NAVIGATION BAR THEME ===
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // === BUTTON THEMES ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: primaryColor.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingXXL,
              vertical: spacingL,
            ),
            minimumSize: const Size(64, 40),
            textStyle: _textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return primaryDark;
              }
              if (states.contains(WidgetState.disabled)) {
                return outline.withValues(alpha: 0.12);
              }
              return primaryColor;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return onSurface.withValues(alpha: 0.38);
              }
              return Colors.white;
            }),
          ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingXXL,
          vertical: spacingL,
        ),
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: outline, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingXXL,
              vertical: spacingL,
            ),
            textStyle: _textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            side: WidgetStateProperty.resolveWith<BorderSide>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return const BorderSide(color: primaryColor, width: 1);
              }
              if (states.contains(WidgetState.focused)) {
                return const BorderSide(color: primaryColor, width: 1);
              }
              if (states.contains(WidgetState.disabled)) {
                return BorderSide(color: onSurface.withValues(alpha: 0.12), width: 1);
              }
              return const BorderSide(color: outline, width: 1);
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return onSurface.withValues(alpha: 0.38);
              }
              return primaryColor;
            }),
          ),
    ),

    textButtonTheme: TextButtonThemeData(
      style:
          TextButton.styleFrom(
            foregroundColor: primaryColor,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingM,
              vertical: spacingS,
            ),
            minimumSize: const Size(64, 40),
            textStyle: _textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return onSurface.withValues(alpha: 0.38);
              }
              return primaryColor;
            }),
          ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style:
          IconButton.styleFrom(
            foregroundColor: onSurfaceVariant,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM),
            ),
            minimumSize: const Size(40, 40),
          ).copyWith(
            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return primaryColor;
              }
              if (states.contains(WidgetState.disabled)) {
                return onSurface.withValues(alpha: 0.38);
              }
              return onSurfaceVariant;
            }),
          ),
    ),

    // === CARD THEME ===
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      surfaceTintColor: primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      margin: const EdgeInsets.all(spacingS),
      color: surfaceContainerLow,
    ),

    // === INPUT DECORATION THEME ===
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: onSurface.withValues(alpha: 0.12), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingL,
        vertical: spacingL,
      ),
      hintStyle: _textTheme.bodyLarge?.copyWith(color: onSurfaceVariant),
      labelStyle: _textTheme.bodyLarge?.copyWith(color: onSurfaceVariant),
      floatingLabelStyle: _textTheme.bodySmall?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      errorStyle: _textTheme.bodySmall?.copyWith(color: errorColor),
    ),

    // === DIALOG THEME ===
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceContainerHigh,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXXL),
      ),
      titleTextStyle: _textTheme.headlineSmall?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: _textTheme.bodyMedium?.copyWith(
        color: onSurfaceVariant,
      ),
    ),

    // === SNACKBAR THEME ===
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF322F35),
      contentTextStyle: _textTheme.bodyMedium?.copyWith(
        color: Color(0xFFF5EFF7),
      ),
      actionTextColor: primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusS),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),

    // === CHIP THEME ===
    chipTheme: ChipThemeData(
      backgroundColor: surfaceContainerLow,
      selectedColor: secondaryContainer,
      disabledColor: onSurface.withValues(alpha: 0.12),
      deleteIconColor: onSurfaceVariant,
      labelStyle: _textTheme.labelLarge?.copyWith(color: onSurfaceVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusS),
      ),
      side: const BorderSide(color: outline, width: 1),
      elevation: 0,
      pressElevation: 1,
    ),

    // === FLOATING ACTION BUTTON THEME ===
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryContainer,
      foregroundColor: primaryColor,
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 8,
      highlightElevation: 12,
      shape: CircleBorder(),
    ),

    // === DIVIDER THEME ===
    dividerTheme: const DividerThemeData(
      color: outlineVariant,
      thickness: 1,
      space: 1,
    ),

    // === LIST TILE THEME ===
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingL,
        vertical: spacingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusS),
      ),
      tileColor: Colors.transparent,
      selectedTileColor: primaryContainer.withValues(alpha: 0.5),
      titleTextStyle: _textTheme.titleMedium?.copyWith(color: onSurface),
      subtitleTextStyle: _textTheme.bodyMedium?.copyWith(
        color: onSurfaceVariant,
      ),
      leadingAndTrailingTextStyle: _textTheme.labelSmall?.copyWith(
        color: onSurfaceVariant,
      ),
      iconColor: onSurfaceVariant,
      textColor: onSurface,
    ),

    // === SWITCH THEME ===
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return surfaceContainerHighest;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return outline;
      }),
    ),

    // === CHECKBOX THEME ===
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: outline, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXS),
      ),
    ),

    // === RADIO THEME ===
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return outline;
      }),
    ),

    // === PROGRESS INDICATOR THEME ===
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: outlineVariant,
      circularTrackColor: outlineVariant,
    ),

    // === TAB BAR THEME ===
    tabBarTheme: TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: onSurfaceVariant,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryColor, width: 2)),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: _textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: _textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.normal,
      ),
    ),

    // === TEXT THEME ===
    textTheme: _textTheme,
    primaryTextTheme: _textTheme,

    // === VISUAL DENSITY ===
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // === MATERIAL TAPS ===
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // === PAGE TRANSITIONS ===
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // === DARK THEME ===
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // === COLOR SCHEME ===
    colorScheme: const ColorScheme.dark(
      // Primary colors
      primary: primaryLight,
      onPrimary: Color(0xFF003258),
      primaryContainer: Color(0xFF004881),
      onPrimaryContainer: Color(0xFFD1E4FF),

      // Secondary colors
      secondary: secondaryLight,
      onSecondary: Color(0xFF003730),
      secondaryContainer: Color(0xFF005048),
      onSecondaryContainer: Color(0xFFB2CCC7),

      // Tertiary colors
      tertiary: tertiaryLight,
      onTertiary: Color(0xFF31135D),
      tertiaryContainer: Color(0xFF492286),
      onTertiaryContainer: Color(0xFFE8DDFF),

      // Error colors
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      // Surface colors
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerLowest: Color(0xFF0F0D13),
      surfaceContainerLow: Color(0xFF1D1B20),
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      onSurfaceVariant: darkOnSurfaceVariant,

      // Outline colors
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,

      // Inverse colors
      inverseSurface: darkInverseSurface,
      onInverseSurface: darkOnInverseSurface,
      inversePrimary: darkInversePrimary,

      // Shadow
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    ),

    // === SYSTEM UI OVERLAY STYLE ===
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkOnSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _textTheme.titleLarge?.copyWith(
        color: darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: darkOnSurface, size: 24),
      actionsIconTheme: const IconThemeData(color: darkOnSurface, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // === NAVIGATION BAR THEME ===
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryLight,
      unselectedItemColor: darkOnSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // === BUTTON THEMES ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Color(0xFF003258),
        elevation: 2,
        shadowColor: primaryLight.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingXXL,
          vertical: spacingL,
        ),
        minimumSize: const Size(64, 40),
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Color(0xFF003258),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingXXL,
          vertical: spacingL,
        ),
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: darkOutline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingXXL,
          vertical: spacingL,
        ),
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        minimumSize: const Size(64, 40),
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: darkOnSurfaceVariant,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        minimumSize: const Size(40, 40),
      ),
    ),

    // === CARD THEME ===
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      surfaceTintColor: primaryLight.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      margin: const EdgeInsets.all(spacingS),
      color: darkSurfaceContainer,
    ),

    // === INPUT DECORATION THEME ===
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: darkOutline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: darkOutline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(
          color: darkOnSurface.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingL,
        vertical: spacingL,
      ),
      hintStyle: _textTheme.bodyLarge?.copyWith(color: darkOnSurfaceVariant),
      labelStyle: _textTheme.bodyLarge?.copyWith(color: darkOnSurfaceVariant),
      floatingLabelStyle: _textTheme.bodySmall?.copyWith(
        color: primaryLight,
        fontWeight: FontWeight.w600,
      ),
      errorStyle: _textTheme.bodySmall?.copyWith(color: Color(0xFFFFB4AB)),
    ),

    // === DIALOG THEME ===
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurfaceContainerHigh,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXXL),
      ),
      titleTextStyle: _textTheme.headlineSmall?.copyWith(
        color: darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: _textTheme.bodyMedium?.copyWith(
        color: darkOnSurfaceVariant,
      ),
    ),

    // === SNACKBAR THEME ===
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkInverseSurface,
      contentTextStyle: _textTheme.bodyMedium?.copyWith(
        color: darkOnInverseSurface,
      ),
      actionTextColor: primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusS),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),

    // === CHIP THEME ===
    chipTheme: ChipThemeData(
      backgroundColor: darkSurfaceContainer,
      selectedColor: Color(0xFF005048),
      disabledColor: darkOnSurface.withValues(alpha: 0.12),
      deleteIconColor: darkOnSurfaceVariant,
      labelStyle: _textTheme.labelLarge?.copyWith(color: darkOnSurfaceVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusS),
      ),
      side: const BorderSide(color: darkOutline, width: 1),
      elevation: 0,
      pressElevation: 1,
    ),

    // === FLOATING ACTION BUTTON THEME ===
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF004881),
      foregroundColor: Color(0xFFD1E4FF),
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 8,
      highlightElevation: 12,
      shape: CircleBorder(),
    ),

    // === DIVIDER THEME ===
    dividerTheme: const DividerThemeData(
      color: darkOutlineVariant,
      thickness: 1,
      space: 1,
    ),

    // === LIST TILE THEME ===
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingL,
        vertical: spacingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusS),
      ),
      tileColor: Colors.transparent,
      selectedTileColor: Color(0xFF004881).withValues(alpha: 0.5),
      titleTextStyle: _textTheme.titleMedium?.copyWith(color: darkOnSurface),
      subtitleTextStyle: _textTheme.bodyMedium?.copyWith(
        color: darkOnSurfaceVariant,
      ),
      leadingAndTrailingTextStyle: _textTheme.labelSmall?.copyWith(
        color: darkOnSurfaceVariant,
      ),
      iconColor: darkOnSurfaceVariant,
      textColor: darkOnSurface,
    ),

    // === SWITCH THEME ===
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return Color(0xFF003258);
        }
        return darkSurfaceContainerHighest;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return darkOutline;
      }),
    ),

    // === CHECKBOX THEME ===
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Color(0xFF003258)),
      side: const BorderSide(color: darkOutline, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXS),
      ),
    ),

    // === RADIO THEME ===
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return darkOutline;
      }),
    ),

    // === PROGRESS INDICATOR THEME ===
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: darkOutlineVariant,
      circularTrackColor: darkOutlineVariant,
    ),

    // === TAB BAR THEME ===
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: darkOnSurfaceVariant,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryLight, width: 2)),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: _textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: _textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.normal,
      ),
    ),

    // === TEXT THEME ===
    textTheme: _textTheme.apply(
      bodyColor: darkOnSurface,
      displayColor: darkOnSurface,
    ),
    primaryTextTheme: _textTheme.apply(
      bodyColor: darkOnSurface,
      displayColor: darkOnSurface,
    ),

    // === VISUAL DENSITY ===
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // === MATERIAL TAPS ===
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // === PAGE TRANSITIONS ===
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // === SEMANTIC COLOR GETTERS ===
  static Color get success => successColor;
  static Color get successBg => successContainer;
  static Color get warning => warningColor;
  static Color get warningBg => warningContainer;
  static Color get info => infoColor;
  static Color get infoBg => infoContainer;

  // === UTILITY METHODS ===

  /// Get appropriate text color for given background color
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? onSurface : Colors.white;
  }

  /// Get elevation shadow for given elevation level
  static List<BoxShadow> getElevationShadow(int level) {
    switch (level) {
      case 1:
        return elevation1;
      case 2:
        return elevation2;
      case 3:
        return elevation3;
      default:
        return elevation1;
    }
  }

  /// Get border radius for given size
  static BorderRadius getBorderRadius(String size) {
    switch (size) {
      case 'xs':
        return BorderRadius.circular(radiusXS);
      case 's':
        return BorderRadius.circular(radiusS);
      case 'm':
        return BorderRadius.circular(radiusM);
      case 'l':
        return BorderRadius.circular(radiusL);
      case 'xl':
        return BorderRadius.circular(radiusXL);
      case 'xxl':
        return BorderRadius.circular(radiusXXL);
      default:
        return BorderRadius.circular(radiusM);
    }
  }

  /// Get spacing value for given size
  static double getSpacing(String size) {
    switch (size) {
      case 'xs':
        return spacingXS;
      case 's':
        return spacingS;
      case 'm':
        return spacingM;
      case 'l':
        return spacingL;
      case 'xl':
        return spacingXL;
      case 'xxl':
        return spacingXXL;
      case 'xxxl':
        return spacingXXXL;
      default:
        return spacingM;
    }
  }

  /// Create a custom button style with specified colors
  static ButtonStyle createCustomButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    double? elevation,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(radiusM),
      ),
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: spacingXXL,
            vertical: spacingL,
          ),
    );
  }

  /// Create a custom card decoration
  static BoxDecoration createCardDecoration({
    Color? color,
    int elevation = 1,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
  }) {
    return BoxDecoration(
      color: color ?? surfaceContainerLow,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
      boxShadow: getElevationShadow(elevation),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth ?? 1)
          : null,
    );
  }

  /// Create gradient decoration
  static BoxDecoration createGradientDecoration({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    double? borderRadius,
    int elevation = 0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(begin: begin, end: end, colors: colors),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
      boxShadow: elevation > 0 ? getElevationShadow(elevation) : null,
    );
  }

  // Private constructor to prevent instantiation
  AppTheme._();
}

/// Extension on BuildContext to easily access theme colors and styles
extension ThemeExtension on BuildContext {
  /// Get the current theme data
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if the current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get semantic success color
  Color get successColor => AppTheme.success;

  /// Get semantic warning color
  Color get warningColor => AppTheme.warning;

  /// Get semantic info color
  Color get infoColor => AppTheme.info;
}

/// Extension on ColorScheme for additional semantic colors
extension ColorSchemeExtension on ColorScheme {
  /// Success color
  Color get success => AppTheme.success;

  /// Success container color
  Color get onSuccess => Colors.white;

  /// Warning color
  Color get warning => AppTheme.warning;

  /// Warning container color
  Color get onWarning => Colors.white;

  /// Info color
  Color get info => AppTheme.info;

  /// Info container color
  Color get onInfo => Colors.white;
}
