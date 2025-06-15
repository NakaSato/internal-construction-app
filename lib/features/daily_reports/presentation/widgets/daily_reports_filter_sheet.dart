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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Reports',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
          const Divider(),

          // Project Filter
          _buildSectionTitle('Project'),
          _buildProjectDropdown(),
          const SizedBox(height: 16),

          // Technician Filter
          _buildSectionTitle('Technician'),
          _buildTechnicianDropdown(),
          const SizedBox(height: 16),

          // Date Range Filter
          _buildSectionTitle('Date Range'),
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
          const SizedBox(height: 16),

          // Status Filter
          _buildSectionTitle('Status'),
          _buildStatusSelector(),
          const SizedBox(height: 24),

          // Apply Button
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
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
