import 'package:flutter/material.dart';

/// A reusable card container widget for work request items
class WorkRequestCardContainer extends StatelessWidget {
  const WorkRequestCardContainer({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 1,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
    this.showRipple = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool showRipple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: margin,
      child: Material(
        elevation: elevation,
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: showRipple ? null : Colors.transparent,
                highlightColor: showRipple ? null : Colors.transparent,
                child: Padding(padding: padding, child: child),
              )
            : Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A reusable header widget for work request cards
class WorkRequestCardHeader extends StatelessWidget {
  const WorkRequestCardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 1,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final int titleMaxLines;
  final int subtitleMaxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

/// A reusable content section widget for work request cards
class WorkRequestCardContent extends StatelessWidget {
  const WorkRequestCardContent({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .expand((widget) => [widget, SizedBox(height: spacing)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}

/// A reusable info row widget for displaying key-value pairs
class WorkRequestInfoRow extends StatelessWidget {
  const WorkRequestInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.spacing = 8,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: spacing),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// A reusable footer widget for work request cards with actions
class WorkRequestCardFooter extends StatelessWidget {
  const WorkRequestCardFooter({
    super.key,
    required this.actions,
    this.alignment = MainAxisAlignment.end,
    this.spacing = 8,
  });

  final List<Widget> actions;
  final MainAxisAlignment alignment;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: actions
          .expand((widget) => [widget, SizedBox(width: spacing)])
          .take(actions.length * 2 - 1)
          .toList(),
    );
  }
}
