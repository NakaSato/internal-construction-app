import 'package:flutter/material.dart';
import '../../domain/entities/approval_statistics.dart';

class ApprovalDashboardScreen extends StatefulWidget {
  const ApprovalDashboardScreen({super.key});

  @override
  State<ApprovalDashboardScreen> createState() =>
      _ApprovalDashboardScreenState();
}

class _ApprovalDashboardScreenState extends State<ApprovalDashboardScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Mock data - replace with real data from cubit
  final ApprovalStatistics _mockStats = ApprovalStatistics(
    totalSubmitted: 45,
    totalApproved: 38,
    totalRejected: 7,
    pendingCount: 12,
    averageApprovalTime: 2.5,
    approvalRate: 84.4,
    byStatus: {'Pending': 12, 'Approved': 38, 'Rejected': 7},
    byPriority: {'Low': 15, 'Medium': 20, 'High': 8, 'Critical': 2},
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeCard(),
              const SizedBox(height: 16),
              _buildMetricsGrid(),
              const SizedBox(height: 16),
              _buildChartsSection(),
              const SizedBox(height: 16),
              _buildStatisticsCard(),
              const SizedBox(height: 16),
              _buildAdminActionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Range',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _showDateRangePicker,
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          'Total Submitted',
          _mockStats.totalSubmitted.toString(),
          Icons.assignment,
          Colors.blue,
        ),
        _buildMetricCard(
          'Total Approved',
          _mockStats.totalApproved.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildMetricCard(
          'Total Rejected',
          _mockStats.totalRejected.toString(),
          Icons.cancel,
          Colors.red,
        ),
        _buildMetricCard(
          'Pending',
          _mockStats.pendingCount.toString(),
          Icons.pending,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Breakdown Analysis',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatusBreakdownCard()),
            const SizedBox(width: 8),
            Expanded(child: _buildPriorityBreakdownCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBreakdownCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._mockStats.byStatus.entries.map((entry) {
              final total = _mockStats.totalSubmitted;
              final percentage = (entry.value / total * 100).round();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value} ($percentage%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBreakdownCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Priority',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._mockStats.byPriority.entries.map((entry) {
              final total = _mockStats.totalSubmitted;
              final percentage = (entry.value / total * 100).round();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value} ($percentage%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPriorityColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Average Approval Time',
                    '${_mockStats.averageApprovalTime} days',
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Approval Rate',
                    '${_mockStats.approvalRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, size: 32, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionsCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Tools',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showSendRemindersDialog,
                icon: const Icon(Icons.notifications),
                label: const Text('Send Approval Reminders'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.blue;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDateRangePicker() async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
      // TODO: Reload data with new date range
    }
  }

  void _showSendRemindersDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _SendRemindersDialog(
        onSend: (daysPending, includeEscalation) {
          Navigator.pop(context);
          // TODO: Implement send reminders
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Approval reminders sent successfully'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    // TODO: Implement refresh logic
    await Future.delayed(const Duration(seconds: 1));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SendRemindersDialog extends StatefulWidget {
  const _SendRemindersDialog({required this.onSend});

  final void Function(int daysPending, bool includeEscalation) onSend;

  @override
  State<_SendRemindersDialog> createState() => _SendRemindersDialogState();
}

class _SendRemindersDialogState extends State<_SendRemindersDialog> {
  int _daysPending = 2;
  bool _includeEscalation = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Approval Reminders'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Send reminders to approvers for requests that have been pending for a specified number of days.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Days pending: '),
              const Spacer(),
              DropdownButton<int>(
                value: _daysPending,
                items: [1, 2, 3, 5, 7].map((days) {
                  return DropdownMenuItem(
                    value: days,
                    child: Text('$days day${days != 1 ? 's' : ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _daysPending = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Include escalation option'),
            subtitle: const Text(
              'Allow approvers to escalate if they cannot approve',
            ),
            value: _includeEscalation,
            onChanged: (value) {
              setState(() {
                _includeEscalation = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => widget.onSend(_daysPending, _includeEscalation),
          child: const Text('Send Reminders'),
        ),
      ],
    );
  }
}
