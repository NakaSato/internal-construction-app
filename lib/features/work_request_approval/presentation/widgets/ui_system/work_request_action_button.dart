import 'package:flutter/material.dart';

/// A reusable action button widget for work request operations
class WorkRequestActionButton extends StatelessWidget {
  const WorkRequestActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = WorkRequestActionButtonStyle.primary,
    this.size = WorkRequestActionButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final WorkRequestActionButtonStyle style;
  final WorkRequestActionButtonSize size;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final styleConfig = _getStyleConfig(colorScheme);
    final sizeConfig = _getSizeConfig();

    final effectiveOnPressed = isEnabled && !isLoading ? onPressed : null;

    Widget child = isLoading
        ? SizedBox(
            width: sizeConfig.loadingSize,
            height: sizeConfig.loadingSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                styleConfig.foregroundColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: sizeConfig.iconSize,
                  color: styleConfig.foregroundColor,
                ),
                SizedBox(width: sizeConfig.spacing),
              ],
              Text(
                label,
                style: TextStyle(
                  color: styleConfig.foregroundColor,
                  fontSize: sizeConfig.fontSize,
                  fontWeight: sizeConfig.fontWeight,
                ),
              ),
            ],
          );

    switch (style) {
      case WorkRequestActionButtonStyle.primary:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: styleConfig.backgroundColor,
            foregroundColor: styleConfig.foregroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: sizeConfig.horizontalPadding,
              vertical: sizeConfig.verticalPadding,
            ),
            minimumSize: Size(sizeConfig.minWidth, sizeConfig.minHeight),
          ),
          child: child,
        );

      case WorkRequestActionButtonStyle.secondary:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: styleConfig.foregroundColor,
            side: BorderSide(color: styleConfig.borderColor!),
            padding: EdgeInsets.symmetric(
              horizontal: sizeConfig.horizontalPadding,
              vertical: sizeConfig.verticalPadding,
            ),
            minimumSize: Size(sizeConfig.minWidth, sizeConfig.minHeight),
          ),
          child: child,
        );

      case WorkRequestActionButtonStyle.destructive:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: styleConfig.backgroundColor,
            foregroundColor: styleConfig.foregroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: sizeConfig.horizontalPadding,
              vertical: sizeConfig.verticalPadding,
            ),
            minimumSize: Size(sizeConfig.minWidth, sizeConfig.minHeight),
          ),
          child: child,
        );

      case WorkRequestActionButtonStyle.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: styleConfig.foregroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: sizeConfig.horizontalPadding,
              vertical: sizeConfig.verticalPadding,
            ),
            minimumSize: Size(sizeConfig.minWidth, sizeConfig.minHeight),
          ),
          child: child,
        );
    }
  }

  _ActionButtonStyleConfig _getStyleConfig(ColorScheme colorScheme) {
    switch (style) {
      case WorkRequestActionButtonStyle.primary:
        return _ActionButtonStyleConfig(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        );
      case WorkRequestActionButtonStyle.secondary:
        return _ActionButtonStyleConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
          borderColor: colorScheme.primary,
        );
      case WorkRequestActionButtonStyle.destructive:
        return _ActionButtonStyleConfig(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
        );
      case WorkRequestActionButtonStyle.text:
        return _ActionButtonStyleConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
        );
    }
  }

  _ActionButtonSizeConfig _getSizeConfig() {
    switch (size) {
      case WorkRequestActionButtonSize.small:
        return const _ActionButtonSizeConfig(
          horizontalPadding: 12,
          verticalPadding: 8,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          iconSize: 16,
          spacing: 4,
          minWidth: 64,
          minHeight: 32,
          loadingSize: 14,
        );
      case WorkRequestActionButtonSize.medium:
        return const _ActionButtonSizeConfig(
          horizontalPadding: 16,
          verticalPadding: 12,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          iconSize: 18,
          spacing: 6,
          minWidth: 80,
          minHeight: 40,
          loadingSize: 16,
        );
      case WorkRequestActionButtonSize.large:
        return const _ActionButtonSizeConfig(
          horizontalPadding: 20,
          verticalPadding: 16,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          iconSize: 20,
          spacing: 8,
          minWidth: 100,
          minHeight: 48,
          loadingSize: 18,
        );
    }
  }
}

enum WorkRequestActionButtonStyle { primary, secondary, destructive, text }

enum WorkRequestActionButtonSize { small, medium, large }

class _ActionButtonStyleConfig {
  const _ActionButtonStyleConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
}

class _ActionButtonSizeConfig {
  const _ActionButtonSizeConfig({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.fontWeight,
    required this.iconSize,
    required this.spacing,
    required this.minWidth,
    required this.minHeight,
    required this.loadingSize,
  });

  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;
  final double spacing;
  final double minWidth;
  final double minHeight;
  final double loadingSize;
}
