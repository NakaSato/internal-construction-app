library solar_ui_layout;

/// Solar UI System - Layout Components
///
/// This file contains layout components for the Solar Project Management app.
/// These components provide consistent page structures with solar theming.

import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// Solar Page Layout
///
/// A consistent page layout wrapper with optional header, sidebar, and footer.
class SolarPageLayout extends StatelessWidget {
  const SolarPageLayout({
    super.key,
    required this.body,
    this.header,
    this.sidebar,
    this.footer,
    this.backgroundColor,
    this.padding,
    this.sidebarWidth = 280.0,
    this.showSidebar = false,
    this.resizeToAvoidBottomInset,
  });

  /// Main page content
  final Widget body;

  /// Optional page header
  final Widget? header;

  /// Optional sidebar content
  final Widget? sidebar;

  /// Optional page footer
  final Widget? footer;

  /// Page background color
  final Color? backgroundColor;

  /// Content padding
  final EdgeInsetsGeometry? padding;

  /// Sidebar width
  final double sidebarWidth;

  /// Show sidebar
  final bool showSidebar;

  /// Resize to avoid bottom inset
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = Column(
      children: [
        if (header != null) header!,
        Expanded(
          child: Row(
            children: [
              if (showSidebar && sidebar != null) SizedBox(width: sidebarWidth, child: sidebar!),
              Expanded(
                child: Container(padding: padding ?? EdgeInsets.all(AppDesignTokens.spacingMd), child: body),
              ),
            ],
          ),
        ),
        if (footer != null) footer!,
      ],
    );

    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: content,
    );
  }
}

/// Solar Section
///
/// A content section with optional title and actions.
class SolarSection extends StatelessWidget {
  const SolarSection({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.actions,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.showDivider = false,
  });

  /// Section content
  final List<Widget> children;

  /// Section title
  final String? title;

  /// Section subtitle
  final String? subtitle;

  /// Section actions
  final List<Widget>? actions;

  /// Section padding
  final EdgeInsetsGeometry? padding;

  /// Section margin
  final EdgeInsetsGeometry? margin;

  /// Section background color
  final Color? backgroundColor;

  /// Section border radius
  final BorderRadius? borderRadius;

  /// Show bottom divider
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: AppDesignTokens.spacingLg),
      padding: padding ?? EdgeInsets.all(AppDesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: showDivider ? Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 1.0)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || actions != null) _buildSectionHeader(context),
          if (title != null || actions != null) SizedBox(height: AppDesignTokens.spacingMd),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(title!, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
              if (subtitle != null) ...[
                SizedBox(height: AppDesignTokens.spacingXs),
                Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
        if (actions != null) ...[
          SizedBox(width: AppDesignTokens.spacingMd),
          Row(mainAxisSize: MainAxisSize.min, children: actions!),
        ],
      ],
    );
  }
}

/// Solar Grid Layout
///
/// A responsive grid layout for cards and content.
class SolarGridLayout extends StatelessWidget {
  const SolarGridLayout({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.maxCrossAxisExtent = 320.0,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Widget> children;
  final int? crossAxisCount;
  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    Widget grid;

    if (crossAxisCount != null) {
      grid = GridView.count(
        crossAxisCount: crossAxisCount!,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        shrinkWrap: shrinkWrap,
        physics: physics,
        children: children,
      );
    } else {
      grid = GridView.extent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        shrinkWrap: shrinkWrap,
        physics: physics,
        children: children,
      );
    }

    if (padding != null) {
      grid = Padding(padding: padding!, child: grid);
    }

    return grid;
  }
}

/// Solar Responsive Layout
///
/// A responsive layout that adapts to screen size.
class SolarResponsiveLayout extends StatelessWidget {
  const SolarResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = 768.0,
    this.tabletBreakpoint = 1024.0,
  });

  /// Mobile layout
  final Widget mobile;

  /// Tablet layout (optional, falls back to mobile)
  final Widget? tablet;

  /// Desktop layout (optional, falls back to tablet or mobile)
  final Widget? desktop;

  /// Mobile breakpoint
  final double mobileBreakpoint;

  /// Tablet breakpoint
  final double tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Solar Split Layout
///
/// A layout that splits content into main and aside sections.
class SolarSplitLayout extends StatelessWidget {
  const SolarSplitLayout({
    super.key,
    required this.main,
    required this.aside,
    this.mainFlex = 2,
    this.asideFlex = 1,
    this.direction = Axis.horizontal,
    this.spacing = 16.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Main content
  final Widget main;

  /// Aside content
  final Widget aside;

  /// Main content flex
  final int mainFlex;

  /// Aside content flex
  final int asideFlex;

  /// Layout direction
  final Axis direction;

  /// Spacing between sections
  final double spacing;

  /// Cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(flex: mainFlex, child: main),
          SizedBox(width: spacing),
          Expanded(flex: asideFlex, child: aside),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(flex: mainFlex, child: main),
          SizedBox(height: spacing),
          Expanded(flex: asideFlex, child: aside),
        ],
      );
    }
  }
}

/// Solar Stack Layout
///
/// A layout for stacking widgets with consistent spacing.
class SolarStackLayout extends StatelessWidget {
  const SolarStackLayout({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  /// Child widgets
  final List<Widget> children;

  /// Spacing between children
  final double spacing;

  /// Stack direction
  final Axis direction;

  /// Main axis alignment
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;

  /// Main axis size
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        if (direction == Axis.vertical) {
          spacedChildren.add(SizedBox(height: spacing));
        } else {
          spacedChildren.add(SizedBox(width: spacing));
        }
      }
    }

    if (direction == Axis.vertical) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: spacedChildren,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: spacedChildren,
      );
    }
  }
}

/// Solar Container
///
/// A themed container with consistent styling.
class SolarContainer extends StatelessWidget {
  const SolarContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.border,
    this.shadow,
    this.gradient,
    this.clipBehavior = Clip.none,
  });

  /// Container content
  final Widget child;

  /// Container padding
  final EdgeInsetsGeometry? padding;

  /// Container margin
  final EdgeInsetsGeometry? margin;

  /// Container width
  final double? width;

  /// Container height
  final double? height;

  /// Container color
  final Color? color;

  /// Container border radius
  final BorderRadius? borderRadius;

  /// Container border
  final Border? border;

  /// Container shadow
  final List<BoxShadow>? shadow;

  /// Container gradient
  final Gradient? gradient;

  /// Clip behavior
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? colorScheme.surface) : null,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(AppDesignTokens.radiusMd),
        border: border,
        boxShadow: shadow,
      ),
      child: child,
    );

    return container;
  }
}

/// Solar Spacer
///
/// Consistent spacing widgets.
class SolarSpacer {
  const SolarSpacer._();

  /// Extra small spacer
  static Widget get xs => SizedBox(width: AppDesignTokens.spacingXs, height: AppDesignTokens.spacingXs);

  /// Small spacer
  static Widget get sm => SizedBox(width: AppDesignTokens.spacingSm, height: AppDesignTokens.spacingSm);

  /// Medium spacer
  static Widget get md => SizedBox(width: AppDesignTokens.spacingMd, height: AppDesignTokens.spacingMd);

  /// Large spacer
  static Widget get lg => SizedBox(width: AppDesignTokens.spacingLg, height: AppDesignTokens.spacingLg);

  /// Extra large spacer
  static Widget get xl => SizedBox(width: AppDesignTokens.spacingXl, height: AppDesignTokens.spacingXl);

  /// Custom spacer
  static Widget custom(double size) => SizedBox(width: size, height: size);

  /// Horizontal spacer
  static Widget horizontal(double width) => SizedBox(width: width);

  /// Vertical spacer
  static Widget vertical(double height) => SizedBox(height: height);
}
