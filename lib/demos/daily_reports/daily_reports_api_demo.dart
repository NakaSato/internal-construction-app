import 'package:flutter/material.dart';

import 'daily_reports/domain/entities/daily_report.dart';

/// Comprehensive demo showcasing the Daily Reports Management API functionality
class DailyReportsApiDemo extends StatefulWidget {
  const DailyReportsApiDemo({super.key});

  @override
  State<DailyReportsApiDemo> createState() => _DailyReportsApiDemoState();
}

class _DailyReportsApiDemoState extends State<DailyReportsApiDemo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Daily Reports Management'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Reports'),
            Tab(icon: Icon(Icons.info), text: 'Status & Workflow'),
            Tab(icon: Icon(Icons.api), text: 'API Features'),
            Tab(icon: Icon(Icons.book), text: 'Documentation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          _buildStatusWorkflowTab(),
          _buildApiTab(),
          _buildDocumentationTab(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthBanner(),
          const SizedBox(height: 24),
          _buildFilterSection(),
          const SizedBox(height: 24),
          Text(
            'Recent Daily Reports',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._generateMockReports().map((report) => _ReportCard(report: report)),
        ],
      ),
    );
  }

  Widget _buildAuthBanner() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔒 Authentication Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This API requires authentication for all operations',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters & Search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(label: 'All Projects', isSelected: true),
                _FilterChip(label: 'Draft', color: DailyReportStatus.draft.color),
                _FilterChip(label: 'Submitted', color: DailyReportStatus.submitted.color),
                _FilterChip(label: 'Approved', color: DailyReportStatus.approved.color),
                _FilterChip(label: 'Rejected', color: DailyReportStatus.rejected.color),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search reports...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.date_range),
                  tooltip: 'Date Filter',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWorkflowTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Status Workflow',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Reports follow a structured workflow: Draft → Submitted → Approved/Rejected',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildWorkflowDiagram(),
          const SizedBox(height: 32),
          Text(
            'Status Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...DailyReportStatus.values.map((status) => _StatusCard(status: status)),
        ],
      ),
    );
  }

  Widget _buildWorkflowDiagram() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WorkflowStep(
                  status: DailyReportStatus.draft,
                  isFirst: true,
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _WorkflowStep(status: DailyReportStatus.submitted),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                Column(
                  children: [
                    _WorkflowStep(status: DailyReportStatus.approved),
                    const SizedBox(height: 8),
                    const Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _WorkflowStep(status: DailyReportStatus.rejected),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API Features',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildApiFeatureCard(
            'HATEOAS Support',
            'Hypermedia as the Engine of Application State for enhanced API navigation',
            Icons.link,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildApiFeatureCard(
            'Advanced Caching',
            '5-minute cache duration for optimal performance',
            Icons.cached,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildApiFeatureCard(
            'Role-Based Access',
            'Technician, ProjectManager, Administrator roles',
            Icons.security,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildApiFeatureCard(
            'Comprehensive Filtering',
            'Filter by project, technician, status, date range',
            Icons.filter_list,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          Text(
            'API Endpoints',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildApiEndpoints(),
        ],
      ),
    );
  }

  Widget _buildApiFeatureCard(String title, String description, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildApiEndpoints() {
    final endpoints = [
      {'method': 'GET', 'path': '/api/v1/daily-reports', 'description': 'Get all daily reports'},
      {'method': 'GET', 'path': '/api/v1/daily-reports/{id}', 'description': 'Get report by ID'},
      {'method': 'POST', 'path': '/api/v1/daily-reports', 'description': 'Create daily report'},
      {'method': 'PUT', 'path': '/api/v1/daily-reports/{id}', 'description': 'Update daily report'},
      {'method': 'POST', 'path': '/api/v1/daily-reports/{id}/submit', 'description': 'Submit report'},
      {'method': 'POST', 'path': '/api/v1/daily-reports/{id}/approve', 'description': 'Approve report'},
      {'method': 'POST', 'path': '/api/v1/daily-reports/{id}/reject', 'description': 'Reject report'},
      {'method': 'DELETE', 'path': '/api/v1/daily-reports/{id}', 'description': 'Delete report'},
    ];

    return endpoints.map((endpoint) => _EndpointCard(
      method: endpoint['method']!,
      path: endpoint['path']!,
      description: endpoint['description']!,
    )).toList();
  }

  Widget _buildDocumentationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Reports API Documentation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDocSection(
            'Overview',
            'The Daily Reports API manages comprehensive field reports for solar installation projects. '
            'Reports support a structured workflow with status tracking, work progress, personnel logs, '
            'material usage, and equipment tracking.',
          ),
          const SizedBox(height: 16),
          _buildDocSection(
            'Authentication',
            'All endpoints require proper authentication. Include the Bearer token in the Authorization header.',
          ),
          const SizedBox(height: 16),
          _buildDocSection(
            'Caching',
            'Read operations are cached for 5 minutes to optimize performance. Cache is automatically '
            'invalidated when data is modified.',
          ),
          const SizedBox(height: 16),
          _buildDocSection(
            'Pagination',
            'List endpoints support pagination with pageNumber, pageSize parameters. '
            'Default page size is 10, maximum is 100.',
          ),
          const SizedBox(height: 16),
          _buildDocSection(
            'Sub-Resources',
            'Each report can contain work progress items, personnel logs, material usage, and equipment logs. '
            'These are managed through dedicated sub-resource endpoints.',
          ),
        ],
      ),
    );
  }

  Widget _buildDocSection(String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DailyReport> _generateMockReports() {
    return [
      DailyReport(
        reportId: 'aa0a1234-b5c6-7d8e-9f10-123456789abc',
        projectId: '550e8400-e29b-41d4-a716-446655440000',
        technicianId: '234f5678-e89b-12d3-a456-426614174001',
        reportDate: DateTime.now().subtract(const Duration(days: 1)),
        status: DailyReportStatus.submitted,
        workStartTime: '07:30:00',
        workEndTime: '16:00:00',
        weatherConditions: 'Sunny, 75°F, Light breeze',
        overallNotes: 'Good progress on panel installation. No major issues encountered.',
        safetyNotes: 'All safety protocols followed. Hard hats and harnesses used.',
        delaysOrIssues: 'Minor delay due to electrical inspection.',
        photosCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        project: const ProjectInfo(
          projectId: '550e8400-e29b-41d4-a716-446655440000',
          projectName: 'Downtown Solar Installation',
          address: '123 Main St, City, State 12345',
        ),
        technician: const TechnicianInfo(
          userId: '234f5678-e89b-12d3-a456-426614174001',
          fullName: 'Mike Technician',
          email: 'mike.tech@example.com',
        ),
        workProgressItems: [
          WorkProgressItem(
            workProgressId: 'cc2c6789-d0e1-2f3a-4b5c-678901234efg',
            reportId: 'aa0a1234-b5c6-7d8e-9f10-123456789abc',
            taskDescription: 'Install solar panels on roof section A',
            hoursWorked: 6.5,
            percentageComplete: 75,
            notes: 'Completed 12 of 16 panels. Good progress despite morning fog.',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      DailyReport(
        reportId: 'bb1b5678-c9d0-1e2f-3a4b-567890123def',
        projectId: '550e8400-e29b-41d4-a716-446655440001',
        technicianId: '234f5678-e89b-12d3-a456-426614174002',
        reportDate: DateTime.now(),
        status: DailyReportStatus.draft,
        workStartTime: '08:00:00',
        workEndTime: '17:00:00',
        weatherConditions: 'Cloudy, 72°F, No wind',
        overallNotes: 'Continued panel installation on building section B.',
        safetyNotes: 'All team members wore required PPE. Safety meeting conducted at start.',
        delaysOrIssues: 'No significant issues today.',
        photosCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        project: const ProjectInfo(
          projectId: '550e8400-e29b-41d4-a716-446655440001',
          projectName: 'Residential Solar Array',
          address: '456 Oak Ave, Suburb, State 67890',
        ),
        technician: const TechnicianInfo(
          userId: '234f5678-e89b-12d3-a456-426614174002',
          fullName: 'Sarah Johnson',
          email: 'sarah.johnson@example.com',
        ),
      ),
    ];
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final DailyReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _showReportDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: report.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(report.status.icon, size: 16, color: report.status.color),
                        const SizedBox(width: 4),
                        Text(
                          report.status.displayName,
                          style: TextStyle(
                            color: report.status.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(report.reportDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.project?.projectName ?? 'Unknown Project',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.project?.address ?? 'No address',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    report.technician?.fullName ?? 'Unknown Technician',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${report.workStartTime} - ${report.workEndTime}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              if (report.overallNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  report.overallNotes,
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.camera_alt,
                    label: '${report.photosCount} photos',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.cloud,
                    label: report.weatherConditions.split(',').first,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ReportDetailsDialog(report: report),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.isSelected = false,
    this.color,
  });

  final String label;
  final bool isSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      backgroundColor: color?.withValues(alpha: 0.1),
      selectedColor: color?.withValues(alpha: 0.2),
      checkmarkColor: color,
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final DailyReportStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(status.icon, color: status.color, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Status Code: ${status.value}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Next Actions:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: status.nextActions.map((action) => Chip(
                label: Text(action),
                labelStyle: TextStyle(fontSize: 12),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({
    required this.status,
    this.isFirst = false,
  });

  final DailyReportStatus status;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.1),
            border: Border.all(color: status.color, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(status.icon, color: status.color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          status.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: status.color,
          ),
        ),
      ],
    );
  }
}

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({
    required this.method,
    required this.path,
    required this.description,
  });

  final String method;
  final String path;
  final String description;

  @override
  Widget build(BuildContext context) {
    final methodColor = _getMethodColor(method);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method,
                style: TextStyle(
                  color: methodColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ReportDetailsDialog extends StatelessWidget {
  const _ReportDetailsDialog({required this.report});

  final DailyReport report;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Daily Report Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Project Information', [
                      _DetailRow('Project Name', report.project?.projectName ?? 'N/A'),
                      _DetailRow('Address', report.project?.address ?? 'N/A'),
                      _DetailRow('Report Date', _formatDate(report.reportDate)),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('Work Information', [
                      _DetailRow('Start Time', report.workStartTime),
                      _DetailRow('End Time', report.workEndTime),
                      _DetailRow('Weather', report.weatherConditions),
                      _DetailRow('Photos Count', '${report.photosCount}'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('Notes', [
                      _DetailRow('Overall Notes', report.overallNotes),
                      _DetailRow('Safety Notes', report.safetyNotes),
                      _DetailRow('Delays/Issues', report.delaysOrIssues),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
