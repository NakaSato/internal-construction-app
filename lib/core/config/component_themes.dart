import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_palette.dart';
import 'design_constants.dart';
import 'text_styles.dart';

/// Component-specific theme configurations
class SolarComponentThemes {
  // === BUTTON THEMES ===
  static ElevatedButtonThemeData get elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            backgroundColor: SolarColorPalette.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.md)),
            padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.xxl, vertical: SolarSpacing.lg),
            minimumSize: const Size(64, SolarUIConstants.buttonHeight),
            textStyle: SolarTextStyles.createTextTheme().labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return SolarColorPalette.primaryDark;
              }
              if (states.contains(WidgetState.disabled)) {
                return SolarColorPalette.outline.withValues(alpha: 0.12);
              }
              return SolarColorPalette.primaryColor;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return SolarColorPalette.onSurface.withValues(alpha: 0.38);
              }
              return Colors.white;
            }),
          ),
    );
  }

  static FilledButtonThemeData get filledButtonTheme {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SolarColorPalette.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.md)),
        padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.xxl, vertical: SolarSpacing.lg),
        textStyle: SolarTextStyles.createTextTheme().labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData get outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SolarColorPalette.primaryColor,
        side: const BorderSide(color: SolarColorPalette.primaryColor, width: 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.md)),
        padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.xxl, vertical: SolarSpacing.lg),
        textStyle: SolarTextStyles.createTextTheme().labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData get textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SolarColorPalette.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.md, vertical: SolarSpacing.sm),
        textStyle: SolarTextStyles.createTextTheme().labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  // === INPUT THEMES ===
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: SolarColorPalette.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SolarBorderRadius.md),
        borderSide: const BorderSide(color: SolarColorPalette.outline, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SolarBorderRadius.md),
        borderSide: const BorderSide(color: SolarColorPalette.outline, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SolarBorderRadius.md),
        borderSide: const BorderSide(color: SolarColorPalette.primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SolarBorderRadius.md),
        borderSide: const BorderSide(color: SolarColorPalette.errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SolarBorderRadius.md),
        borderSide: const BorderSide(color: SolarColorPalette.errorColor, width: 2.0),
      ),
      contentPadding: const EdgeInsets.all(SolarSpacing.md),
      labelStyle: SolarTextStyles.createTextTheme().bodyMedium?.copyWith(color: SolarColorPalette.onSurfaceVariant),
      hintStyle: SolarTextStyles.createTextTheme().bodyMedium?.copyWith(
        color: SolarColorPalette.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }

  // === CARD THEME ===
  static CardThemeData get cardTheme {
    return CardThemeData(
      elevation: SolarSpacing.elevationSM,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.md)),
      color: SolarColorPalette.surfaceColor,
      margin: const EdgeInsets.all(SolarSpacing.sm),
    );
  }

  // === APP BAR THEME ===
  static AppBarTheme get appBarTheme {
    return AppBarTheme(
      backgroundColor: SolarColorPalette.surfaceColor,
      foregroundColor: SolarColorPalette.onSurface,
      elevation: SolarUIConstants.appBarElevation,
      centerTitle: false,
      titleTextStyle: SolarTextStyles.createTextTheme().titleLarge?.copyWith(fontWeight: FontWeight.w600),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  // === BOTTOM NAVIGATION BAR THEME ===
  static BottomNavigationBarThemeData get bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: SolarColorPalette.surfaceColor,
      selectedItemColor: SolarColorPalette.primaryColor,
      unselectedItemColor: SolarColorPalette.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: SolarSpacing.elevationSM,
      selectedLabelStyle: SolarTextStyles.createTextTheme().labelSmall?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: SolarTextStyles.createTextTheme().labelSmall,
    );
  }

  // === DIALOG THEME ===
  static DialogThemeData get dialogTheme {
    return DialogThemeData(
      backgroundColor: SolarColorPalette.surfaceColor,
      elevation: SolarSpacing.elevationLG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.lg)),
      titleTextStyle: SolarTextStyles.createTextTheme().titleLarge?.copyWith(fontWeight: FontWeight.w600),
      contentTextStyle: SolarTextStyles.createTextTheme().bodyMedium,
    );
  }

  // === BOTTOM SHEET THEME ===
  static BottomSheetThemeData get bottomSheetTheme {
    return BottomSheetThemeData(
      backgroundColor: SolarColorPalette.surfaceColor,
      elevation: SolarSpacing.elevationXL,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SolarBorderRadius.lg),
          topRight: Radius.circular(SolarBorderRadius.lg),
        ),
      ),
      constraints: const BoxConstraints(maxWidth: SolarUIConstants.dialogMaxWidth),
    );
  }

  // === FLOATING ACTION BUTTON THEME ===
  static FloatingActionButtonThemeData get floatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: SolarColorPalette.primaryColor,
      foregroundColor: Colors.white,
      elevation: SolarSpacing.elevationMD,
      focusElevation: SolarSpacing.elevationLG,
      hoverElevation: SolarSpacing.elevationMD,
      highlightElevation: SolarSpacing.elevationLG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.lg)),
    );
  }

  // === CHIP THEME ===
  static ChipThemeData get chipTheme {
    return ChipThemeData(
      backgroundColor: SolarColorPalette.surfaceContainerLow,
      labelStyle: SolarTextStyles.createTextTheme().labelMedium?.copyWith(fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.md, vertical: SolarSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.sm)),
    );
  }

  // === LIST TILE THEME ===
  static ListTileThemeData get listTileTheme {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: SolarSpacing.md, vertical: SolarSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.sm)),
      titleTextStyle: SolarTextStyles.createTextTheme().bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      subtitleTextStyle: SolarTextStyles.createTextTheme().bodyMedium?.copyWith(
        color: SolarColorPalette.onSurfaceVariant,
      ),
    );
  }

  // === SWITCH THEME ===
  static SwitchThemeData get switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return SolarColorPalette.primaryColor;
        }
        return SolarColorPalette.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return SolarColorPalette.primaryColor.withValues(alpha: 0.3);
        }
        return SolarColorPalette.outline.withValues(alpha: 0.3);
      }),
    );
  }

  // === CHECKBOX THEME ===
  static CheckboxThemeData get checkboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return SolarColorPalette.primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: SolarColorPalette.outline, width: 1.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SolarBorderRadius.xs)),
    );
  }

  // === RADIO THEME ===
  static RadioThemeData get radioTheme {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return SolarColorPalette.primaryColor;
        }
        return SolarColorPalette.outline;
      }),
    );
  }

  // Private constructor to prevent instantiation
  const SolarComponentThemes._();
}
