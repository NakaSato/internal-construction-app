import 'package:flutter/material.dart';

/// Container widget for the login form with consistent styling and layout
class LoginFormContainer extends StatelessWidget {
  const LoginFormContainer({
    super.key,
    required this.formKey,
    required this.isSmallScreen,
    required this.responsivePadding,
    required this.responsiveMargin,
    required this.containerBorderRadius,
    required this.usernameField,
    required this.passwordField,
    required this.optionsRow,
    required this.signInButton,
  });

  final GlobalKey<FormState> formKey;
  final bool isSmallScreen;
  final EdgeInsets responsivePadding;
  final EdgeInsets responsiveMargin;
  final double containerBorderRadius;
  final Widget usernameField;
  final Widget passwordField;
  final Widget optionsRow;
  final Widget signInButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: responsivePadding,
      margin: responsiveMargin,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(containerBorderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: const Color(0xFFCDDC39).withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 16)),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            usernameField,
            SizedBox(height: isSmallScreen ? 16 : 20),
            passwordField,
            SizedBox(height: isSmallScreen ? 20 : 24),
            optionsRow,
            SizedBox(height: isSmallScreen ? 20 : 24),
            signInButton,
          ],
        ),
      ),
    );
  }
}
