import 'package:flutter/material.dart';

/// Widget for the login header section with title and description
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, required this.isSmallScreen, required this.screenWidth});

  final bool isSmallScreen;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    // Responsive font sizes - more compact
    final titleFontSize = isSmallScreen ? (screenWidth < 320 ? 24.0 : 28.0) : 36.0;
    final descriptionFontSize = isSmallScreen ? 12.0 : 14.0;

    return Column(
      children: [
        // Make title responsive with better line breaking
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'CONSTRUCTION\nINTERNAL',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: isSmallScreen ? -0.3 : -0.5,
                height: 1.1,
                fontSize: titleFontSize,
                shadows: [
                  Shadow(offset: const Offset(0, 2), blurRadius: 8, color: Colors.black.withValues(alpha: 0.3)),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        // Responsive description with better padding
        if (!isSmallScreen || MediaQuery.of(context).size.height > 600)
          Container(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 20.0),
            child: Text(
              'Manage your solar construction projects',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
                fontSize: descriptionFontSize,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(offset: const Offset(0, 1), blurRadius: 4, color: Colors.black.withValues(alpha: 0.2)),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
