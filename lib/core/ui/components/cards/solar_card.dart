library solar_ui_cards;

/// Solar UI System - Card Components
///
/// This file contains all card components for the Solar Project Management app.
/// These components provide consistent containers with solar-specific styling.

import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';
import '../chips/solar_chip.dart' show ProjectStatus, EnergyLevel;

/// Solar Card Variant Types
enum SolarCardVariant { elevated, outlined, filled, surface, glass }

/// Solar Card Size Options
enum SolarCardSize { small, medium, large, extraLarge }

/// Solar Card Base Widget
///
/// A flexible card component that supports multiple variants, sizes, and styles.
/// Follows Material Design 3 guidelines with solar-specific theming.
class SolarCard extends StatelessWidget {
  const SolarCard({
    super.key,
    required this.child,
    this.variant = SolarCardVariant.elevated,
    this.size = SolarCardSize.medium,
    this.onTap,
    this.margin,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.color,
    this.borderColor,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Card content
  final Widget child;

  /// Card visual variant
  final SolarCardVariant variant;

  /// Card size preset
  final SolarCardSize size;

  /// Card tap callback
  final VoidCallback? onTap;

  /// Card margin
  final EdgeInsetsGeometry? margin;

  /// Card padding
  final EdgeInsetsGeometry? padding;

  /// Custom border radius
  final BorderRadius? borderRadius;

  /// Custom elevation
  final double? elevation;

  /// Custom background color
  final Color? color;

  /// Custom border color
  final Color? borderColor;

  /// Card width
  final double? width;

  /// Card height
  final double? height;

  /// Clip behavior
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? _getDefaultBorderRadius();
    final effectivePadding = padding ?? _getDefaultPadding();
    final effectiveMargin = margin ?? _getDefaultMargin();

    Widget cardWidget = Container(
      width: width,
      height: height,
      decoration: _getDecoration(context),
      clipBehavior: clipBehavior,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: Padding(padding: effectivePadding, child: child),
        ),
      ),
    );

    if (effectiveMargin != EdgeInsets.zero) {
      cardWidget = Padding(padding: effectiveMargin, child: cardWidget);
    }

    return cardWidget;
  }

  /// Get card decoration based on variant
  BoxDecoration _getDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBorderRadius = borderRadius ?? _getDefaultBorderRadius();
    final effectiveColor = color ?? _getDefaultColor(context);
    final effectiveElevation = elevation ?? _getDefaultElevation();

    switch (variant) {
      case SolarCardVariant.elevated:
        return BoxDecoration(
          color: effectiveColor,
          borderRadius: effectiveBorderRadius,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: effectiveElevation * 2,
              offset: Offset(0, effectiveElevation / 2),
            ),
          ],
        );

      case SolarCardVariant.outlined:
        return BoxDecoration(
          color: effectiveColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(color: borderColor ?? colorScheme.outline, width: 1.0),
        );

      case SolarCardVariant.filled:
        return BoxDecoration(color: effectiveColor, borderRadius: effectiveBorderRadius);

      case SolarCardVariant.surface:
        return BoxDecoration(
          color: colorScheme.surface,
          borderRadius: effectiveBorderRadius,
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
        );

      case SolarCardVariant.glass:
        return BoxDecoration(
          color: effectiveColor.withOpacity(0.8),
          borderRadius: effectiveBorderRadius,
          border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 1.0),
          boxShadow: [
            BoxShadow(color: colorScheme.shadow.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        );
    }
  }

  /// Get default border radius based on size
  BorderRadius _getDefaultBorderRadius() {
    switch (size) {
      case SolarCardSize.small:
        return BorderRadius.circular(AppDesignTokens.radiusSm);
      case SolarCardSize.medium:
        return BorderRadius.circular(AppDesignTokens.radiusMd);
      case SolarCardSize.large:
        return BorderRadius.circular(AppDesignTokens.radiusLg);
      case SolarCardSize.extraLarge:
        return BorderRadius.circular(AppDesignTokens.radiusXl);
    }
  }

  /// Get default padding based on size
  EdgeInsetsGeometry _getDefaultPadding() {
    switch (size) {
      case SolarCardSize.small:
        return EdgeInsets.all(AppDesignTokens.spacingSm);
      case SolarCardSize.medium:
        return EdgeInsets.all(AppDesignTokens.spacingMd);
      case SolarCardSize.large:
        return EdgeInsets.all(AppDesignTokens.spacingLg);
      case SolarCardSize.extraLarge:
        return EdgeInsets.all(AppDesignTokens.spacingXl);
    }
  }

  /// Get default margin based on size
  EdgeInsetsGeometry _getDefaultMargin() {
    switch (size) {
      case SolarCardSize.small:
        return EdgeInsets.all(AppDesignTokens.spacingXs);
      case SolarCardSize.medium:
        return EdgeInsets.all(AppDesignTokens.spacingSm);
      case SolarCardSize.large:
        return EdgeInsets.all(AppDesignTokens.spacingMd);
      case SolarCardSize.extraLarge:
        return EdgeInsets.all(AppDesignTokens.spacingLg);
    }
  }

  /// Get default color based on variant
  Color _getDefaultColor(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case SolarCardVariant.elevated:
      case SolarCardVariant.outlined:
      case SolarCardVariant.surface:
        return colorScheme.surface;
      case SolarCardVariant.filled:
        return colorScheme.surfaceContainerLow;
      case SolarCardVariant.glass:
        return colorScheme.surface;
    }
  }

  /// Get default elevation based on variant and size
  double _getDefaultElevation() {
    if (variant != SolarCardVariant.elevated) return 0.0;

    switch (size) {
      case SolarCardSize.small:
        return AppDesignTokens.elevationXs;
      case SolarCardSize.medium:
        return AppDesignTokens.elevationSm;
      case SolarCardSize.large:
        return AppDesignTokens.elevationMd;
      case SolarCardSize.extraLarge:
        return AppDesignTokens.elevationLg;
    }
  }
}

/// Specialized Solar Card Variants

/// Project Card - Optimized for project information display
class SolarProjectCard extends StatelessWidget {
  const SolarProjectCard({
    super.key,
    required this.child,
    this.onTap,
    this.isActive = false,
    this.size = SolarCardSize.medium,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool isActive;
  final SolarCardSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SolarCard(
      onTap: onTap,
      variant: SolarCardVariant.elevated,
      size: size,
      borderColor: isActive ? colorScheme.primary : null,
      child: child,
    );
  }
}

/// Energy Card - Optimized for energy metrics display
class SolarEnergyCard extends StatelessWidget {
  const SolarEnergyCard({
    super.key,
    required this.child,
    this.onTap,
    this.energyLevel = EnergyLevel.medium,
    this.size = SolarCardSize.medium,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EnergyLevel energyLevel;
  final SolarCardSize size;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (energyLevel) {
      case EnergyLevel.high:
        borderColor = AppColorTokens.energyHigh;
        break;
      case EnergyLevel.medium:
        borderColor = AppColorTokens.energyMedium;
        break;
      case EnergyLevel.low:
        borderColor = AppColorTokens.energyLow;
        break;
      case EnergyLevel.none:
        borderColor = AppColorTokens.energyNone;
        break;
      case EnergyLevel.optimal:
        borderColor = AppColorTokens.energyOptimal;
        break;
    }

    return SolarCard(
      onTap: onTap,
      variant: SolarCardVariant.outlined,
      size: size,
      borderColor: borderColor,
      child: child,
    );
  }
}

/// Status Card - Optimized for status information display
class SolarStatusCard extends StatelessWidget {
  const SolarStatusCard({
    super.key,
    required this.child,
    this.onTap,
    this.status = ProjectStatus.active,
    this.size = SolarCardSize.medium,
  });

  final Widget child;
  final VoidCallback? onTap;
  final ProjectStatus status;
  final SolarCardSize size;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (status) {
      case ProjectStatus.active:
        borderColor = AppColorTokens.statusActive;
        break;
      case ProjectStatus.pending:
        borderColor = AppColorTokens.statusPending;
        break;
      case ProjectStatus.completed:
        borderColor = AppColorTokens.statusCompleted;
        break;
      case ProjectStatus.cancelled:
        borderColor = AppColorTokens.statusCancelled;
        break;
      case ProjectStatus.onHold:
        borderColor = AppColorTokens.statusOnHold;
        break;
    }

    return SolarCard(
      onTap: onTap,
      variant: SolarCardVariant.outlined,
      size: size,
      borderColor: borderColor,
      child: child,
    );
  }
}

/// Glass Card - Semi-transparent card for overlays
class SolarGlassCard extends StatelessWidget {
  const SolarGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.size = SolarCardSize.medium,
    this.opacity = 0.8,
  });

  final Widget child;
  final VoidCallback? onTap;
  final SolarCardSize size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SolarCard(onTap: onTap, variant: SolarCardVariant.glass, size: size, child: child);
  }
}

/// Card Grid - Helper widget for displaying cards in a responsive grid
class SolarCardGrid extends StatelessWidget {
  const SolarCardGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.maxCrossAxisExtent = 320.0,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  final List<Widget> children;
  final int? crossAxisCount;
  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget grid;

    if (crossAxisCount != null) {
      grid = GridView.count(
        crossAxisCount: crossAxisCount!,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        children: children,
      );
    } else {
      grid = GridView.extent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        children: children,
      );
    }

    if (padding != null) {
      grid = Padding(padding: padding!, child: grid);
    }

    return grid;
  }
}
