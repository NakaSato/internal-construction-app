import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../theme/solar_app_theme.dart';

class CustomBottomBar extends StatelessWidget {
  /// Creates a CustomBottomBar
  const CustomBottomBar({
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
    return Container(
      margin: margin ?? const EdgeInsets.all(SolarSpacing.sm),
      decoration: SolarDecorations.createCardDecoration(
        color: backgroundColor ?? context.colorScheme.surface,
        elevation: 2,
        borderRadius: SolarBorderRadius.xl,
      ),
      child: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: selectedItemColor ?? context.colorScheme.primary,
        unselectedItemColor: unselectedItemColor ?? context.colorScheme.onSurfaceVariant,
        margin: const EdgeInsets.symmetric(horizontal: SolarSpacing.sm, vertical: SolarSpacing.sm),
        items: [
          /// Dashboard
          SalomonBottomBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            title: const Text('Home'),
          ),

          /// Calendar
          SalomonBottomBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            title: const Text('Calendar'),
          ),

          /// Work Request Approvals
          SalomonBottomBarItem(
            icon: const Icon(Icons.approval_outlined),
            activeIcon: const Icon(Icons.approval),
            title: const Text('Approvals'),
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
