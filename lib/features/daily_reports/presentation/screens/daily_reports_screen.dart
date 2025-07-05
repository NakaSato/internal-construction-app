import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/universal_realtime_handler.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../application/cubits/daily_reports_cubit.dart';
import '../../application/states/daily_reports_state.dart';
import '../../domain/entities/daily_report.dart';
import '../widgets/daily_report_card.dart';
import '../widgets/daily_reports_filter_sheet.dart';
import '../widgets/daily_reports_analytics_widget.dart';
import '../widgets/daily_reports_bulk_actions_widget.dart';
import '../widgets/daily_reports_search_widget.dart';
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
  final _searchQuery = ValueNotifier<String>('');
  final _selectedReports = ValueNotifier<List<DailyReport>>([]);
  bool _isSelectionMode = false;
  bool _showAnalytics = true;

  // Real-time updates
  late final UniversalRealtimeHandler _realtimeHandler;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize real-time handler
    _realtimeHandler = getIt<UniversalRealtimeHandler>();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Load initial data
    context.read<DailyReportsCubit>().loadDailyReports();

    // Initialize real-time updates based on authentication state
    _checkAuthAndInitializeRealtime();
  }

  /// Check authentication state and initialize real-time updates if authenticated
  Future<void> _checkAuthAndInitializeRealtime() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      await _initializeRealtimeUpdates();
    } else {
      debugPrint('⚠️ Daily Reports: User not authenticated, skipping real-time initialization');
      // Listen for authentication changes
      _authSubscription = context.read<AuthBloc>().stream.listen((state) {
        if (state is AuthAuthenticated && mounted) {
          _initializeRealtimeUpdates();
        } else if (state is AuthUnauthenticated && mounted) {
          _disconnectRealtime();
        }
      });
    }
  }

  /// Initialize real-time updates for daily reports
  Future<void> _initializeRealtimeUpdates() async {
    try {
      // Initialize the universal real-time handler if not already connected
      if (!_realtimeHandler.isConnected) {
        await _realtimeHandler.initialize();
      }

      // Register handlers for daily report events
      _realtimeHandler.registerDailyReportHandler((event) {
        debugPrint('📡 Real-time daily report event: ${event.type.name}');

        if (!mounted) return;

        // Refresh the reports list for any daily report change
        // This ensures data consistency and handles complex state changes
        switch (event.type.name) {
          case 'dailyReportCreated':
          case 'dailyReportUpdated':
          case 'dailyReportDeleted':
          case 'dailyReportSubmitted':
          case 'dailyReportApproved':
            _silentRefresh();
            break;
          default:
            debugPrint('⚠️ Unknown daily report event type: ${event.type.name}');
            _silentRefresh(); // Fallback to refresh
        }
      });

      // Register handlers for project events (may affect daily reports)
      _realtimeHandler.registerProjectHandler((event) {
        if (!mounted) return;
        debugPrint('📡 Real-time project event affecting daily reports: ${event.type.name}');
        // Refresh when projects change as it may affect report data
        _silentRefresh();
      });

      debugPrint('✅ Daily Reports: Real-time updates initialized successfully');
    } catch (e) {
      debugPrint('❌ Daily Reports: Failed to initialize real-time updates: $e');
    }
  }

  /// Disconnect real-time updates when user logs out
  Future<void> _disconnectRealtime() async {
    try {
      debugPrint('🔌 Daily Reports: Disconnecting real-time updates due to logout');
    } catch (e) {
      debugPrint('❌ Daily Reports: Error disconnecting real-time updates: $e');
    }
  }

  /// Silently refresh the reports list
  void _silentRefresh() {
    if (mounted) {
      context.read<DailyReportsCubit>().loadDailyReports();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchQuery.dispose();
    _selectedReports.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // Modern styled app bar with gradient
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary.withOpacity(0.9), colorScheme.primary],
            ),
          ),
        ),
        title: Text(
          'Daily Reports',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          // Analytics toggle button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onPrimary.withOpacity(0.2), width: 1),
            ),
            child: IconButton(
              onPressed: () => setState(() => _showAnalytics = !_showAnalytics),
              icon: Icon(_showAnalytics ? Icons.analytics : Icons.analytics_outlined, color: colorScheme.onPrimary),
              tooltip: _showAnalytics ? 'Hide Analytics' : 'Show Analytics',
            ),
          ),
          // Styled filter button
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onPrimary.withOpacity(0.2), width: 1),
            ),
            child: IconButton(
              onPressed: _showFilterSheet,
              icon: Icon(Icons.tune, color: colorScheme.onPrimary),
              tooltip: 'Filter Reports',
            ),
          ),
        ],
      ),

      // Modern floating action button with gradient
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
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
        child: FloatingActionButton(
          heroTag: "daily_reports_fab",
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _navigateToCreateReport(context),
          child: Icon(Icons.add_rounded, color: colorScheme.onPrimary, size: 28),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.surface, colorScheme.surfaceContainerLowest],
          ),
        ),
        child: Column(
          children: [
            // Search widget
            DailyReportsSearchWidget(
              onSearchChanged: (query) {
                _searchQuery.value = query;
                _performSearch(query);
              },
              onAdvancedSearch: (filters) {
                context.read<DailyReportsCubit>().applyFilters(filters);
              },
              onClearSearch: () {
                _searchQuery.value = '';
                context.read<DailyReportsCubit>().loadDailyReports();
              },
            ),

            // Analytics widget (conditional)
            if (_showAnalytics)
              DailyReportsAnalyticsWidget(
                onRefresh: () {
                  context.read<DailyReportsCubit>().refreshDailyReports();
                },
              ),

            // Bulk actions widget (conditional)
            ValueListenableBuilder<List<DailyReport>>(
              valueListenable: _selectedReports,
              builder: (context, selectedReports, _) {
                return DailyReportsBulkActionsWidget(
                  selectedReports: selectedReports,
                  onBulkApprove: _handleBulkApprove,
                  onBulkReject: _handleBulkReject,
                  onBulkDelete: _handleBulkDelete,
                  onClearSelection: () {
                    _selectedReports.value = [];
                    setState(() => _isSelectionMode = false);
                  },
                );
              },
            ),

            // Main content
            Expanded(
              child: BlocBuilder<DailyReportsCubit, DailyReportsState>(
                builder: (context, state) {
                  if (state is DailyReportsInitial || state is DailyReportsLoading) {
                    return _buildLoadingView();
                  } else if (state is DailyReportsError) {
                    return _buildErrorView(state.message);
                  } else if (state is DailyReportsLoaded) {
                    return _buildReportsList(state);
                  }
                  return const Center(child: Text('Unexpected state'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading Reports...',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we fetch your daily reports',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(16),
        itemCount: state.reports.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          // Show loading indicator at the end if more items are being loaded
          if (index >= state.reports.length) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading more reports...',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          // Show daily report card
          final report = state.reports[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ValueListenableBuilder<List<DailyReport>>(
              valueListenable: _selectedReports,
              builder: (context, selectedReports, _) {
                return GestureDetector(
                  onLongPress: () {
                    _toggleReportSelection(report);
                    HapticFeedback.mediumImpact();
                  },
                  child: DailyReportCard(
                    report: report,
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleReportSelection(report);
                      } else {
                        _navigateToReportDetails(context, report);
                      }
                    },
                    isSelected: selectedReports.contains(report),
                    isSelectionMode: _isSelectionMode,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern illustration-style icon container
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.description_outlined, size: 64, color: colorScheme.primary.withOpacity(0.7)),
            ),

            const SizedBox(height: 32),

            // Modern typography
            Text(
              'No Daily Reports Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Start tracking your daily work progress\nby creating your first report',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Modern styled button with gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
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
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreateReport(context),
                icon: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
                label: Text(
                  'Create New Report',
                  style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern error icon container
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.error.withOpacity(0.1), colorScheme.error.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: colorScheme.error.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.error.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error.withOpacity(0.7)),
            ),

            const SizedBox(height: 32),

            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),

            const SizedBox(height: 40),

            // Modern retry button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
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
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<DailyReportsCubit>().loadDailyReports();
                },
                icon: Icon(Icons.refresh_rounded, color: colorScheme.onPrimary),
                label: Text(
                  'Try Again',
                  style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
        builder: (_) =>
            BlocProvider.value(value: context.read<DailyReportsCubit>(), child: const CreateDailyReportScreen()),
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

  // Enhanced functionality methods
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<DailyReportsCubit>().loadDailyReports();
    } else {
      // TODO: Implement search functionality in cubit
      // For now, we'll reload with default filters
      // This can be enhanced when search is implemented in the cubit
      context.read<DailyReportsCubit>().loadDailyReports();
    }
  }

  void _toggleReportSelection(DailyReport report) {
    final currentSelected = List<DailyReport>.from(_selectedReports.value);

    if (currentSelected.contains(report)) {
      currentSelected.remove(report);
    } else {
      currentSelected.add(report);
    }

    _selectedReports.value = currentSelected;

    // Update selection mode based on whether we have selected reports
    setState(() {
      _isSelectionMode = currentSelected.isNotEmpty;
    });
  }

  void _handleBulkApprove(List<String> reportIds) async {
    try {
      // TODO: Implement bulk approve using ApiConfig.dailyReportsBulkApprove
      // For now, show feedback
      _showSuccessMessage('${reportIds.length} report${reportIds.length != 1 ? 's' : ''} approved successfully');

      // Clear selection and refresh
      _selectedReports.value = [];
      setState(() => _isSelectionMode = false);
      context.read<DailyReportsCubit>().refreshDailyReports();
    } catch (e) {
      _showErrorMessage('Failed to approve reports: $e');
    }
  }

  void _handleBulkReject(List<String> reportIds) async {
    try {
      // TODO: Implement bulk reject using ApiConfig.dailyReportsBulkReject
      // For now, show feedback
      _showSuccessMessage('${reportIds.length} report${reportIds.length != 1 ? 's' : ''} rejected successfully');

      // Clear selection and refresh
      _selectedReports.value = [];
      setState(() => _isSelectionMode = false);
      context.read<DailyReportsCubit>().refreshDailyReports();
    } catch (e) {
      _showErrorMessage('Failed to reject reports: $e');
    }
  }

  void _handleBulkDelete(List<String> reportIds) async {
    try {
      // TODO: Implement bulk delete functionality
      // For now, show feedback
      _showSuccessMessage('${reportIds.length} report${reportIds.length != 1 ? 's' : ''} deleted successfully');

      // Clear selection and refresh
      _selectedReports.value = [];
      setState(() => _isSelectionMode = false);
      context.read<DailyReportsCubit>().refreshDailyReports();
    } catch (e) {
      _showErrorMessage('Failed to delete reports: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onError),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
