import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project.dart';
import '../../../../authentication/domain/entities/user.dart';
import '../../../../daily_reports/application/cubits/daily_reports_cubit.dart';
import '../../../../daily_reports/application/states/daily_reports_state.dart';
import '../../../../daily_reports/domain/entities/daily_report.dart';
import 'constants.dart';
import 'daily_reports_helpers.dart';
import 'utils.dart';

/// Tab content builders for project detail screen
class ProjectDetailTabBuilders {
  /// Build overview tab
  static Widget buildOverviewTab(
    BuildContext context,
    Project project,
    User user,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ProjectDetailConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedStatsSection(context, project),
          const SizedBox(height: ProjectDetailConstants.largeSpacing),
          _buildEnhancedDescriptionSection(context, project),
          const SizedBox(height: ProjectDetailConstants.largeSpacing),
          _buildEnhancedDetailsSection(context, project),
        ],
      ),
    );
  }

  /// Build progress tab
  static Widget buildProgressTab(BuildContext context, Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ProjectDetailConstants.cardPadding),
      child: Column(
        children: [_buildEnhancedProgressSection(context, project)],
      ),
    );
  }

  /// Build tasks tab
  static Widget buildTasksTab(BuildContext context, Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ProjectDetailConstants.cardPadding),
      child: Column(children: [_buildEnhancedTasksSection(context, project)]),
    );
  }

  /// Build daily reports tab
  static Widget buildDailyReportsTab(
    BuildContext context,
    Project project,
    User user,
    UserRole currentUserRole,
    Function(Project) onNavigateToCreateReport,
    Function(Project) onNavigateToDailyReports,
    Function(DailyReport) onViewReportDetails,
    VoidCallback onLoadProjectReports,
  ) {
    final isUser = currentUserRole.isFieldUser;
    final isManagerOrAdmin = currentUserRole.hasFullAccess;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ProjectDetailConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyReportsHeader(
            context,
            isUser,
            isManagerOrAdmin,
            project,
            onNavigateToCreateReport,
            onNavigateToDailyReports,
          ),
          const SizedBox(height: ProjectDetailConstants.cardPadding),
          if (isUser)
            _buildUserDailyReportsContent(
              context,
              project,
              user,
              onNavigateToCreateReport,
              onViewReportDetails,
              onLoadProjectReports,
            )
          else if (isManagerOrAdmin)
            _buildManagerAdminDailyReportsContent(
              context,
              project,
              user,
              onNavigateToDailyReports,
              onViewReportDetails,
              onLoadProjectReports,
            ),
        ],
      ),
    );
  }

  // Private helper methods

  static Widget _buildEnhancedStatsSection(
    BuildContext context,
    Project project,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Overview',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: ProjectDetailConstants.defaultSpacing),
        // ProjectStatsWidget would be imported and used here
        const Placeholder(fallbackHeight: 200), // Replace with actual widget
      ],
    );
  }

  static Widget _buildEnhancedDescriptionSection(
    BuildContext context,
    Project project,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          ProjectDetailConstants.borderRadius,
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(ProjectDetailConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Description',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: ProjectDetailConstants.defaultSpacing),
          // ProjectDescriptionWidget would be imported and used here
          const Placeholder(fallbackHeight: 100), // Replace with actual widget
        ],
      ),
    );
  }

  static Widget _buildEnhancedDetailsSection(
    BuildContext context,
    Project project,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ProjectDetailConstants.defaultSpacing),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(
              ProjectDetailConstants.borderRadius,
            ),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: const Placeholder(
            fallbackHeight: 200,
          ), // Replace with ProjectDetailsWidget
        ),
      ],
    );
  }

  static Widget _buildEnhancedProgressSection(
    BuildContext context,
    Project project,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress & Budget',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ProjectDetailConstants.defaultSpacing),
        const Placeholder(
          fallbackHeight: 300,
        ), // Replace with ProjectProgressWidget
      ],
    );
  }

  static Widget _buildEnhancedTasksSection(
    BuildContext context,
    Project project,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                ProjectDetailUtils.showFeatureComingSoonSnackBar(
                  context,
                  'Task management',
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: ProjectDetailConstants.defaultSpacing),
        const Placeholder(
          fallbackHeight: 300,
        ), // Replace with ProjectTasksWidget
      ],
    );
  }

  static Widget _buildDailyReportsHeader(
    BuildContext context,
    bool isUser,
    bool isManagerOrAdmin,
    Project project,
    Function(Project) onNavigateToCreateReport,
    Function(Project) onNavigateToDailyReports,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isUser ? 'Add Daily Report' : 'Daily Reports',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isUser)
          FilledButton.icon(
            onPressed: () => onNavigateToCreateReport(project),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Report'),
          ),
        if (isManagerOrAdmin)
          TextButton.icon(
            onPressed: () => onNavigateToDailyReports(project),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('View All'),
          ),
      ],
    );
  }

  static Widget _buildUserDailyReportsContent(
    BuildContext context,
    Project project,
    User user,
    Function(Project) onNavigateToCreateReport,
    Function(DailyReport) onViewReportDetails,
    VoidCallback onLoadProjectReports,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DailyReportsHelpers.buildCreateReportCard(
          context,
          () => onNavigateToCreateReport(project),
        ),
        const SizedBox(height: ProjectDetailConstants.cardPadding),
        Text(
          'Your Recent Reports',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildUserRecentReports(
          context,
          project,
          user,
          onViewReportDetails,
          onLoadProjectReports,
        ),
      ],
    );
  }

  static Widget _buildManagerAdminDailyReportsContent(
    BuildContext context,
    Project project,
    User user,
    Function(Project) onNavigateToDailyReports,
    Function(DailyReport) onViewReportDetails,
    VoidCallback onLoadProjectReports,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reports overview stats
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reports Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DailyReportsHelpers.buildReportStatCard(
                        context,
                        'This Week',
                        '12',
                        Icons.today,
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DailyReportsHelpers.buildReportStatCard(
                        context,
                        'This Month',
                        '45',
                        Icons.calendar_month,
                        theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DailyReportsHelpers.buildReportStatCard(
                        context,
                        'Team Members',
                        '8',
                        Icons.people,
                        theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Recent reports from all team members
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Team Reports',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () => onNavigateToDailyReports(project),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTeamRecentReports(
          context,
          project,
          user,
          onViewReportDetails,
          onLoadProjectReports,
        ),
      ],
    );
  }

  static Widget _buildUserRecentReports(
    BuildContext context,
    Project project,
    User user,
    Function(DailyReport) onViewReportDetails,
    VoidCallback onLoadProjectReports,
  ) {
    return BlocBuilder<DailyReportsCubit, DailyReportsState>(
      builder: (context, state) {
        if (state is DailyReportsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DailyReportsLoaded) {
          // Filter reports by current user (technician)
          final userReports = state.reports
              .where((report) => report.technicianId == user.userId)
              .take(3) // Show only the 3 most recent
              .toList();

          if (userReports.isEmpty) {
            return _buildEmptyReportsCard(
              context,
              'No reports yet',
              'Create your first daily report to get started',
            );
          }

          return Column(
            children: userReports.map((report) {
              return _buildReportCard(
                context,
                report,
                user.fullName,
                onViewReportDetails,
              );
            }).toList(),
          );
        }

        // Show empty state for error or other states
        return _buildErrorReportsCard(context, onLoadProjectReports);
      },
    );
  }

  static Widget _buildTeamRecentReports(
    BuildContext context,
    Project project,
    User user,
    Function(DailyReport) onViewReportDetails,
    VoidCallback onLoadProjectReports,
  ) {
    return BlocBuilder<DailyReportsCubit, DailyReportsState>(
      builder: (context, state) {
        if (state is DailyReportsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DailyReportsLoaded) {
          // Show all team reports (not filtered by user)
          final teamReports = state.reports.take(5).toList(); // Show recent 5

          if (teamReports.isEmpty) {
            return _buildEmptyReportsCard(context, 'No team reports yet', null);
          }

          return Column(
            children: teamReports.map((report) {
              final technicianName =
                  report.technician?.fullName ?? 'Unknown User';
              return _buildTeamReportCard(
                context,
                report,
                technicianName,
                onViewReportDetails,
              );
            }).toList(),
          );
        }

        // Show error state
        return _buildErrorReportsCard(context, onLoadProjectReports);
      },
    );
  }

  static Widget _buildReportCard(
    BuildContext context,
    DailyReport report,
    String userName,
    Function(DailyReport) onViewReportDetails,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: DailyReportsHelpers.getStatusColor(
            report.status,
            theme,
          ),
          child: Icon(
            DailyReportsHelpers.getStatusIcon(report.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          ProjectDetailUtils.formatReportDate(report.reportDate),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${report.workStartTime} - ${report.workEndTime}'),
            if (report.workProgressItems.isNotEmpty)
              Text(
                report.workProgressItems.first.taskDescription,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            report.status.displayName,
            style: theme.textTheme.bodySmall,
          ),
          backgroundColor: DailyReportsHelpers.getStatusColor(
            report.status,
            theme,
          ).withValues(alpha: 0.2),
          side: BorderSide.none,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onTap: () => onViewReportDetails(report),
      ),
    );
  }

  static Widget _buildTeamReportCard(
    BuildContext context,
    DailyReport report,
    String technicianName,
    Function(DailyReport) onViewReportDetails,
  ) {
    final theme = Theme.of(context);
    final initials = ProjectDetailUtils.getInitials(technicianName);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            initials,
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                technicianName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              ProjectDetailUtils.formatReportDate(report.reportDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${report.workStartTime} - ${report.workEndTime}'),
            if (report.workProgressItems.isNotEmpty)
              Text(
                report.workProgressItems.first.taskDescription,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: () => onViewReportDetails(report),
      ),
    );
  }

  static Widget _buildEmptyReportsCard(
    BuildContext context,
    String title,
    String? subtitle,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.note_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildErrorReportsCard(
    BuildContext context,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load reports',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
