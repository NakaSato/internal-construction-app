library solar_ui_chips;

/// Solar UI System - Chip & Badge Components
///
/// This file contains chip and badge components for the Solar Project Management app.
/// These components provide status indicators and selectable options with solar theming.

import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

// Import enums from card component to avoid duplication
enum ProjectStatus { active, pending, completed, cancelled, onHold }

enum EnergyLevel { high, medium, low, none, optimal }

/// Solar Chip Variant Types
enum SolarChipVariant { filled, outlined, elevated, input, filter, action }

/// Solar Chip Size Options
enum SolarChipSize { small, medium, large }

/// Solar Chip Base Widget
///
/// A flexible chip component with multiple variants and solar theming.
class SolarChip extends StatelessWidget {
  const SolarChip({
    super.key,
    required this.label,
    this.avatar,
    this.deleteIcon,
    this.variant = SolarChipVariant.filled,
    this.size = SolarChipSize.medium,
    this.isSelected = false,
    this.onTap,
    this.onDeleted,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.tooltip,
  });

  /// Chip label
  final String label;

  /// Leading avatar or icon
  final Widget? avatar;

  /// Delete icon
  final Widget? deleteIcon;

  /// Chip variant
  final SolarChipVariant variant;

  /// Chip size
  final SolarChipSize size;

  /// Selected state
  final bool isSelected;

  /// Tap callback
  final VoidCallback? onTap;

  /// Delete callback
  final VoidCallback? onDeleted;

  /// Custom text color
  final Color? color;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom border color
  final Color? borderColor;

  /// Tooltip text
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget chip = _buildChipByVariant(context);

    if (tooltip != null) {
      chip = Tooltip(message: tooltip!, child: chip);
    }

    return chip;
  }

  Widget _buildChipByVariant(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case SolarChipVariant.filled:
        return Chip(
          label: Text(label),
          avatar: avatar,
          deleteIcon: deleteIcon,
          onDeleted: onDeleted,
          backgroundColor: backgroundColor ?? (isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh),
          labelStyle: _getLabelStyle(context),
          padding: _getPadding(),
          shape: _getShape(context),
        );

      case SolarChipVariant.outlined:
        return Chip(
          label: Text(label),
          avatar: avatar,
          deleteIcon: deleteIcon,
          onDeleted: onDeleted,
          backgroundColor: backgroundColor ?? Colors.transparent,
          side: BorderSide(
            color: borderColor ?? (isSelected ? colorScheme.primary : colorScheme.outline),
            width: isSelected ? 2.0 : 1.0,
          ),
          labelStyle: _getLabelStyle(context),
          padding: _getPadding(),
          shape: _getShape(context),
        );

      case SolarChipVariant.elevated:
        return Chip(
          label: Text(label),
          avatar: avatar,
          deleteIcon: deleteIcon,
          onDeleted: onDeleted,
          backgroundColor: backgroundColor ?? colorScheme.surface,
          elevation: AppDesignTokens.elevationSm,
          shadowColor: colorScheme.shadow,
          labelStyle: _getLabelStyle(context),
          padding: _getPadding(),
          shape: _getShape(context),
        );

      case SolarChipVariant.input:
        return InputChip(
          label: Text(label),
          avatar: avatar,
          deleteIcon: deleteIcon,
          onDeleted: onDeleted,
          onPressed: onTap,
          selected: isSelected,
          backgroundColor: backgroundColor,
          selectedColor: backgroundColor ?? colorScheme.secondaryContainer,
          labelStyle: _getLabelStyle(context),
          padding: _getPadding(),
          shape: _getShape(context),
        );

      case SolarChipVariant.filter:
        return FilterChip(
          label: Text(label),
          avatar: avatar,
          onSelected: onTap != null ? (_) => onTap!() : null,
          selected: isSelected,
          backgroundColor: backgroundColor,
          selectedColor: backgroundColor ?? colorScheme.secondaryContainer,
          labelStyle: _getLabelStyle(context),
          padding: _getPadding(),
          shape: _getShape(context),
        );

      case SolarChipVariant.action:
        return ActionChip(
          label: Text(label),
          avatar: avatar,
          onPressed: onTap,
          backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHigh,
          labelStyle: _getLabelStyle(context),
          padding: _getPadding(),
          shape: _getShape(context),
        );
    }
  }

  TextStyle _getLabelStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color textColor = color ?? colorScheme.onSurface;

    if (isSelected && variant == SolarChipVariant.filled) {
      textColor = colorScheme.onPrimary;
    }

    switch (size) {
      case SolarChipSize.small:
        return theme.textTheme.labelSmall!.copyWith(color: textColor, fontWeight: FontWeight.w500);
      case SolarChipSize.medium:
        return theme.textTheme.labelMedium!.copyWith(color: textColor, fontWeight: FontWeight.w500);
      case SolarChipSize.large:
        return theme.textTheme.labelLarge!.copyWith(color: textColor, fontWeight: FontWeight.w500);
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case SolarChipSize.small:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXs, vertical: AppDesignTokens.spacingXxs);
      case SolarChipSize.medium:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingSm, vertical: AppDesignTokens.spacingXs);
      case SolarChipSize.large:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingMd, vertical: AppDesignTokens.spacingSm);
    }
  }

  OutlinedBorder _getShape(BuildContext context) {
    double radius;
    switch (size) {
      case SolarChipSize.small:
        radius = AppDesignTokens.radiusSm;
        break;
      case SolarChipSize.medium:
        radius = AppDesignTokens.radiusMd;
        break;
      case SolarChipSize.large:
        radius = AppDesignTokens.radiusLg;
        break;
    }

    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
}

/// Solar Status Chip - Specialized chip for status display
class SolarStatusChip extends StatelessWidget {
  const SolarStatusChip({
    super.key,
    required this.status,
    required this.label,
    this.size = SolarChipSize.medium,
    this.onTap,
  });

  final ProjectStatus status;
  final String label;
  final SolarChipSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor) = _getStatusColors();

    return SolarChip(
      label: label,
      variant: SolarChipVariant.filled,
      size: size,
      backgroundColor: backgroundColor,
      color: textColor,
      onTap: onTap,
    );
  }

  (Color, Color) _getStatusColors() {
    switch (status) {
      case ProjectStatus.active:
        return (AppColorTokens.statusActive.withOpacity(0.1), AppColorTokens.statusActive);
      case ProjectStatus.pending:
        return (AppColorTokens.statusPending.withOpacity(0.1), AppColorTokens.statusPending);
      case ProjectStatus.completed:
        return (AppColorTokens.statusCompleted.withOpacity(0.1), AppColorTokens.statusCompleted);
      case ProjectStatus.cancelled:
        return (AppColorTokens.statusCancelled.withOpacity(0.1), AppColorTokens.statusCancelled);
      case ProjectStatus.onHold:
        return (AppColorTokens.statusOnHold.withOpacity(0.1), AppColorTokens.statusOnHold);
    }
  }
}

/// Solar Energy Chip - Specialized chip for energy level display
class SolarEnergyChip extends StatelessWidget {
  const SolarEnergyChip({
    super.key,
    required this.energyLevel,
    required this.label,
    this.size = SolarChipSize.medium,
    this.onTap,
  });

  final EnergyLevel energyLevel;
  final String label;
  final SolarChipSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor) = _getEnergyColors();

    return SolarChip(
      label: label,
      variant: SolarChipVariant.filled,
      size: size,
      backgroundColor: backgroundColor,
      color: textColor,
      onTap: onTap,
    );
  }

  (Color, Color) _getEnergyColors() {
    switch (energyLevel) {
      case EnergyLevel.high:
        return (AppColorTokens.energyHigh.withOpacity(0.1), AppColorTokens.energyHigh);
      case EnergyLevel.medium:
        return (AppColorTokens.energyMedium.withOpacity(0.1), AppColorTokens.energyMedium);
      case EnergyLevel.low:
        return (AppColorTokens.energyLow.withOpacity(0.1), AppColorTokens.energyLow);
      case EnergyLevel.none:
        return (AppColorTokens.energyNone.withOpacity(0.1), AppColorTokens.energyNone);
      case EnergyLevel.optimal:
        return (AppColorTokens.energyOptimal.withOpacity(0.1), AppColorTokens.energyOptimal);
    }
  }
}

/// Solar Badge Widget
///
/// A notification badge component with solar theming.
class SolarBadge extends StatelessWidget {
  const SolarBadge({
    super.key,
    required this.child,
    this.label,
    this.value,
    this.color,
    this.backgroundColor,
    this.textColor,
    this.showZero = false,
    this.offset,
    this.isLarge = false,
  });

  /// Widget to badge
  final Widget child;

  /// Badge label text
  final String? label;

  /// Badge numeric value
  final int? value;

  /// Badge color
  final Color? color;

  /// Badge background color
  final Color? backgroundColor;

  /// Badge text color
  final Color? textColor;

  /// Show badge when value is zero
  final bool showZero;

  /// Badge position offset
  final Offset? offset;

  /// Large badge style
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final shouldShow = _shouldShowBadge();

    if (!shouldShow) {
      return child;
    }

    final badgeLabel = _getBadgeLabel();

    return Badge(
      label: badgeLabel != null ? Text(badgeLabel) : null,
      backgroundColor: backgroundColor ?? colorScheme.error,
      textColor: textColor ?? colorScheme.onError,
      offset: offset,
      isLabelVisible: shouldShow,
      textStyle: isLarge
          ? theme.textTheme.labelMedium?.copyWith(color: textColor ?? colorScheme.onError, fontWeight: FontWeight.w600)
          : theme.textTheme.labelSmall?.copyWith(color: textColor ?? colorScheme.onError, fontWeight: FontWeight.w600),
      child: child,
    );
  }

  bool _shouldShowBadge() {
    if (label != null && label!.isNotEmpty) return true;
    if (value != null) {
      return showZero || value! > 0;
    }
    return false;
  }

  String? _getBadgeLabel() {
    if (label != null) return label;
    if (value != null) {
      if (value! > 99) return '99+';
      return value.toString();
    }
    return null;
  }
}

/// Solar Notification Badge - Specialized badge for notifications
class SolarNotificationBadge extends StatelessWidget {
  const SolarNotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.showZero = false,
    this.isLarge = false,
  });

  final Widget child;
  final int count;
  final bool showZero;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return SolarBadge(
      value: count,
      showZero: showZero,
      isLarge: isLarge,
      backgroundColor: AppColorTokens.error600,
      child: child,
    );
  }
}

/// Solar Priority Badge - Specialized badge for priority indicators
class SolarPriorityBadge extends StatelessWidget {
  const SolarPriorityBadge({super.key, required this.child, required this.priority, this.isLarge = false});

  final Widget child;
  final Priority priority;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, label) = _getPriorityData();

    return SolarBadge(
      label: label,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      isLarge: isLarge,
      child: child,
    );
  }

  (Color, String) _getPriorityData() {
    switch (priority) {
      case Priority.high:
        return (AppColorTokens.error600, 'H');
      case Priority.medium:
        return (AppColorTokens.warning500, 'M');
      case Priority.low:
        return (AppColorTokens.success600, 'L');
      case Priority.critical:
        return (AppColorTokens.error800, '!');
    }
  }
}

/// Priority Enum
enum Priority { high, medium, low, critical }
