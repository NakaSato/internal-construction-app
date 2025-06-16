import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/project_detail.dart';

class ProjectHeroSection extends StatelessWidget {
  const ProjectHeroSection({super.key, required this.projectDetail});

  final ProjectDetail projectDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
            colorScheme.primaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // More options
                    },
                    icon: Icon(Icons.more_vert, color: colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

            // Hero content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip
                  _buildStatusChip(context),

                  const SizedBox(height: 16),

                  // Project title
                  Text(
                    projectDetail.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Project description
                  Text(
                    projectDetail.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick stats row
                  _buildQuickStats(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = projectDetail.status.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.tertiary
            : theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.onTertiary
                  : theme.colorScheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            projectDetail.status,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isActive
                  ? theme.colorScheme.onTertiary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.timeline,
            label: 'Progress',
            value: '${projectDetail.progressPercentage.toStringAsFixed(0)}%',
            color: colorScheme.onPrimary,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: colorScheme.onPrimary.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.task_alt,
            label: 'Tasks',
            value:
                '${projectDetail.completedTasks}/${projectDetail.totalTasks}',
            color: colorScheme.onPrimary,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: colorScheme.onPrimary.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.account_balance_wallet,
            label: 'Budget',
            value: currencyFormat.format(projectDetail.budget),
            color: colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.9), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
