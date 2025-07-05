library solar_ui_inputs;

/// Solar UI System - Input Components
///
/// This file contains all input components for the Solar Project Management app.
/// These components provide consistent form controls with solar-specific styling.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/design_system.dart';

/// Solar Input Field Variant Types
enum SolarInputVariant { outlined, filled, underlined }

/// Solar Input Field Size Options
enum SolarInputSize { small, medium, large }

/// Solar Text Field Widget
///
/// A flexible text input component with validation, states, and solar theming.
class SolarTextField extends StatefulWidget {
  const SolarTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.variant = SolarInputVariant.outlined,
    this.size = SolarInputSize.medium,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.isRequired = false,
  });

  /// Text editing controller
  final TextEditingController? controller;

  /// Initial value
  final String? initialValue;

  /// Label text
  final String? labelText;

  /// Hint text
  final String? hintText;

  /// Helper text
  final String? helperText;

  /// Error text
  final String? errorText;

  /// Prefix icon
  final Widget? prefixIcon;

  /// Suffix icon
  final Widget? suffixIcon;

  /// Prefix text
  final String? prefixText;

  /// Suffix text
  final String? suffixText;

  /// Input variant
  final SolarInputVariant variant;

  /// Input size
  final SolarInputSize size;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Obscure text for passwords
  final bool obscureText;

  /// Enabled state
  final bool enabled;

  /// Read only state
  final bool readOnly;

  /// Maximum number of lines
  final int? maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum length
  final int? maxLength;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Validator function
  final String? Function(String?)? validator;

  /// Value changed callback
  final ValueChanged<String>? onChanged;

  /// Form submitted callback
  final ValueChanged<String>? onSubmitted;

  /// Tap callback
  final VoidCallback? onTap;

  /// Focus node
  final FocusNode? focusNode;

  /// Auto focus
  final bool autofocus;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Text alignment
  final TextAlign textAlign;

  /// Required field indicator
  final bool isRequired;

  @override
  State<SolarTextField> createState() => _SolarTextFieldState();
}

class _SolarTextFieldState extends State<SolarTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _errorText = widget.errorText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      // Trigger rebuild when focus changes for visual updates
    });
  }

  void _onChanged(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[_buildLabel(context), SizedBox(height: AppDesignTokens.spacingXs)],

        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: _buildInputDecoration(context, hasError),
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          onChanged: _onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,
          style: _getTextStyle(context),
        ),

        if (widget.helperText != null || hasError) ...[
          SizedBox(height: AppDesignTokens.spacingXs),
          _buildHelperText(context, hasError),
        ],
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          widget.labelText!,
          style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
        ),
        if (widget.isRequired) ...[
          SizedBox(width: AppDesignTokens.spacingXxs),
          Text(
            '*',
            style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }

  Widget _buildHelperText(BuildContext context, bool hasError) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final text = hasError ? _errorText : widget.helperText;
    final color = hasError ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Text(text!, style: theme.textTheme.bodySmall?.copyWith(color: color));
  }

  InputDecoration _buildInputDecoration(BuildContext context, bool hasError) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderRadius = _getBorderRadius();
    final contentPadding = _getContentPadding();

    InputBorder border;
    InputBorder focusedBorder;
    InputBorder errorBorder;

    switch (widget.variant) {
      case SolarInputVariant.outlined:
        border = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        );
        focusedBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        );
        errorBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.error),
        );
        break;

      case SolarInputVariant.filled:
        border = OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide.none);
        focusedBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        );
        errorBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.error),
        );
        break;

      case SolarInputVariant.underlined:
        border = UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.outline));
        focusedBorder = UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary, width: 2));
        errorBorder = UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.error));
        break;
    }

    return InputDecoration(
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      contentPadding: contentPadding,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      filled: widget.variant == SolarInputVariant.filled,
      fillColor: widget.variant == SolarInputVariant.filled ? colorScheme.surfaceContainerHighest : null,
      hintStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      prefixStyle: _getTextStyle(context),
      suffixStyle: _getTextStyle(context),
    );
  }

  BorderRadius _getBorderRadius() {
    switch (widget.size) {
      case SolarInputSize.small:
        return BorderRadius.circular(AppDesignTokens.radiusSm);
      case SolarInputSize.medium:
        return BorderRadius.circular(AppDesignTokens.radiusMd);
      case SolarInputSize.large:
        return BorderRadius.circular(AppDesignTokens.radiusLg);
    }
  }

  EdgeInsetsGeometry _getContentPadding() {
    switch (widget.size) {
      case SolarInputSize.small:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingSm, vertical: AppDesignTokens.spacingXs);
      case SolarInputSize.medium:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingMd, vertical: AppDesignTokens.spacingSm);
      case SolarInputSize.large:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingLg, vertical: AppDesignTokens.spacingMd);
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.size) {
      case SolarInputSize.small:
        return theme.textTheme.bodySmall!;
      case SolarInputSize.medium:
        return theme.textTheme.bodyLarge!;
      case SolarInputSize.large:
        return theme.textTheme.titleSmall!;
    }
  }
}

/// Solar Dropdown Field Widget
class SolarDropdownField<T> extends StatelessWidget {
  const SolarDropdownField({
    super.key,
    required this.items,
    this.value,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.variant = SolarInputVariant.outlined,
    this.size = SolarInputSize.medium,
    this.enabled = true,
    this.isRequired = false,
    this.onChanged,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final SolarInputVariant variant;
  final SolarInputSize size;
  final bool enabled;
  final bool isRequired;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Row(
            children: [
              Text(
                labelText!,
                style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
              ),
              if (isRequired) ...[
                SizedBox(width: AppDesignTokens.spacingXxs),
                Text(
                  '*',
                  style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingXs),
        ],

        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          decoration: _buildInputDecoration(context),
          style: _getTextStyle(context),
          dropdownColor: colorScheme.surface,
          icon: Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
        ),

        if (helperText != null || errorText != null) ...[
          SizedBox(height: AppDesignTokens.spacingXs),
          Text(
            errorText ?? helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: errorText != null ? colorScheme.error : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderRadius = _getBorderRadius();
    final contentPadding = _getContentPadding();

    InputBorder border;
    InputBorder focusedBorder;
    InputBorder errorBorder;

    switch (variant) {
      case SolarInputVariant.outlined:
        border = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        );
        focusedBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        );
        errorBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.error),
        );
        break;

      case SolarInputVariant.filled:
        border = OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide.none);
        focusedBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        );
        errorBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.error),
        );
        break;

      case SolarInputVariant.underlined:
        border = UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.outline));
        focusedBorder = UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary, width: 2));
        errorBorder = UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.error));
        break;
    }

    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      contentPadding: contentPadding,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      filled: variant == SolarInputVariant.filled,
      fillColor: variant == SolarInputVariant.filled ? colorScheme.surfaceContainerHighest : null,
      hintStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  BorderRadius _getBorderRadius() {
    switch (size) {
      case SolarInputSize.small:
        return BorderRadius.circular(AppDesignTokens.radiusSm);
      case SolarInputSize.medium:
        return BorderRadius.circular(AppDesignTokens.radiusMd);
      case SolarInputSize.large:
        return BorderRadius.circular(AppDesignTokens.radiusLg);
    }
  }

  EdgeInsetsGeometry _getContentPadding() {
    switch (size) {
      case SolarInputSize.small:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingSm, vertical: AppDesignTokens.spacingXs);
      case SolarInputSize.medium:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingMd, vertical: AppDesignTokens.spacingSm);
      case SolarInputSize.large:
        return EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingLg, vertical: AppDesignTokens.spacingMd);
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);

    switch (size) {
      case SolarInputSize.small:
        return theme.textTheme.bodySmall!;
      case SolarInputSize.medium:
        return theme.textTheme.bodyLarge!;
      case SolarInputSize.large:
        return theme.textTheme.titleSmall!;
    }
  }
}

/// Solar Search Field Widget
class SolarSearchField extends StatelessWidget {
  const SolarSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.size = SolarInputSize.medium,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final SolarInputSize size;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return SolarTextField(
      controller: controller,
      hintText: hintText,
      variant: SolarInputVariant.filled,
      size: size,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
