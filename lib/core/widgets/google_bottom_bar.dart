import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

/// A custom bottom navigation bar using Salomon Bottom Bar with Google-style design
class GoogleBottomBar extends StatelessWidget {
  /// Creates a GoogleBottomBar
  const GoogleBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.margin,
  });

  /// The index of the currently selected item
  final int currentIndex;

  /// Called when a navigation item is tapped
  final ValueChanged<int> onTap;

  /// Background color of the bottom bar
  final Color? backgroundColor;

  /// Color of the selected item
  final Color? selectedItemColor;

  /// Color of unselected items
  final Color? unselectedItemColor;

  /// Margin around the bottom bar
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: selectedItemColor ?? theme.colorScheme.primary,
        unselectedItemColor:
            unselectedItemColor ?? theme.colorScheme.onSurfaceVariant,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        items: [
          /// Dashboard
          SalomonBottomBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            title: const Text('Home'),
          ),

          /// Featured Partners
          SalomonBottomBarItem(
            icon: const Icon(Icons.star_outline),
            activeIcon: const Icon(Icons.star),
            title: const Text('Featured'),
          ),

          /// Calendar
          SalomonBottomBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            title: const Text('Calendar'),
          ),

          /// Location
          SalomonBottomBarItem(
            icon: const Icon(Icons.location_on_outlined),
            activeIcon: const Icon(Icons.location_on),
            title: const Text('Location'),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            title: const Text('Profile'),
          ),
        ],
      ),
    );
  }
}
