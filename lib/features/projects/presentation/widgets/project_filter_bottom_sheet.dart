import 'package:flutter/material.dart';
import '../../domain/entities/project_api_models.dart';

/// Bottom sheet for filtering projects with enhanced filtering options
class ProjectFilterBottomSheet extends StatefulWidget {
  const ProjectFilterBottomSheet({
    super.key,
    required this.currentQuery,
    required this.onApplyFilters,
  });

  final ProjectsQuery currentQuery;
  final ValueChanged<ProjectsQuery> onApplyFilters;

  @override
  State<ProjectFilterBottomSheet> createState() =>
      _ProjectFilterBottomSheetState();
}

class _ProjectFilterBottomSheetState extends State<ProjectFilterBottomSheet> {
  late ProjectsQuery _query;

  // Capacity range filters
  double _minCapacity = 0;
  double _maxCapacity = 2000; // 2MW max
  bool _useCapacityFilter = false;

  // Date range filters
  DateTimeRange? _dateRange;
  bool _useDateFilter = false;

  // Team filter
  String? _selectedTeam;
  bool _useTeamFilter = false;

  // Connection type filter
  String? _selectedConnectionType;
  bool _useConnectionFilter = false;

  final List<String> _statuses = [
    'Planning',
    'Active',
    'In Progress',
    'Completed',
    'On Hold',
    'Cancelled',
  ];

  final List<String> _sortOptions = [
    'projectName',
    'startDate',
    'estimatedEndDate',
    'status',
    'totalCapacityKw',
    'createdAt',
    'updatedAt',
  ];

  final List<String> _teams = [
    'Solar Team Alpha',
    'Solar Team Beta',
    'Solar Team Gamma',
    'Installation Team A',
    'Installation Team B',
    'Maintenance Team',
  ];

  final List<String> _connectionTypes = [
    'LV', // Low Voltage
    'HV', // High Voltage
    'Grid-Tied',
    'Off-Grid',
    'Hybrid',
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.currentQuery;

    // Initialize filter states from current query
    _useCapacityFilter =
        widget.currentQuery.minCapacity != null ||
        widget.currentQuery.maxCapacity != null;
    _minCapacity = widget.currentQuery.minCapacity ?? 0;
    _maxCapacity = widget.currentQuery.maxCapacity ?? 2000;

    _useTeamFilter = widget.currentQuery.team?.isNotEmpty == true;
    _selectedTeam = widget.currentQuery.team;

    _useConnectionFilter =
        widget.currentQuery.connectionType?.isNotEmpty == true;
    _selectedConnectionType = widget.currentQuery.connectionType;

    _useDateFilter =
        widget.currentQuery.startDateFrom != null ||
        widget.currentQuery.startDateTo != null;
    if (_useDateFilter) {
      _dateRange = DateTimeRange(
        start:
            widget.currentQuery.startDateFrom ??
            DateTime.now().subtract(const Duration(days: 365)),
        end: widget.currentQuery.startDateTo ?? DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: mediaQuery.viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Advanced Filters',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Status Filter
                _buildSectionTitle('Project Status'),
                DropdownButtonFormField<String>(
                  value: _query.status?.isEmpty == true ? null : _query.status,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Select status',
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ..._statuses.map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _query = _query.copyWith(status: value ?? '');
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Capacity Filter
                _buildSectionTitle('Capacity Range (kW)'),
                SwitchListTile(
                  title: Text('Filter by capacity'),
                  subtitle: _useCapacityFilter
                      ? Text(
                          '${_minCapacity.toInt()} - ${_maxCapacity.toInt()} kW',
                        )
                      : null,
                  value: _useCapacityFilter,
                  onChanged: (value) {
                    setState(() {
                      _useCapacityFilter = value;
                    });
                  },
                ),
                if (_useCapacityFilter) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Min: ${_minCapacity.toInt()} kW'),
                            const Spacer(),
                            Text('Max: ${_maxCapacity.toInt()} kW'),
                          ],
                        ),
                        RangeSlider(
                          values: RangeValues(_minCapacity, _maxCapacity),
                          min: 0,
                          max: 2000,
                          divisions: 40,
                          labels: RangeLabels(
                            '${_minCapacity.toInt()}kW',
                            '${_maxCapacity.toInt()}kW',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _minCapacity = values.start;
                              _maxCapacity = values.end;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Team Filter
                _buildSectionTitle('Team Assignment'),
                SwitchListTile(
                  title: Text('Filter by team'),
                  subtitle: _useTeamFilter && _selectedTeam != null
                      ? Text(_selectedTeam!)
                      : null,
                  value: _useTeamFilter,
                  onChanged: (value) {
                    setState(() {
                      _useTeamFilter = value;
                      if (!value) _selectedTeam = null;
                    });
                  },
                ),
                if (_useTeamFilter) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTeam,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Select team',
                      prefixIcon: const Icon(Icons.group_outlined),
                    ),
                    items: _teams
                        .map(
                          (team) =>
                              DropdownMenuItem(value: team, child: Text(team)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTeam = value;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Connection Type Filter
                _buildSectionTitle('Connection Type'),
                SwitchListTile(
                  title: Text('Filter by connection type'),
                  subtitle:
                      _useConnectionFilter && _selectedConnectionType != null
                      ? Text(_selectedConnectionType!)
                      : null,
                  value: _useConnectionFilter,
                  onChanged: (value) {
                    setState(() {
                      _useConnectionFilter = value;
                      if (!value) _selectedConnectionType = null;
                    });
                  },
                ),
                if (_useConnectionFilter) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedConnectionType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Select connection type',
                      prefixIcon: const Icon(Icons.power_outlined),
                    ),
                    items: _connectionTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedConnectionType = value;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Date Range Filter
                _buildSectionTitle('Date Range Filter'),
                SwitchListTile(
                  title: Text('Filter by date range'),
                  subtitle: _useDateFilter && _dateRange != null
                      ? Text(
                          '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                        )
                      : null,
                  value: _useDateFilter,
                  onChanged: (value) {
                    setState(() {
                      _useDateFilter = value;
                      if (!value) _dateRange = null;
                    });
                  },
                ),
                if (_useDateFilter) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              initialDateRange: _dateRange,
                              builder: (context, child) {
                                return Theme(
                                  data: theme.copyWith(
                                    colorScheme: theme.colorScheme.copyWith(
                                      primary: theme.colorScheme.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _dateRange = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _dateRange != null
                                ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                                : 'Select Date Range',
                          ),
                        ),
                        if (_dateRange != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Start: ${_formatDate(_dateRange!.start)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'End: ${_formatDate(_dateRange!.end)}',
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Multiple Status Filter (Enhanced)
                _buildSectionTitle('Project Status (Multiple Selection)'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: _statuses.map((status) {
                      final selectedStatuses = _query.statuses ?? [];
                      final isSelected = selectedStatuses.contains(status);

                      return CheckboxListTile(
                        title: Text(status),
                        subtitle: Text(_getStatusDescription(status)),
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            final currentStatuses = List<String>.from(
                              _query.statuses ?? [],
                            );
                            if (selected == true) {
                              if (!currentStatuses.contains(status)) {
                                currentStatuses.add(status);
                              }
                            } else {
                              currentStatuses.remove(status);
                            }
                            _query = _query.copyWith(
                              statuses: currentStatuses.isEmpty
                                  ? null
                                  : currentStatuses,
                            );
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Project Search Filters
                _buildSectionTitle('Project Information'),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Filter by project name',
                    prefixIcon: const Icon(Icons.business),
                  ),
                  controller: TextEditingController(
                    text: _query.projectName ?? '',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = _query.copyWith(
                        projectName: value.isEmpty ? null : value,
                      );
                    });
                  },
                ),

                const SizedBox(height: 12),

                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Filter by client information',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  controller: TextEditingController(
                    text: _query.clientInfo ?? '',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = _query.copyWith(
                        clientInfo: value.isEmpty ? null : value,
                      );
                    });
                  },
                ),

                const SizedBox(height: 12),

                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Filter by address',
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  controller: TextEditingController(text: _query.address ?? ''),
                  onChanged: (value) {
                    setState(() {
                      _query = _query.copyWith(
                        address: value.isEmpty ? null : value,
                      );
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Sort Options
                _buildSectionTitle('Sort Options'),
                DropdownButtonFormField<String>(
                  value: _query.sortBy?.isEmpty == true ? null : _query.sortBy,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Select sort field',
                    prefixIcon: const Icon(Icons.sort),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Default')),
                    ..._sortOptions.map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(_formatSortOption(option)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _query = _query.copyWith(sortBy: value ?? '');
                    });
                  },
                ),

                if (_query.sortBy?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _query.sortOrder ?? 'asc',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Sort order',
                      prefixIcon: const Icon(Icons.swap_vert),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                      DropdownMenuItem(
                        value: 'desc',
                        child: Text('Descending'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _query = _query.copyWith(sortOrder: value);
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Filter summary
                      Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_getActiveFilterCount()} active filters',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
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
                              onPressed: _clearAllFilters,
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Clear All'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: _applyFilters,
                              icon: const Icon(Icons.check),
                              label: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Planning':
        return 'Project is in planning phase';
      case 'Active':
        return 'Project is currently active';
      case 'In Progress':
        return 'Work is in progress';
      case 'Completed':
        return 'Project has been completed';
      case 'On Hold':
        return 'Project is temporarily paused';
      case 'Cancelled':
        return 'Project has been cancelled';
      default:
        return 'Unknown status';
    }
  }

  String _formatSortOption(String option) {
    switch (option) {
      case 'projectName':
        return 'Project Name';
      case 'startDate':
        return 'Start Date';
      case 'estimatedEndDate':
        return 'End Date';
      case 'status':
        return 'Status';
      case 'totalCapacityKw':
        return 'Capacity (kW)';
      case 'createdAt':
        return 'Created Date';
      case 'updatedAt':
        return 'Updated Date';
      default:
        return option;
    }
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_query.status?.isNotEmpty == true) count++;
    if (_query.statuses?.isNotEmpty == true) count++;
    if (_useCapacityFilter) count++;
    if (_useTeamFilter) count++;
    if (_useConnectionFilter) count++;
    if (_useDateFilter) count++;
    if (_query.projectName?.isNotEmpty == true) count++;
    if (_query.clientInfo?.isNotEmpty == true) count++;
    if (_query.address?.isNotEmpty == true) count++;
    if (_query.sortBy?.isNotEmpty == true) count++;
    return count;
  }

  void _clearAllFilters() {
    setState(() {
      _query = const ProjectsQuery();
      _useCapacityFilter = false;
      _minCapacity = 0;
      _maxCapacity = 2000;
      _useTeamFilter = false;
      _selectedTeam = null;
      _useConnectionFilter = false;
      _selectedConnectionType = null;
      _useDateFilter = false;
      _dateRange = null;
    });
  }

  void _applyFilters() {
    ProjectsQuery finalQuery = _query;

    // Apply capacity filter
    if (_useCapacityFilter) {
      finalQuery = finalQuery.copyWith(
        minCapacity: _minCapacity,
        maxCapacity: _maxCapacity,
      );
    }

    // Apply team filter
    if (_useTeamFilter && _selectedTeam != null) {
      finalQuery = finalQuery.copyWith(team: _selectedTeam);
    }

    // Apply connection type filter
    if (_useConnectionFilter && _selectedConnectionType != null) {
      finalQuery = finalQuery.copyWith(connectionType: _selectedConnectionType);
    }

    // Apply date range filter
    if (_useDateFilter && _dateRange != null) {
      finalQuery = finalQuery.copyWith(
        startDateFrom: _dateRange!.start,
        startDateTo: _dateRange!.end,
      );
    }

    widget.onApplyFilters(finalQuery);
    Navigator.of(context).pop();
  }
}
