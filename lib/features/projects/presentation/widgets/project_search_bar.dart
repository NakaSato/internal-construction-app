import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/services/realtime_api_streams.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/project_api_models.dart';

/// Search bar widget for projects with filter functionality and real-time updates
class ProjectSearchBar extends StatefulWidget {
  const ProjectSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    this.hintText = 'Search projects by name, client, or address...',
    this.onClearSearch,
    this.showActiveFilters = false,
    this.activeFilterCount = 0,
    this.currentQuery,
    this.onQueryChanged,
    this.onRealtimeUpdate,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final String hintText;
  final VoidCallback? onClearSearch;
  final bool showActiveFilters;
  final int activeFilterCount;
  final ProjectsQuery? currentQuery;
  final ValueChanged<ProjectsQuery>? onQueryChanged;
  final ValueChanged<RealtimeProjectUpdate>? onRealtimeUpdate;

  @override
  State<ProjectSearchBar> createState() => _ProjectSearchBarState();
}

class _ProjectSearchBarState extends State<ProjectSearchBar> {
  String _searchMode = 'all'; // 'all', 'name', 'client', 'address', 'capacity'

  // Real-time update state
  StreamSubscription<RealtimeProjectUpdate>? _realtimeSubscription;
  late final RealtimeApiStreams _realtimeStreams;
  bool _isRealtimeConnected = false;
  bool _hasRecentUpdate = false;
  Timer? _updateIndicatorTimer;

  final List<Map<String, dynamic>> _searchModes = [
    {'key': 'all', 'label': 'All Fields', 'icon': Icons.search},
    {'key': 'name', 'label': 'Project Name', 'icon': Icons.business},
    {'key': 'client', 'label': 'Client Info', 'icon': Icons.person},
    {'key': 'address', 'label': 'Address', 'icon': Icons.location_on},
    {'key': 'capacity', 'label': 'Capacity (kW)', 'icon': Icons.bolt},
  ];

  @override
  void initState() {
    super.initState();
    _initializeRealtimeUpdates();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _updateIndicatorTimer?.cancel();
    super.dispose();
  }

  void _initializeRealtimeUpdates() {
    try {
      // Initialize real-time streams
      _realtimeStreams = getIt<RealtimeApiStreams>();

      // Subscribe to project updates using the correct stream name
      _realtimeSubscription = _realtimeStreams.projectsStream.listen(
        (update) {
          if (mounted) {
            setState(() {
              _hasRecentUpdate = true;
              _isRealtimeConnected = true;
            });

            // Call parent callback if provided
            if (widget.onRealtimeUpdate != null) {
              widget.onRealtimeUpdate!(update);
            }

            // Clear update indicator after 3 seconds
            _updateIndicatorTimer?.cancel();
            _updateIndicatorTimer = Timer(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _hasRecentUpdate = false;
                });
              }
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isRealtimeConnected = false;
            });
          }
          debugPrint('Real-time projects stream error: $error');
        },
      );

      // Set initial connection state
      setState(() {
        _isRealtimeConnected = true;
      });
    } catch (e) {
      // Graceful fallback if real-time services are not available
      debugPrint('Real-time updates not available: $e');
      setState(() {
        _isRealtimeConnected = false;
      });
    }
  }

  String _getSearchHint() {
    switch (_searchMode) {
      case 'name':
        return 'Search by project name...';
      case 'client':
        return 'Search by client information...';
      case 'address':
        return 'Search by project address...';
      case 'capacity':
        return 'Search by capacity (e.g., 100, >50, <200)...';
      default:
        return 'Search projects by name, client, or address...';
    }
  }

  void _handleSearchChanged(String value) {
    widget.onChanged(value);

    // Update query based on search mode if callback is provided
    if (widget.onQueryChanged != null && widget.currentQuery != null) {
      final query = widget.currentQuery!;
      ProjectsQuery newQuery;

      switch (_searchMode) {
        case 'name':
          newQuery = query.copyWith(projectName: value.isEmpty ? null : value);
          break;
        case 'client':
          newQuery = query.copyWith(clientInfo: value.isEmpty ? null : value);
          break;
        case 'address':
          newQuery = query.copyWith(address: value.isEmpty ? null : value);
          break;
        case 'capacity':
          if (value.isEmpty) {
            newQuery = query.copyWith(minCapacity: null, maxCapacity: null);
          } else {
            final capacityFilter = _parseCapacityFilter(value);
            newQuery = query.copyWith(minCapacity: capacityFilter['min'], maxCapacity: capacityFilter['max']);
          }
          break;
        default:
          // For 'all' mode, use general filter
          newQuery = query.copyWith(filter: value.isEmpty ? null : value);
          break;
      }

      widget.onQueryChanged!(newQuery);
    }
  }

  Map<String, double?> _parseCapacityFilter(String value) {
    // Parse capacity filters like ">50", "<200", "100", "50-150"
    value = value.trim();

    if (value.startsWith('>')) {
      final minValue = double.tryParse(value.substring(1));
      return {'min': minValue, 'max': null};
    } else if (value.startsWith('<')) {
      final maxValue = double.tryParse(value.substring(1));
      return {'min': null, 'max': maxValue};
    } else if (value.contains('-')) {
      final parts = value.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0]);
        final max = double.tryParse(parts[1]);
        return {'min': min, 'max': max};
      }
    } else {
      // Exact match or approximate
      final capacity = double.tryParse(value);
      if (capacity != null) {
        return {'min': capacity - 10, 'max': capacity + 10};
      }
    }

    return {'min': null, 'max': null};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasText = widget.controller.text.isNotEmpty;
    final currentMode = _searchModes.firstWhere((mode) => mode['key'] == _searchMode);

    return Column(
      children: [
        // Search Mode Selector
        Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _searchModes.length,
            itemBuilder: (context, index) {
              final mode = _searchModes[index];
              final isSelected = mode['key'] == _searchMode;

              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mode['icon'] as IconData,
                        size: 16,
                        color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(mode['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _searchMode = mode['key'] as String;
                      });
                    }
                  },
                  selectedColor: colorScheme.secondaryContainer,
                  backgroundColor: colorScheme.surface,
                ),
              );
            },
          ),
        ),

        // Real-time status indicator
        if (_isRealtimeConnected)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _hasRecentUpdate ? colorScheme.primaryContainer : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _hasRecentUpdate ? colorScheme.primary : colorScheme.outline.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _hasRecentUpdate ? Icons.sync : Icons.wifi,
                  size: 14,
                  color: _hasRecentUpdate ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  _hasRecentUpdate ? 'Live update received' : 'Real-time connected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _hasRecentUpdate ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    fontWeight: _hasRecentUpdate ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (_hasRecentUpdate)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: (value) {
                  setState(() {});
                  _handleSearchChanged(value);
                },
                decoration: InputDecoration(
                  hintText: _getSearchHint(),
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                  prefixIcon: Icon(currentMode['icon'] as IconData, color: colorScheme.onSurfaceVariant),
                  suffixIcon: hasText
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchMode == 'capacity' && hasText)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  'kW',
                                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                                ),
                              ),
                            IconButton(
                              onPressed: () {
                                widget.controller.clear();
                                setState(() {});
                                _handleSearchChanged('');
                                widget.onClearSearch?.call();
                              },
                              icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: _searchMode == 'capacity' ? TextInputType.number : TextInputType.text,
              ),
            ),
            const SizedBox(width: 12),
            // Filter button with badge
            Stack(
              children: [
                IconButton.filled(
                  onPressed: widget.onFilterTap,
                  icon: const Icon(Icons.tune),
                  style: IconButton.styleFrom(
                    backgroundColor: widget.showActiveFilters ? colorScheme.primary : colorScheme.primaryContainer,
                    foregroundColor: widget.showActiveFilters ? colorScheme.onPrimary : colorScheme.onPrimaryContainer,
                  ),
                ),
                // Active filters badge
                if (widget.activeFilterCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${widget.activeFilterCount}',
                        style: TextStyle(color: colorScheme.onError, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Search suggestions/hints
        if (hasText && widget.controller.text.length >= 2)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getSearchModeHint(),
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),

        // Active filters display
        if (widget.currentQuery?.hasActiveFilters == true)
          Container(margin: const EdgeInsets.only(top: 8), child: _buildActiveFiltersDisplay(context)),
      ],
    );
  }

  String _getSearchModeHint() {
    switch (_searchMode) {
      case 'name':
        return 'Searching by project name...';
      case 'client':
        return 'Searching by client information...';
      case 'address':
        return 'Searching by project address...';
      case 'capacity':
        return 'Searching by capacity. Use ">50", "<200", or "50-150" for ranges...';
      default:
        return 'Searching by project name, client info, and address...';
    }
  }

  Widget _buildActiveFiltersDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final query = widget.currentQuery!;
    final filters = <Widget>[];

    // Helper function to add filter chips
    void addFilterChip(String label, VoidCallback onRemove) {
      filters.add(
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 4),
          child: Chip(
            label: Text(label),
            onDeleted: onRemove,
            deleteIcon: const Icon(Icons.close, size: 16),
            backgroundColor: colorScheme.secondaryContainer,
            labelStyle: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 12),
          ),
        ),
      );
    }

    if (query.projectName?.isNotEmpty == true) {
      addFilterChip('Name: ${query.projectName}', () {
        widget.onQueryChanged?.call(query.copyWith(projectName: null));
      });
    }

    if (query.clientInfo?.isNotEmpty == true) {
      addFilterChip('Client: ${query.clientInfo}', () {
        widget.onQueryChanged?.call(query.copyWith(clientInfo: null));
      });
    }

    if (query.address?.isNotEmpty == true) {
      addFilterChip('Address: ${query.address}', () {
        widget.onQueryChanged?.call(query.copyWith(address: null));
      });
    }

    if (query.team?.isNotEmpty == true) {
      addFilterChip('Team: ${query.team}', () {
        widget.onQueryChanged?.call(query.copyWith(team: null));
      });
    }

    if (query.connectionType?.isNotEmpty == true) {
      addFilterChip('Connection: ${query.connectionType}', () {
        widget.onQueryChanged?.call(query.copyWith(connectionType: null));
      });
    }

    if (query.minCapacity != null || query.maxCapacity != null) {
      String capacityLabel = 'Capacity: ';
      if (query.minCapacity != null && query.maxCapacity != null) {
        capacityLabel += '${query.minCapacity!.toInt()}-${query.maxCapacity!.toInt()} kW';
      } else if (query.minCapacity != null) {
        capacityLabel += '>${query.minCapacity!.toInt()} kW';
      } else {
        capacityLabel += '<${query.maxCapacity!.toInt()} kW';
      }

      addFilterChip(capacityLabel, () {
        widget.onQueryChanged?.call(query.copyWith(minCapacity: null, maxCapacity: null));
      });
    }

    if (query.statuses?.isNotEmpty == true) {
      addFilterChip('Status: ${query.statuses!.join(", ")}', () {
        widget.onQueryChanged?.call(query.copyWith(statuses: null));
      });
    }

    if (filters.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Filters:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                widget.onQueryChanged?.call(query.clearFilters());
              },
              child: Text('Clear All', style: TextStyle(color: colorScheme.primary, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(children: filters),
      ],
    );
  }
}
