import 'package:flutter/material.dart';

/// Custom password input field widget with visibility toggle and validation
class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onFieldSubmitted,
    required this.buildInputDecoration,
    required this.buildPrefixIcon,
    required this.minPasswordLength,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onFieldSubmitted;
  final InputDecoration Function({
    required String labelText,
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  })
  buildInputDecoration;
  final Widget Function(IconData) buildPrefixIcon;
  final int minPasswordLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      enabled: !isLoading,
      style: TextStyle(
        fontSize: 15, // Reduced from 16 for better compact design
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.3, // Reduced letter spacing for compact design
      ),
      decoration: buildInputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: buildPrefixIcon(Icons.lock_rounded),
        suffixIcon: _buildPasswordToggleIcon(context),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < minPasswordLength) {
          return 'Password must be at least $minPasswordLength characters';
        }
        return null;
      },
      onFieldSubmitted: (_) => onFieldSubmitted(),
    );
  }

  /// Builds an enhanced password visibility toggle icon with minimal styling
  Widget _buildPasswordToggleIcon(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: isLoading ? null : onTogglePasswordVisibility,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Icon(
              obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              key: ValueKey(obscurePassword),
              color: isLoading
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                  : const Color(0xFF4CAF50).withValues(alpha: 0.85),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
