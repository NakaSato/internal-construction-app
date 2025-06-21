import 'package:flutter/material.dart';
import '../../domain/entities/project_api_models.dart';

/// Bottom sheet for filtering projects
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

  final List<String> _statuses = [
    'Active',
    'Completed',
    'On Hold',
    'Planning',
    'Cancelled',
  ];

  final List<String> _sortOptions = [
    'projectName',
    'startDate',
    'estimatedEndDate',
    'status',
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.currentQuery;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Filter Projects',
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
              Text(
                'Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _query.status?.isEmpty == true ? null : _query.status,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select status',
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

              const SizedBox(height: 16),

              // Sort By
              Text(
                'Sort By',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _query.sortBy?.isEmpty == true ? null : _query.sortBy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select sort field',
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

              const SizedBox(height: 16),

              // Sort Order
              if (_query.sortBy?.isNotEmpty == true) ...[
                Text(
                  'Sort Order',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _query.sortOrder ?? 'asc',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                    DropdownMenuItem(value: 'desc', child: Text('Descending')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _query = _query.copyWith(sortOrder: value);
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Page Size
              Text(
                'Items per page',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _query.pageSize,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5')),
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 20, child: Text('20')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                ],
                onChanged: (value) {
                  setState(() {
                    _query = _query.copyWith(pageSize: value);
                  });
                },
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _query = const ProjectsQuery();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilters(_query);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      default:
        return option;
    }
  }
}
