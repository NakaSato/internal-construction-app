import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../application/models/filter_params.dart';

/// Widget for filtering daily reports
class DailyReportsFilterSheet extends StatefulWidget {
  final DailyReportsFilterParams initialFilters;
  final List<ProjectOption> projects;
  final List<TechnicianOption> technicians;
  final Function(DailyReportsFilterParams) onApplyFilters;

  const DailyReportsFilterSheet({
    super.key,
    required this.initialFilters,
    required this.projects,
    required this.technicians,
    required this.onApplyFilters,
  });

  @override
  State<DailyReportsFilterSheet> createState() =>
      _DailyReportsFilterSheetState();
}

class _DailyReportsFilterSheetState extends State<DailyReportsFilterSheet> {
  late String? _selectedProjectId;
  late String? _selectedTechnicianId;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late DailyReportsFilterStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialFilters.projectId;
    _selectedTechnicianId = widget.initialFilters.technicianId;
    _startDate = widget.initialFilters.startDate;
    _endDate = widget.initialFilters.endDate;
    _selectedStatus = widget.initialFilters.status;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surface, colorScheme.surfaceContainerLowest],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern header with drag handle
            Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Reports',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: 0.3,
                          ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextButton.icon(
                        onPressed: _resetFilters,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        label: Text(
                          'Reset',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Project Filter
            _buildSectionTitle('Project'),
            const SizedBox(height: 12),
            _buildProjectDropdown(),
            const SizedBox(height: 24),

            // Technician Filter
            _buildSectionTitle('Technician'),
            const SizedBox(height: 12),
            _buildTechnicianDropdown(),
            const SizedBox(height: 24),

            // Date Range Filter
            _buildSectionTitle('Date Range'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Start Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    'End Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Filter
            _buildSectionTitle('Status'),
            const SizedBox(height: 12),
            _buildStatusSelector(),
            const SizedBox(height: 32),

            // Modern Apply Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProjectId,
          isExpanded: true,
          hint: const Text('All Projects'),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Projects'),
            ),
            ...widget.projects.map((project) {
              return DropdownMenuItem<String>(
                value: project.id,
                child: Text(project.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedProjectId = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTechnicianDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTechnicianId,
          isExpanded: true,
          hint: const Text('All Technicians'),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Technicians'),
            ),
            ...widget.technicians.map((technician) {
              return DropdownMenuItem<String>(
                value: technician.id,
                child: Text(technician.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedTechnicianId = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    Function(DateTime?) onChanged,
  ) {
    return InkWell(
      onTap: () => _selectDate(context, value, onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? DateFormat('MM/dd/yyyy').format(value) : 'Select',
            ),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onChanged,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  Widget _buildStatusSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatusChip(null, 'All'),
        _buildStatusChip(DailyReportsFilterStatus.draft, 'Draft'),
        _buildStatusChip(DailyReportsFilterStatus.submitted, 'Submitted'),
        _buildStatusChip(DailyReportsFilterStatus.approved, 'Approved'),
        _buildStatusChip(DailyReportsFilterStatus.rejected, 'Rejected'),
      ],
    );
  }

  Widget _buildStatusChip(DailyReportsFilterStatus? status, String label) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        setState(() {
          _selectedStatus = status;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedProjectId = null;
      _selectedTechnicianId = null;
      _startDate = null;
      _endDate = null;
      _selectedStatus = null;
    });
  }

  void _applyFilters() {
    final filters = DailyReportsFilterParams(
      projectId: _selectedProjectId,
      technicianId: _selectedTechnicianId,
      startDate: _startDate,
      endDate: _endDate,
      status: _selectedStatus,
      // Keep the current page size and sort order
      pageSize: widget.initialFilters.pageSize,
      sortBy: widget.initialFilters.sortBy,
      sortDescending: widget.initialFilters.sortDescending,
      // Reset to first page
      pageNumber: 1,
    );

    widget.onApplyFilters(filters);
    Navigator.of(context).pop();
  }
}

/// Project option for dropdown
class ProjectOption {
  final String id;
  final String name;

  ProjectOption({required this.id, required this.name});
}

/// Technician option for dropdown
class TechnicianOption {
  final String id;
  final String name;

  TechnicianOption({required this.id, required this.name});
}
