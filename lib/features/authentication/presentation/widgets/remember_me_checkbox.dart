import 'package:flutter/material.dart';

/// Custom animated checkbox widget for "Remember me" functionality
class RememberMeCheckbox extends StatelessWidget {
  const RememberMeCheckbox({
    super.key,
    required this.rememberMe,
    required this.onToggle,
    required this.isLoading,
    required this.isSmallScreen,
    this.onLongPress,
  });

  final bool rememberMe;
  final VoidCallback onToggle;
  final bool isLoading;
  final bool isSmallScreen;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final checkboxSize = isSmallScreen ? 18.0 : 20.0; // Slightly smaller for compact design
    final fontSize = isSmallScreen ? 12.0 : 13.0; // More compact font size

    return Expanded(
      child: InkWell(
        onTap: isLoading ? null : onToggle,
        onLongPress: isLoading ? null : onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom animated checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: checkboxSize,
                height: checkboxSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: rememberMe
                        ? const Color(0xFF4CAF50)
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
                    width: rememberMe ? 2 : 1.5,
                  ),
                  color: rememberMe ? const Color(0xFF4CAF50) : Colors.transparent,
                  boxShadow: rememberMe
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: rememberMe
                    ? Icon(Icons.check_rounded, color: Colors.white, size: isSmallScreen ? 12.0 : 14.0)
                    : null,
              ),
              const SizedBox(width: 12),
              // Enhanced text with better typography
              Expanded(
                child: Text(
                  'Remember me',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: rememberMe
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: rememberMe ? FontWeight.w600 : FontWeight.w500,
                    fontSize: fontSize,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
