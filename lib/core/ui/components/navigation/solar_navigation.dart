library solar_ui_navigation;

/// Solar UI System - Navigation Components
///
/// This file contains navigation components for the Solar Project Management app.
/// These components provide consistent navigation patterns with solar theming.

import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// Solar Bottom Navigation Bar
///
/// A themed bottom navigation bar for primary app navigation.
class SolarBottomNavigationBar extends StatelessWidget {
  const SolarBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.type = BottomNavigationBarType.shifting,
    this.backgroundColor,
    this.elevation,
  });

  final List<SolarBottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final BottomNavigationBarType type;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BottomNavigationBar(
      items: items.map((item) => item.toBottomNavigationBarItem()).toList(),
      currentIndex: currentIndex,
      onTap: onTap,
      type: type,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      elevation: elevation ?? AppDesignTokens.elevationSm,
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400),
      selectedIconTheme: IconThemeData(size: AppDesignTokens.iconLg),
      unselectedIconTheme: IconThemeData(size: AppDesignTokens.iconMd),
    );
  }
}

/// Solar Bottom Navigation Bar Item
class SolarBottomNavigationBarItem {
  const SolarBottomNavigationBarItem({required this.icon, required this.label, this.activeIcon, this.badge});

  final Widget icon;
  final Widget? activeIcon;
  final String label;
  final Widget? badge;

  BottomNavigationBarItem toBottomNavigationBarItem() {
    return BottomNavigationBarItem(
      icon: badge != null
          ? Badge.count(
              count: 0, // Will be handled by the badge widget
              child: icon,
            )
          : icon,
      activeIcon: activeIcon ?? icon,
      label: label,
    );
  }
}

/// Solar Navigation Rail
///
/// A themed navigation rail for desktop/tablet layouts.
class SolarNavigationRail extends StatelessWidget {
  const SolarNavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
    this.backgroundColor,
    this.leading,
    this.trailing,
    this.minWidth,
    this.minExtendedWidth,
  });

  final List<SolarNavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? trailing;
  final double? minWidth;
  final double? minExtendedWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationRail(
      destinations: destinations.map((dest) => dest.toNavigationRailDestination()).toList(),
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      selectedIconTheme: IconThemeData(color: colorScheme.primary, size: AppDesignTokens.iconLg),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: AppDesignTokens.iconMd),
      selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
      leading: leading,
      trailing: trailing,
      minWidth: minWidth ?? 80.0,
      minExtendedWidth: minExtendedWidth ?? 256.0,
      labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
    );
  }
}

/// Solar Navigation Rail Destination
class SolarNavigationRailDestination {
  const SolarNavigationRailDestination({required this.icon, required this.label, this.selectedIcon, this.badge});

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final Widget? badge;

  NavigationRailDestination toNavigationRailDestination() {
    return NavigationRailDestination(
      icon: badge != null
          ? Badge.count(
              count: 0, // Will be handled by the badge widget
              child: icon,
            )
          : icon,
      selectedIcon: selectedIcon,
      label: Text(label),
    );
  }
}

/// Solar Tab Bar
///
/// A themed tab bar for secondary navigation.
class SolarTabBar extends StatelessWidget implements PreferredSizeWidget {
  const SolarTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.backgroundColor,
    this.indicatorWeight = 3.0,
    this.labelPadding,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? backgroundColor;
  final double indicatorWeight;
  final EdgeInsetsGeometry? labelPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 1.0)),
      ),
      child: TabBar(
        tabs: tabs,
        controller: controller,
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        labelColor: labelColor ?? colorScheme.primary,
        unselectedLabelColor: unselectedLabelColor ?? colorScheme.onSurfaceVariant,
        indicatorWeight: indicatorWeight,
        labelPadding: labelPadding ?? EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingMd),
        labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w400),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.primary.withOpacity(0.04);
          }
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withOpacity(0.12);
          }
          return null;
        }),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Solar App Bar
///
/// A themed app bar with solar styling.
class SolarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SolarAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.bottom,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? AppDesignTokens.elevationNone,
      centerTitle: centerTitle,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
        color: foregroundColor ?? colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: foregroundColor ?? colorScheme.onSurface, size: AppDesignTokens.iconLg),
      actionsIconTheme: IconThemeData(color: foregroundColor ?? colorScheme.onSurface, size: AppDesignTokens.iconLg),
      surfaceTintColor: colorScheme.surfaceTint,
      scrolledUnderElevation: AppDesignTokens.elevationXs,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// Solar Breadcrumb
///
/// A navigation breadcrumb component for showing navigation hierarchy.
class SolarBreadcrumb extends StatelessWidget {
  const SolarBreadcrumb({super.key, required this.items, this.separator = '/', this.onTap});

  final List<SolarBreadcrumbItem> items;
  final String separator;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          GestureDetector(
            onTap: () => onTap?.call(i),
            child: Text(
              items[i].label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: i == items.length - 1 ? colorScheme.onSurface : colorScheme.primary,
                fontWeight: i == items.length - 1 ? FontWeight.w600 : FontWeight.w400,
                decoration: i == items.length - 1 ? null : TextDecoration.underline,
              ),
            ),
          ),
          if (i < items.length - 1) ...[
            SizedBox(width: AppDesignTokens.spacingXs),
            Text(separator, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            SizedBox(width: AppDesignTokens.spacingXs),
          ],
        ],
      ],
    );
  }
}

/// Solar Breadcrumb Item
class SolarBreadcrumbItem {
  const SolarBreadcrumbItem({required this.label, this.route});

  final String label;
  final String? route;
}

/// Solar Drawer
///
/// A themed navigation drawer for app navigation.
class SolarDrawer extends StatelessWidget {
  const SolarDrawer({
    super.key,
    this.header,
    required this.items,
    this.currentRoute,
    this.onItemTap,
    this.backgroundColor,
    this.elevation,
  });

  final Widget? header;
  final List<SolarDrawerItem> items;
  final String? currentRoute;
  final ValueChanged<SolarDrawerItem>? onItemTap;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      elevation: elevation ?? AppDesignTokens.elevationMd,
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: items.map((item) => _buildDrawerItem(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, SolarDrawerItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentRoute == item.route;

    if (item.isDivider) {
      return Divider(color: colorScheme.outlineVariant, height: 1);
    }

    return ListTile(
      leading: item.icon,
      title: Text(item.title),
      trailing: item.trailing,
      selected: isSelected,
      selectedColor: colorScheme.primary,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
      onTap: () => onItemTap?.call(item),
      titleTextStyle: theme.textTheme.bodyLarge?.copyWith(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd)),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacingMd,
        vertical: AppDesignTokens.spacingXs,
      ),
    );
  }
}

/// Solar Drawer Item
class SolarDrawerItem {
  const SolarDrawerItem({required this.title, this.icon, this.trailing, this.route, this.isDivider = false});

  final String title;
  final Widget? icon;
  final Widget? trailing;
  final String? route;
  final bool isDivider;

  /// Create a divider item
  const SolarDrawerItem.divider() : title = '', icon = null, trailing = null, route = null, isDivider = true;
}
