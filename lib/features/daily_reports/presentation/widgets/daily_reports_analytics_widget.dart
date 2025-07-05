import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/cubits/daily_reports_cubit.dart';
import '../../application/states/daily_reports_state.dart';
import '../../domain/entities/daily_report.dart';

/// Widget to display daily reports analytics and insights
class DailyReportsAnalyticsWidget extends StatelessWidget {
  final String? projectId;
  final VoidCallback? onRefresh;

  const DailyReportsAnalyticsWidget({super.key, this.projectId, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primaryContainer.withOpacity(0.1), colorScheme.primaryContainer.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.analytics_outlined, color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Reports Analytics',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                ],
              ),
              if (onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  icon: Icon(Icons.refresh_rounded, color: colorScheme.primary, size: 20),
                  tooltip: 'Refresh Analytics',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Analytics Cards
          BlocBuilder<DailyReportsCubit, DailyReportsState>(
            builder: (context, state) {
              if (state is DailyReportsLoaded) {
                return _buildAnalyticsCards(context, state);
              } else if (state is DailyReportsLoading) {
                return _buildLoadingAnalytics(context);
              } else {
                return _buildEmptyAnalytics(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards(BuildContext context, DailyReportsLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate analytics from loaded reports
    final totalReports = state.reports.length;
    final pendingReports = state.reports
        .where((r) => r.status == DailyReportStatus.draft || r.status == DailyReportStatus.submitted)
        .length;
    final approvedReports = state.reports.where((r) => r.status == DailyReportStatus.approved).length;

    return Column(
      children: [
        // Primary metrics row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Reports',
                totalReports.toString(),
                Icons.description_outlined,
                colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Approved',
                approvedReports.toString(),
                Icons.check_circle_outline,
                colorScheme.tertiary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Secondary metrics row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Pending',
                pendingReports.toString(),
                Icons.pending_outlined,
                colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Completion',
                totalReports > 0 ? '${((approvedReports / totalReports) * 100).toStringAsFixed(0)}%' : '0%',
                Icons.trending_up_outlined,
                colorScheme.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick actions
        Row(
          children: [
            Expanded(
              child: _buildActionButton(context, 'Export Data', Icons.download_outlined, () => _exportReports(context)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Weekly Report',
                Icons.calendar_view_week_outlined,
                () => _generateWeeklyReport(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildLoadingAnalytics(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading analytics...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAnalytics(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, color: colorScheme.onSurfaceVariant.withOpacity(0.5), size: 32),
          const SizedBox(height: 8),
          Text(
            'No analytics available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _exportReports(BuildContext context) {
    // TODO: Implement export functionality using ApiConfig.dailyReportsExport
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export functionality will be implemented'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _generateWeeklyReport(BuildContext context) {
    // TODO: Implement weekly report using ApiConfig.dailyReportsWeeklySummary
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weekly report generation will be implemented'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
}

// Define the missing enum if not already defined
// Remove duplicate enum definition
