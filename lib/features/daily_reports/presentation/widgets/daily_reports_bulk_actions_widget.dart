import 'package:flutter/material.dart';

import '../../domain/entities/daily_report.dart';

/// Widget for bulk operations on daily reports
class DailyReportsBulkActionsWidget extends StatefulWidget {
  final List<DailyReport> selectedReports;
  final Function(List<String>) onBulkApprove;
  final Function(List<String>) onBulkReject;
  final Function(List<String>) onBulkDelete;
  final VoidCallback onClearSelection;

  const DailyReportsBulkActionsWidget({
    super.key,
    required this.selectedReports,
    required this.onBulkApprove,
    required this.onBulkReject,
    required this.onBulkDelete,
    required this.onClearSelection,
  });

  @override
  State<DailyReportsBulkActionsWidget> createState() => _DailyReportsBulkActionsWidgetState();
}

class _DailyReportsBulkActionsWidgetState extends State<DailyReportsBulkActionsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    if (widget.selectedReports.isNotEmpty) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(DailyReportsBulkActionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedReports.isEmpty && oldWidget.selectedReports.isNotEmpty) {
      _animationController.reverse();
    } else if (widget.selectedReports.isNotEmpty && oldWidget.selectedReports.isEmpty) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedReports.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with selection info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.check_box_outlined, color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.selectedReports.length} report${widget.selectedReports.length != 1 ? 's' : ''} selected',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        ),
                        Text(
                          'Choose an action to apply',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClearSelection,
                    icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                    tooltip: 'Clear Selection',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  // Approve button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Approve',
                      Icons.check_circle_outline,
                      colorScheme.tertiary,
                      _canApproveSelected() ? () => _showBulkApproveDialog(context) : null,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Reject button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Reject',
                      Icons.cancel_outlined,
                      colorScheme.error,
                      _canRejectSelected() ? () => _showBulkRejectDialog(context) : null,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Delete button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Delete',
                      Icons.delete_outline,
                      colorScheme.error,
                      () => _showBulkDeleteDialog(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback? onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null;

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: isEnabled ? color.withOpacity(0.1) : colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: isEnabled ? color : colorScheme.onSurfaceVariant.withOpacity(0.5), size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isEnabled ? color : colorScheme.onSurfaceVariant.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canApproveSelected() {
    return widget.selectedReports.any((report) => report.status == DailyReportStatus.submitted);
  }

  bool _canRejectSelected() {
    return widget.selectedReports.any((report) => report.status == DailyReportStatus.submitted);
  }

  void _showBulkApproveDialog(BuildContext context) {
    final approveableReports = widget.selectedReports
        .where((report) => report.status == DailyReportStatus.submitted)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Reports'),
        content: Text(
          'Are you sure you want to approve ${approveableReports.length} report${approveableReports.length != 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onBulkApprove(approveableReports.map((r) => r.reportId).toList());
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showBulkRejectDialog(BuildContext context) {
    final rejectableReports = widget.selectedReports
        .where((report) => report.status == DailyReportStatus.submitted)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Reports'),
        content: Text(
          'Are you sure you want to reject ${rejectableReports.length} report${rejectableReports.length != 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onBulkReject(rejectableReports.map((r) => r.reportId).toList());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reports'),
        content: Text(
          'Are you sure you want to delete ${widget.selectedReports.length} report${widget.selectedReports.length != 1 ? 's' : ''}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onBulkDelete(widget.selectedReports.map((r) => r.reportId).toList());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Remove duplicate enum definition
