import 'package:flutter/material.dart';

/// A simplified bottom navigation bar that matches the design in the mockup
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

  /// Whether to show notification indicator on profile
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selected = selectedItemColor ?? colorScheme.primary;
    final unselected = unselectedItemColor ?? colorScheme.onSurfaceVariant.withOpacity(0.7);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -1), spreadRadius: 1),
        ],
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: currentIndex == 0 ? Icons.home : Icons.home_outlined,
                label: 'Home',
                isSelected: currentIndex == 0,
                selectedColor: selected,
                unselectedColor: unselected,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                context: context,
                icon: currentIndex == 1 ? Icons.build : Icons.build_outlined,
                label: 'Works',
                isSelected: currentIndex == 1,
                selectedColor: selected,
                unselectedColor: unselected,
                onTap: () => onTap(1),
              ),
              _buildNavItem(
                context: context,
                icon: currentIndex == 2 ? Icons.approval : Icons.approval_outlined,
                label: 'Approvals',
                isSelected: currentIndex == 2,
                selectedColor: selected,
                unselectedColor: unselected,
                onTap: () => onTap(2),
              ),
              _buildNavItem(
                context: context,
                icon: currentIndex == 3 ? Icons.person : Icons.person_outline_rounded,
                label: 'Me',
                isSelected: currentIndex == 3,
                selectedColor: selected,
                unselectedColor: unselected,
                onTap: () => onTap(3),
                hasNotification: hasNotification,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single navigation item
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    required VoidCallback onTap,
    bool hasNotification = false,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtle indicator dot for selected item
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCirc,
            width: isSelected ? 10 : 0,
            height: 2,
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isSelected ? 2 : 0),
                child: Icon(icon, color: isSelected ? selectedColor : unselectedColor, size: isSelected ? 20 : 18),
              ),
              if (hasNotification)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 1, offset: const Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
