import 'package:flutter/material.dart';
import '../../domain/entities/notification_statistics.dart';

/// Widget for displaying notification statistics
class NotificationStatisticsWidget extends StatelessWidget {
  final NotificationStatistics statistics;
  final bool isCompact;

  const NotificationStatisticsWidget({
    super.key,
    required this.statistics,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactView(context);
    } else {
      return _buildFullView(context);
    }
  }

  Widget _buildCompactView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Unread',
                statistics.unreadCount.toString(),
                colorScheme.primary,
                Icons.mark_email_unread,
              ),
            ),
            Container(width: 1, height: 40, color: colorScheme.outline),
            Expanded(
              child: _buildStatItem(
                context,
                'Total',
                statistics.totalCount.toString(),
                colorScheme.onSurfaceVariant,
                Icons.email,
              ),
            ),
            Container(width: 1, height: 40, color: colorScheme.outline),
            Expanded(
              child: _buildStatItem(
                context,
                'Today',
                statistics.recentActivity.last24Hours.toString(),
                colorScheme.tertiary,
                Icons.today,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Statistics', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            // Overview stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Unread',
                    statistics.unreadCount.toString(),
                    colorScheme.primary,
                    Icons.mark_email_unread,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Read',
                    statistics.readCount.toString(),
                    colorScheme.secondary,
                    Icons.mark_email_read,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total',
                    statistics.totalCount.toString(),
                    colorScheme.onSurfaceVariant,
                    Icons.email,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Read %',
                    '${(statistics.readPercentage * 100).toInt()}%',
                    colorScheme.tertiary,
                    Icons.pie_chart,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent activity
            Text('Recent Activity', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildActivityChart(context),

            const SizedBox(height: 24),

            // Type breakdown
            Text('By Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildTypeBreakdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
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
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final maxValue = [
      statistics.recentActivity.last24Hours,
      statistics.recentActivity.lastWeek,
      statistics.recentActivity.lastMonth,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      children: [
        _buildActivityBar(
          context,
          'Last 24 Hours',
          statistics.recentActivity.last24Hours,
          maxValue,
          colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _buildActivityBar(
          context,
          'Last Week',
          statistics.recentActivity.lastWeek,
          maxValue,
          colorScheme.secondary,
        ),
        const SizedBox(height: 8),
        _buildActivityBar(
          context,
          'Last Month',
          statistics.recentActivity.lastMonth,
          maxValue,
          colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildActivityBar(
    BuildContext context,
    String label,
    int value,
    double maxValue,
    Color color,
  ) {
    final theme = Theme.of(context);
    final percentage = maxValue > 0 ? value / maxValue : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            value.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final sortedTypes = statistics.typeBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedTypes.isEmpty) {
      return Text('No notifications by type', style: theme.textTheme.bodySmall);
    }

    return Column(
      children: sortedTypes.take(5).map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatTypeName(entry.key),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.value.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatTypeName(String typeName) {
    // Convert camelCase to readable format
    return typeName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
