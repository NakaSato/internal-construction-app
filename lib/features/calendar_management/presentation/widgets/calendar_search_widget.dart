import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_event.dart';

/// Widget for searching calendar events
class CalendarSearchWidget extends StatefulWidget {
  const CalendarSearchWidget({super.key});

  @override
  State<CalendarSearchWidget> createState() => _CalendarSearchWidgetState();
}

class _CalendarSearchWidgetState extends State<CalendarSearchWidget> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search Events',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search input
              TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Query',
                  hintText: 'Enter keywords to search for...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a search query';
                  }
                  if (value.trim().length < 2) {
                    return 'Search query must be at least 2 characters';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _performSearch(),
              ),
              const SizedBox(height: 16),

              // Search tips
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Tips:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Search in titles, descriptions, and locations',
                      ),
                      const Text('• Use multiple keywords for better results'),
                      const Text('• Search is case-insensitive'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: const Text('Search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch() {
    if (_formKey.currentState?.validate() == true) {
      final query = _searchController.text.trim();
      context.read<CalendarManagementBloc>().add(CalendarEventsSearched(query));
      Navigator.of(context).pop();
    }
  }
}
