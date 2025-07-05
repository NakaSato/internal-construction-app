library solar_ui_buttons;

/// Solar UI System - Button Components
///
/// This file contains all button components for the Solar Project Management app.
/// These components follow Material Design 3 guidelines with solar-specific styling.

import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// Solar Button Variant Types
enum SolarButtonVariant { primary, secondary, outlined, text, elevated, filled, filledTonal }

/// Solar Button Size Options
enum SolarButtonSize { small, medium, large, extraLarge }

/// Solar Button Base Widget
///
/// A flexible button component that supports multiple variants, sizes, and states.
/// Follows Material Design 3 guidelines with solar-specific theming.
class SolarButton extends StatelessWidget {
  const SolarButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = SolarButtonVariant.primary,
    this.size = SolarButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.borderRadius,
  });

  /// Button press callback
  final VoidCallback? onPressed;

  /// Button content
  final Widget child;

  /// Button visual variant
  final SolarButtonVariant variant;

  /// Button size
  final SolarButtonSize size;

  /// Loading state
  final bool isLoading;

  /// Disabled state
  final bool isDisabled;

  /// Leading icon
  final Widget? leadingIcon;

  /// Trailing icon
  final Widget? trailingIcon;

  /// Full width button
  final bool fullWidth;

  /// Custom border radius
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final buttonHeight = _getButtonHeight();

    Widget buttonChild = _buildButtonContent(context);

    if (isLoading) {
      buttonChild = _buildLoadingContent(context);
    }

    Widget button = _buildButtonByVariant(context: context, style: buttonStyle, child: buttonChild);

    if (fullWidth) {
      button = SizedBox(width: double.infinity, height: buttonHeight, child: button);
    } else {
      button = SizedBox(height: buttonHeight, child: button);
    }

    return button;
  }

  /// Build button content with icons
  Widget _buildButtonContent(BuildContext context) {
    final children = <Widget>[];

    if (leadingIcon != null) {
      children.add(leadingIcon!);
      children.add(SizedBox(width: _getIconSpacing()));
    }

    children.add(Flexible(child: child));

    if (trailingIcon != null) {
      children.add(SizedBox(width: _getIconSpacing()));
      children.add(trailingIcon!);
    }

    return Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  /// Build loading content
  Widget _buildLoadingContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color indicatorColor;
    switch (variant) {
      case SolarButtonVariant.primary:
      case SolarButtonVariant.elevated:
      case SolarButtonVariant.filled:
        indicatorColor = colorScheme.onPrimary;
        break;
      case SolarButtonVariant.filledTonal:
        indicatorColor = colorScheme.onSecondaryContainer;
        break;
      default:
        indicatorColor = colorScheme.primary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _getLoadingIndicatorSize(),
          height: _getLoadingIndicatorSize(),
          child: CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(indicatorColor)),
        ),
        SizedBox(width: _getIconSpacing()),
        child,
      ],
    );
  }

  /// Build button based on variant
  Widget _buildButtonByVariant({required BuildContext context, required ButtonStyle style, required Widget child}) {
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    switch (variant) {
      case SolarButtonVariant.primary:
      case SolarButtonVariant.filled:
        return FilledButton(onPressed: effectiveOnPressed, style: style, child: child);

      case SolarButtonVariant.secondary:
      case SolarButtonVariant.filledTonal:
        return FilledButton.tonal(onPressed: effectiveOnPressed, style: style, child: child);

      case SolarButtonVariant.outlined:
        return OutlinedButton(onPressed: effectiveOnPressed, style: style, child: child);

      case SolarButtonVariant.text:
        return TextButton(onPressed: effectiveOnPressed, style: style, child: child);

      case SolarButtonVariant.elevated:
        return ElevatedButton(onPressed: effectiveOnPressed, style: style, child: child);
    }
  }

  /// Get button style based on variant and size
  ButtonStyle _getButtonStyle(BuildContext context) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(_getButtonPadding()),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? _getDefaultBorderRadius())),
      ),
      textStyle: WidgetStateProperty.all(_getTextStyle(context)),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (variant == SolarButtonVariant.elevated) {
          if (states.contains(WidgetState.pressed)) {
            return AppDesignTokens.elevationSm;
          }
          return AppDesignTokens.elevationMd;
        }
        return AppDesignTokens.elevationNone;
      }),
    );
  }

  /// Get button height based on size
  double _getButtonHeight() {
    switch (size) {
      case SolarButtonSize.small:
        return AppDesignTokens.buttonSm;
      case SolarButtonSize.medium:
        return AppDesignTokens.buttonMd;
      case SolarButtonSize.large:
        return AppDesignTokens.buttonLg;
      case SolarButtonSize.extraLarge:
        return AppDesignTokens.buttonXl;
    }
  }

  /// Get button padding based on size
  EdgeInsetsGeometry _getButtonPadding() {
    switch (size) {
      case SolarButtonSize.small:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingMd, vertical: AppDesignTokens.spacingXs);
      case SolarButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingLg, vertical: AppDesignTokens.spacingSm);
      case SolarButtonSize.large:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXl, vertical: AppDesignTokens.spacingMd);
      case SolarButtonSize.extraLarge:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXxl, vertical: AppDesignTokens.spacingLg);
    }
  }

  /// Get text style based on size
  TextStyle _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);

    switch (size) {
      case SolarButtonSize.small:
        return theme.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w500);
      case SolarButtonSize.medium:
        return theme.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w500);
      case SolarButtonSize.large:
        return theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600);
      case SolarButtonSize.extraLarge:
        return theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);
    }
  }

  /// Get default border radius based on size
  double _getDefaultBorderRadius() {
    switch (size) {
      case SolarButtonSize.small:
        return AppDesignTokens.radiusSm;
      case SolarButtonSize.medium:
        return AppDesignTokens.radiusMd;
      case SolarButtonSize.large:
        return AppDesignTokens.radiusLg;
      case SolarButtonSize.extraLarge:
        return AppDesignTokens.radiusXl;
    }
  }

  /// Get icon spacing based on size
  double _getIconSpacing() {
    switch (size) {
      case SolarButtonSize.small:
        return AppDesignTokens.spacingXs;
      case SolarButtonSize.medium:
        return AppDesignTokens.spacingSm;
      case SolarButtonSize.large:
        return AppDesignTokens.spacingMd;
      case SolarButtonSize.extraLarge:
        return AppDesignTokens.spacingMd;
    }
  }

  /// Get loading indicator size based on button size
  double _getLoadingIndicatorSize() {
    switch (size) {
      case SolarButtonSize.small:
        return AppDesignTokens.iconSm;
      case SolarButtonSize.medium:
        return AppDesignTokens.iconMd;
      case SolarButtonSize.large:
        return AppDesignTokens.iconLg;
      case SolarButtonSize.extraLarge:
        return AppDesignTokens.iconXl;
    }
  }
}

/// Specialized Solar Button Variants

/// Primary Action Button
class SolarPrimaryButton extends StatelessWidget {
  const SolarPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = SolarButtonSize.medium,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final SolarButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SolarButton(
      onPressed: onPressed,
      variant: SolarButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      child: child,
    );
  }
}

/// Secondary Action Button
class SolarSecondaryButton extends StatelessWidget {
  const SolarSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = SolarButtonSize.medium,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final SolarButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SolarButton(
      onPressed: onPressed,
      variant: SolarButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      child: child,
    );
  }
}

/// Outlined Button
class SolarOutlinedButton extends StatelessWidget {
  const SolarOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = SolarButtonSize.medium,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final SolarButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SolarButton(
      onPressed: onPressed,
      variant: SolarButtonVariant.outlined,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      child: child,
    );
  }
}

/// Text Button
class SolarTextButton extends StatelessWidget {
  const SolarTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = SolarButtonSize.medium,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final SolarButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return SolarButton(
      onPressed: onPressed,
      variant: SolarButtonVariant.text,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      child: child,
    );
  }
}
