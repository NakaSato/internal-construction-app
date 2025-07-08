import 'package:flutter/material.dart';

/// Custom username input field widget with validation
class UsernameField extends StatelessWidget {
  const UsernameField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.passwordFocusNode,
    required this.isLoading,
    required this.buildInputDecoration,
    required this.buildPrefixIcon,
    required this.minUsernameLength,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode passwordFocusNode;
  final bool isLoading;
  final InputDecoration Function({
    required String labelText,
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  })
  buildInputDecoration;
  final Widget Function(IconData) buildPrefixIcon;
  final int minUsernameLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      style: TextStyle(
        fontSize: 15, // Reduced from 16 for better compact design
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.3, // Reduced letter spacing for compact design
      ),
      decoration: buildInputDecoration(
        labelText: 'Username',
        hintText: 'Enter your username',
        prefixIcon: buildPrefixIcon(Icons.person_rounded),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        if (value.length < minUsernameLength) {
          return 'Username must be at least $minUsernameLength characters';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(passwordFocusNode);
      },
    );
  }
}
