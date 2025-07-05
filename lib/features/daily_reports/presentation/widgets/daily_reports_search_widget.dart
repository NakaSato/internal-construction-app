import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/models/filter_params.dart';

/// Widget for advanced search functionality in daily reports
class DailyReportsSearchWidget extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearchChanged;
  final Function(DailyReportsFilterParams) onAdvancedSearch;
  final VoidCallback? onClearSearch;

  const DailyReportsSearchWidget({
    super.key,
    this.initialQuery,
    required this.onSearchChanged,
    required this.onAdvancedSearch,
    this.onClearSearch,
  });

  @override
  State<DailyReportsSearchWidget> createState() => _DailyReportsSearchWidgetState();
}

class _DailyReportsSearchWidgetState extends State<DailyReportsSearchWidget> with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _showAdvancedOptions = false;

  // Advanced search fields
  String? _selectedStatus;
  String? _selectedProject;
  DateTimeRange? _dateRange;
  String? _selectedTechnician;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search input
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search reports by description, notes, or technician...',
                      prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                widget.onSearchChanged('');
                                if (widget.onClearSearch != null) {
                                  widget.onClearSearch!();
                                }
                              },
                              icon: Icon(Icons.clear_rounded, color: colorScheme.onSurfaceVariant),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: widget.onSearchChanged,
                  ),
                ),

                const SizedBox(width: 8),

                // Advanced search toggle
                Material(
                  borderRadius: BorderRadius.circular(12),
                  color: _showAdvancedOptions
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: _toggleAdvancedSearch,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.tune_rounded,
                        color: _showAdvancedOptions ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Advanced search options
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(heightFactor: _expandAnimation.value, child: child),
              );
            },
            child: _showAdvancedOptions ? _buildAdvancedOptions() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.filter_list_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Advanced Search',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // First row: Status and Project
          Row(
            children: [
              Expanded(
                child: _buildDropdownField('Status', _selectedStatus, [
                  'All',
                  'Draft',
                  'Submitted',
                  'Approved',
                  'Rejected',
                ], (value) => setState(() => _selectedStatus = value == 'All' ? null : value)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  'Project',
                  _selectedProject,
                  ['All Projects', 'Solar Installation Alpha', 'Commercial Rooftop', 'Residential Array'],
                  (value) => setState(() => _selectedProject = value == 'All Projects' ? null : value),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Second row: Date Range and Technician
          Row(
            children: [
              Expanded(child: _buildDateRangeField()),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  'Technician',
                  _selectedTechnician,
                  ['All Technicians', 'John Technician', 'Jane Smith', 'Robert Engineer'],
                  (value) => setState(() => _selectedTechnician = value == 'All Technicians' ? null : value),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearAdvancedFilters,
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: const Text('Clear Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _applyAdvancedSearch,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Apply Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> options, Function(String?) onChanged) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeField() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Material(
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range_outlined, color: colorScheme.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dateRange != null
                          ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                          : 'Select date range',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _dateRange != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_dateRange != null)
                    GestureDetector(
                      onTap: () => setState(() => _dateRange = null),
                      child: Icon(Icons.clear_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleAdvancedSearch() {
    setState(() {
      _showAdvancedOptions = !_showAdvancedOptions;
    });

    if (_showAdvancedOptions) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _clearAdvancedFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedProject = null;
      _dateRange = null;
      _selectedTechnician = null;
    });
  }

  void _applyAdvancedSearch() {
    final filters = DailyReportsFilterParams(
      status: _selectedStatus != null
          ? DailyReportsFilterStatus.values.firstWhere(
              (s) => s.name.toLowerCase() == _selectedStatus!.toLowerCase(),
              orElse: () => DailyReportsFilterStatus.all,
            )
          : null,
      projectId: _selectedProject,
      technicianId: _selectedTechnician,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );

    widget.onAdvancedSearch(filters);

    // Also trigger text search if there's a query
    if (_searchController.text.trim().isNotEmpty) {
      widget.onSearchChanged(_searchController.text.trim());
    }

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Advanced search applied'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
