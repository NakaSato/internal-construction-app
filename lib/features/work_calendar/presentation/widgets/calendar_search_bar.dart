import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/work_event.dart';
import '../../application/work_calendar_bloc.dart';
import '../../application/work_calendar_event.dart';
import '../../application/work_calendar_state.dart';
import 'event_list_widget.dart';

/// Search dialog for calendar events
class CalendarSearchDialog extends StatefulWidget {
  const CalendarSearchDialog({super.key});

  @override
  State<CalendarSearchDialog> createState() => _CalendarSearchDialogState();
}

class _CalendarSearchDialogState extends State<CalendarSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.search, color: Colors.blue),
        const SizedBox(width: 8),
        const Text(
          'Search Events',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search by title, description, or location...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
            : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: _onSearchChanged,
      onSubmitted: _performSearch,
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<WorkCalendarBloc, WorkCalendarState>(
      builder: (context, state) {
        if (state is WorkCalendarLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Searching events...'),
              ],
            ),
          );
        } else if (state is CalendarSearchResultsLoaded) {
          return _buildResultsList(state.results, state.query);
        } else {
          return _buildInitialState();
        }
      },
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search Your Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter keywords to find events by title,\ndescription, or location',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          _buildQuickSearchChips(),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChips() {
    final quickSearchTerms = [
      'meeting',
      'deadline',
      'task',
      'appointment',
      'training',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickSearchTerms.map((term) {
        return ActionChip(
          label: Text(term),
          onPressed: () {
            _searchController.text = term;
            _performSearch(term);
          },
          backgroundColor: Colors.grey[100],
        );
      }).toList(),
    );
  }

  Widget _buildResultsList(List<WorkEvent> results, String query) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Events Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No events match "$query"',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Found ${results.length} event${results.length == 1 ? '' : 's'} for "$query"',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: EventListWidget(
            events: results,
            onEventTap: (event) {
              Navigator.of(context).pop();
              // You could navigate to event details here
            },
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    setState(() {}); // Rebuild to show/hide clear button

    if (value.trim().isEmpty) {
      // Clear search results when text is empty
      // Don't perform search for empty queries
      return;
    }

    // Debounce search to avoid too many API calls
    _debounceSearch(value);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    context.read<WorkCalendarBloc>().add(CalendarEventsSearched(query.trim()));
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    _searchFocusNode.requestFocus();
  }

  // Simple debounce implementation
  Timer? _debounceTimer;

  void _debounceSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }
}
