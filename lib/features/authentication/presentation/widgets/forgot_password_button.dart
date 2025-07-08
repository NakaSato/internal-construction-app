import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';

/// Custom "Forgot Password?" button widget
class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key, required this.isLoading, required this.isSmallScreen});

  final bool isLoading;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final buttonFontSize = isSmallScreen ? 11.0 : 12.0; // More compact font size

    return TextButton(
      onPressed: isLoading ? null : () => context.go(AppRoutes.forgotPassword),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 8 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
      ),
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: const Color(0xFF4CAF50),
          fontWeight: FontWeight.w600,
          fontSize: buttonFontSize,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
