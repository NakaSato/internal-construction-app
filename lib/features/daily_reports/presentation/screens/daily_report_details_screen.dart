import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart' show Share;

import '../../application/cubits/daily_reports_cubit.dart';
import '../../application/states/daily_reports_state.dart';
import '../../domain/entities/daily_report.dart';
import 'create_daily_report_screen.dart';

/// Screen to display details of a daily report
class DailyReportDetailsScreen extends StatefulWidget {
  final String reportId;

  const DailyReportDetailsScreen({super.key, required this.reportId});

  @override
  State<DailyReportDetailsScreen> createState() =>
      _DailyReportDetailsScreenState();
}

class _DailyReportDetailsScreenState extends State<DailyReportDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load report details
    context.read<DailyReportsCubit>().getDailyReportById(widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          BlocBuilder<DailyReportsCubit, DailyReportsState>(
            buildWhen: (previous, current) =>
                current is DailyReportDetailLoaded,
            builder: (context, state) {
              if (state is DailyReportDetailLoaded) {
                return _buildActionButtons(context, state.report);
              }
              return Container();
            },
          ),
        ],
      ),
      body: BlocConsumer<DailyReportsCubit, DailyReportsState>(
        listenWhen: (previous, current) =>
            current is DailyReportOperationSuccess ||
            current is DailyReportOperationError,
        listener: (context, state) {
          if (state is DailyReportOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            if (state.message.contains('deleted')) {
              Navigator.pop(context);
            }
          } else if (state is DailyReportOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is DailyReportDetailLoading ||
            current is DailyReportDetailError ||
            current is DailyReportDetailLoaded,
        builder: (context, state) {
          if (state is DailyReportDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DailyReportDetailError) {
            return _buildErrorView(state.message);
          } else if (state is DailyReportDetailLoaded) {
            return _buildReportDetails(state.report);
          }
          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }

  Widget _buildReportDetails(DailyReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          _buildHeaderCard(report),
          const SizedBox(height: 16),

          // Details sections
          ..._buildDetailsSection(report),
          const SizedBox(height: 16),

          // Work progress items
          if (report.workProgressItems.isNotEmpty) ...[
            _buildSectionTitle('Work Progress'),
            const SizedBox(height: 8),
            ...report.workProgressItems.map(
              (item) => _buildWorkProgressItem(item),
            ),
            const SizedBox(height: 16),
          ],

          // Personnel logs
          if (report.personnelLogs.isNotEmpty) ...[
            _buildSectionTitle('Personnel'),
            const SizedBox(height: 8),
            ...report.personnelLogs.map((log) => _buildPersonnelLog(log)),
            const SizedBox(height: 16),
          ],

          // Material usage
          if (report.materialUsage.isNotEmpty) ...[
            _buildSectionTitle('Materials Used'),
            const SizedBox(height: 8),
            ...report.materialUsage.map(
              (material) => _buildMaterialUsage(material),
            ),
            const SizedBox(height: 16),
          ],

          // Equipment logs
          if (report.equipmentLogs.isNotEmpty) ...[
            _buildSectionTitle('Equipment Used'),
            const SizedBox(height: 8),
            ...report.equipmentLogs.map(
              (equipment) => _buildEquipmentLog(equipment),
            ),
            const SizedBox(height: 16),
          ],

          // Image gallery
          _buildSectionTitle('Photos (${report.photosCount})'),
          const SizedBox(height: 8),
          _buildImageGallery(report),
          const SizedBox(height: 16),

          // Location map
          _buildSectionTitle('Location'),
          const SizedBox(height: 8),
          _buildLocationMap(report),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(DailyReport report) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.project?.projectName ?? 'Unknown Project',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(report.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Report Date: ${DateFormat('MMMM d, yyyy').format(report.reportDate)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Created by: ${report.technician?.fullName ?? 'Unknown User'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (report.submittedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Submitted: ${DateFormat('MMM d, yyyy - h:mm a').format(report.submittedAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (report.approvedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Approved: ${DateFormat('MMM d, yyyy - h:mm a').format(report.approvedAt!)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            ],
            if (report.rejectedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Rejected: ${DateFormat('MMM d, yyyy - h:mm a').format(report.rejectedAt!)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailsSection(DailyReport report) {
    return [
      _buildSectionTitle('Work Details'),
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Work Hours',
                '${report.workStartTime} - ${report.workEndTime}',
              ),
              const Divider(height: 24),
              _buildDetailRow('Weather', report.weatherConditions),
              const Divider(height: 24),
              _buildDetailLabel('Overall Notes'),
              const SizedBox(height: 4),
              Text(
                report.overallNotes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildDetailLabel('Safety Notes'),
              const SizedBox(height: 4),
              Text(
                report.safetyNotes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (report.delaysOrIssues.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailLabel('Delays/Issues'),
                const SizedBox(height: 4),
                Text(
                  report.delaysOrIssues,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.orange[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildDetailLabel(String label) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildWorkProgressItem(WorkProgressItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.taskDescription,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.percentageComplete}% Complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.hoursWorked} hours',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.notes, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelLog(PersonnelLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                log.personnelName.isNotEmpty
                    ? log.personnelName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.personnelName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(log.role, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${log.hoursWorked} hrs',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (log.overtimeHours > 0)
                  Text(
                    '${log.overtimeHours} hrs OT',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.orange[700]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialUsage(MaterialUsage material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.category,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.materialName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (material.notes.isNotEmpty)
                    Text(
                      material.notes,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${material.quantityUsed} ${material.unit}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentLog(EquipmentLog equipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.construction,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.equipmentName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    equipment.equipmentLogId,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '${equipment.usageHours} hrs',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(DailyReport report) {
    // In a real app, we'd fetch actual images from the API
    // For now, we'll use placeholder images

    if (report.photosCount == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No photos available')),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: PageView.builder(
          itemCount: report.photosCount,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                // Image would be loaded from network in a real app
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.photo,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                // Image counter
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Image ${index + 1} of ${report.photosCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationMap(DailyReport report) {
    // In a real app, we'd use actual coordinates from the report
    // For now, we'll use a placeholder location
    const defaultLocation = LatLng(37.7749, -122.4194); // San Francisco

    return SizedBox(
      height: 200,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          options: const MapOptions(center: defaultLocation, zoom: 13),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            const MarkerLayer(
              markers: [
                Marker(
                  width: 30,
                  height: 30,
                  point: defaultLocation,
                  child: Icon(Icons.location_pin, color: Colors.red, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusChip(DailyReportStatus status) {
    Color color;
    String label;

    switch (status) {
      case DailyReportStatus.draft:
        color = Colors.grey;
        label = 'DRAFT';
        break;
      case DailyReportStatus.submitted:
        color = Colors.blue;
        label = 'SUBMITTED';
        break;
      case DailyReportStatus.approved:
        color = Colors.green;
        label = 'APPROVED';
        break;
      case DailyReportStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
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
              'Error loading report',
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
                context.read<DailyReportsCubit>().getDailyReportById(
                  widget.reportId,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DailyReport report) {
    return Row(
      children: [
        // Only show edit/delete for drafts or if the user is the creator
        if (report.status == DailyReportStatus.draft ||
            report.status == DailyReportStatus.rejected) ...[
          IconButton(
            onPressed: () => _navigateToEditReport(context, report),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Report',
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, report),
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Report',
          ),
        ],

        // Share button
        IconButton(
          onPressed: () => _shareReport(report),
          icon: const Icon(Icons.share),
          tooltip: 'Share Report',
        ),
      ],
    );
  }

  void _navigateToEditReport(BuildContext context, DailyReport report) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CreateDailyReportScreen(report: report),
          ),
        )
        .then((_) {
          // Refresh the report details when returning from edit screen
          context.read<DailyReportsCubit>().getDailyReportById(widget.reportId);
        });
  }

  void _showDeleteConfirmation(BuildContext context, DailyReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report?'),
        content: Text(
          'Are you sure you want to delete this report from ${DateFormat('MMM d, yyyy').format(report.reportDate)}?'
          ' This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DailyReportsCubit>().deleteDailyReport(
                report.reportId,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareReport(DailyReport report) {
    final projectName = report.project?.projectName ?? 'Unknown Project';
    final date = DateFormat('MMM d, yyyy').format(report.reportDate);
    final technicianName = report.technician?.fullName ?? 'Unknown';
    final workTime = '${report.workStartTime} - ${report.workEndTime}';

    // Create a detailed summary
    final text =
        'DAILY REPORT SUMMARY\n\n'
        'Project: $projectName\n'
        'Date: $date\n'
        'Status: ${report.status.displayName}\n'
        'Technician: $technicianName\n'
        'Work Hours: $workTime\n'
        'Weather: ${report.weatherConditions}\n\n'
        'NOTES:\n${report.overallNotes}\n\n'
        'SAFETY NOTES:\n${report.safetyNotes}\n\n';

    // Add work progress items if available
    if (report.workProgressItems.isNotEmpty) {
      final progressText = report.workProgressItems
          .map(
            (item) =>
                '- ${item.taskDescription} (${item.percentageComplete}% complete, ${item.hoursWorked} hours)',
          )
          .join('\n');

      final workProgressSection = 'WORK COMPLETED:\n$progressText\n\n';
      Share.share(
        text + workProgressSection,
        subject: 'Daily Report - $projectName - $date',
      );
    } else {
      Share.share(text, subject: 'Daily Report - $projectName - $date');
    }

    // In a real app, we could:
    // 1. Generate a PDF with reportlab_flutter or similar
    // 2. Create a shareable link to view the report online
    // 3. Include images as attachments
  }
}
