import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/cubits/daily_reports_cubit.dart';
import '../../application/states/daily_reports_state.dart';
import '../../domain/entities/daily_report.dart';
import '../widgets/daily_report_card.dart';
import '../widgets/daily_reports_filter_sheet.dart';
import 'create_daily_report_screen.dart';
import 'daily_report_details_screen.dart';

/// Screen to display a list of daily reports with filtering and pagination
class DailyReportsScreen extends StatefulWidget {
  const DailyReportsScreen({super.key});

  @override
  State<DailyReportsScreen> createState() => _DailyReportsScreenState();
}

class _DailyReportsScreenState extends State<DailyReportsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
    // Load initial data
    context.read<DailyReportsCubit>().loadDailyReports();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<DailyReportsCubit>().loadMoreReports();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more data when we're 80% of the way to the bottom
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reports'),
        actions: [
          // Filter button
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Reports',
          ),
        ],
      ),

      // Floating action button to create a new report
      floatingActionButton: FloatingActionButton(
        heroTag: "daily_reports_fab",
        onPressed: () => _navigateToCreateReport(context),
        child: const Icon(Icons.add),
      ),

      body: BlocBuilder<DailyReportsCubit, DailyReportsState>(
        builder: (context, state) {
          if (state is DailyReportsInitial || state is DailyReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DailyReportsError) {
            return _buildErrorView(state.message);
          } else if (state is DailyReportsLoaded) {
            return _buildReportsList(state);
          }
          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }

  Widget _buildReportsList(DailyReportsLoaded state) {
    if (state.reports.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DailyReportsCubit>().refreshDailyReports();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.reports.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          // Show loading indicator at the end if more items are being loaded
          if (index >= state.reports.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Show daily report card
          final report = state.reports[index];
          return DailyReportCard(
            report: report,
            onTap: () => _navigateToReportDetails(context, report),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No daily reports found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new report to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateReport(context),
            icon: const Icon(Icons.add),
            label: const Text('Create New Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading reports',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DailyReportsCubit>().loadDailyReports();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    final state = context.read<DailyReportsCubit>().state;
    if (state is! DailyReportsLoaded) return;

    // Create mock data for projects and technicians
    // In a real app, we'd get this from the repository
    final projects = [
      ProjectOption(id: 'proj1', name: 'Solar Installation Alpha'),
      ProjectOption(id: 'proj2', name: 'Commercial Rooftop Retrofit'),
      ProjectOption(id: 'proj3', name: 'Residential Solar Array'),
    ];

    final technicians = [
      TechnicianOption(id: 'tech1', name: 'John Technician'),
      TechnicianOption(id: 'tech2', name: 'Jane Smith'),
      TechnicianOption(id: 'tech3', name: 'Robert Engineer'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: DailyReportsFilterSheet(
                  initialFilters: state.activeFilters,
                  projects: projects,
                  technicians: technicians,
                  onApplyFilters: (filters) {
                    context.read<DailyReportsCubit>().applyFilters(filters);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToCreateReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DailyReportsCubit>(),
          child: const CreateDailyReportScreen(),
        ),
      ),
    );
  }

  void _navigateToReportDetails(BuildContext context, DailyReport report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DailyReportsCubit>(),
          child: DailyReportDetailsScreen(reportId: report.reportId),
        ),
      ),
    );
  }
}
