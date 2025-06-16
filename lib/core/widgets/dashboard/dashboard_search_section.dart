import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Enhanced search section for the dashboard
class DashboardSearchSection extends StatefulWidget {
  /// Callback for search query changes
  final ValueChanged<String>? onSearchChanged;

  /// Callback for filter button tap
  final VoidCallback? onFilterTap;

  /// Callback for grid view button tap
  final VoidCallback? onGridViewTap;

  const DashboardSearchSection({
    super.key,
    this.onSearchChanged,
    this.onFilterTap,
    this.onGridViewTap,
  });

  @override
  State<DashboardSearchSection> createState() => _DashboardSearchSectionState();
}

class _DashboardSearchSectionState extends State<DashboardSearchSection> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Enter a project name',
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
            semanticLabel: 'Search icon',
          ),
          suffixIcon: _buildSuffixActions(context),
          border: _buildBorder(colorScheme, isEnabled: true),
          enabledBorder: _buildBorder(colorScheme, isEnabled: true),
          focusedBorder: _buildBorder(colorScheme, isFocused: true),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
        style: theme.textTheme.bodyLarge,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _searchFocusNode.unfocus(),
      ),
    );
  }

  /// Builds the suffix action buttons
  Widget _buildSuffixActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: widget.onGridViewTap ?? _defaultGridViewAction,
          icon: Icon(Icons.view_module, color: colorScheme.onSurfaceVariant),
          tooltip: 'Grid View',
          splashRadius: 20,
        ),
        IconButton(
          onPressed: widget.onFilterTap ?? _defaultFilterAction,
          icon: Icon(Icons.filter_list, color: colorScheme.onSurfaceVariant),
          tooltip: 'Filter',
          splashRadius: 20,
        ),
      ],
    );
  }

  /// Builds the input border
  OutlineInputBorder _buildBorder(
    ColorScheme colorScheme, {
    bool isEnabled = false,
    bool isFocused = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isFocused
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.2),
        width: isFocused ? 2 : 1,
      ),
    );
  }

  /// Default grid view action
  void _defaultGridViewAction() {
    context.push('/projects');
  }

  /// Default filter action
  void _defaultFilterAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter options coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
