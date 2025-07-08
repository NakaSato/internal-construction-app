import 'package:flutter/material.dart';

/// A simplified bottom navigation bar that matches the design requirements.
///
/// This widget follows Material Design 3 principles and provides a clean,
/// consistent navigation experience across the solar project management app.
class CustomBottomBar extends StatelessWidget {
  /// Creates a [CustomBottomBar] with the specified configuration.
  ///
  /// The [currentIndex] and [onTap] parameters are required.
  /// Other parameters provide customization options for colors and behavior.
  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.margin,
    this.hasNotification = false,
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

  /// Whether to show notification indicator on profile tab
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selected = selectedItemColor ?? colorScheme.primary;
    final unselected = unselectedItemColor ?? colorScheme.onSurfaceVariant.withOpacity(0.7);

    return RepaintBoundary(
      child: Container(
        decoration: _buildContainerDecoration(),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildNavigationItems(context, selected, unselected),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the container decoration with shadow and border
  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -1), spreadRadius: 1),
      ],
      border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 0.5)),
    );
  }

  /// Builds the list of navigation items
  List<Widget> _buildNavigationItems(BuildContext context, Color selected, Color unselected) {
    // Navigation items configuration
    const navItems = [
      (Icons.home, Icons.home_outlined, 'Home'),
      (Icons.build, Icons.build_outlined, 'Works'),
      (Icons.approval, Icons.approval_outlined, 'Approvals'),
      (Icons.person, Icons.person_outline_rounded, 'Me'),
    ];

    return List.generate(navItems.length, (index) {
      final (filledIcon, outlinedIcon, label) = navItems[index];
      final isSelected = currentIndex == index;
      final icon = isSelected ? filledIcon : outlinedIcon;

      return _NavigationItem(
        icon: icon,
        label: label,
        isSelected: isSelected,
        selectedColor: selected,
        unselectedColor: unselected,
        onTap: () => onTap(index),
        hasNotification: hasNotification && index == 3, // Only show on 'Me' tab
      );
    });
  }
}

/// Individual navigation item widget for optimal performance.
///
/// This widget can be const when appropriate and participates in Flutter's
/// optimization pipeline as a separate widget class.
class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
    this.hasNotification = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: RepaintBoundary(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SelectionIndicator(isSelected: isSelected, selectedColor: selectedColor),
                _IconWithNotification(
                  icon: icon,
                  isSelected: isSelected,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  hasNotification: hasNotification,
                ),
                const SizedBox(height: 3),
                _NavigationLabel(
                  label: label,
                  isSelected: isSelected,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Selection indicator widget - can be const when not selected
class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected, required this.selectedColor});

  final bool isSelected;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSelected ? 10 : 0,
      height: 2,
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Icon with notification badge widget
class _IconWithNotification extends StatelessWidget {
  const _IconWithNotification({
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.hasNotification,
  });

  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          child: Icon(icon, color: isSelected ? selectedColor : unselectedColor, size: 20),
        ),
        if (hasNotification) const _NotificationBadge(),
      ],
    );
  }
}

/// Notification badge widget - const for better performance
class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -2,
      right: -4,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 1, offset: const Offset(0, 1))],
        ),
      ),
    );
  }
}

/// Navigation label widget
class _NavigationLabel extends StatelessWidget {
  const _NavigationLabel({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: isSelected ? selectedColor : unselectedColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}
