import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/cubits/pending_approvals_cubit.dart';
import '../widgets/pending_approval_card.dart';
import '../../domain/entities/work_request.dart';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isBulkMode = false;
  final Set<String> _selectedRequests = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<PendingApprovalsCubit>().loadPendingApprovals();
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
        title: const Text('Pending Approvals'),
        bottom: _buildTabBar(),
        actions: [
          if (!_isBulkMode)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _enableBulkMode,
              tooltip: 'Bulk Actions',
            )
          else
            TextButton(
              onPressed: _disableBulkMode,
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<PendingApprovalsCubit>().refreshApprovals(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPendingList(showOnlyMyApprovals: true),
            _buildPendingList(showOnlyMyApprovals: false),
          ],
        ),
      ),
      bottomSheet: _isBulkMode && _selectedRequests.isNotEmpty
          ? _buildBulkActionBar()
          : null,
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Pending My Approval'),
        Tab(text: 'All Pending'),
      ],
    );
  }

  Widget _buildPendingList({required bool showOnlyMyApprovals}) {
    return BlocBuilder<PendingApprovalsCubit, PendingApprovalsState>(
      builder: (context, state) {
        if (state is PendingApprovalsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PendingApprovalsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading pending approvals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context
                      .read<PendingApprovalsCubit>()
                      .loadPendingApprovals(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is PendingApprovalsLoaded) {
          final requests = state.requests;

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending approvals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All caught up! No work requests are waiting for your approval.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(
              top: 8,
              bottom: _isBulkMode && _selectedRequests.isNotEmpty ? 80 : 8,
              left: 0,
              right: 0,
            ),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return PendingApprovalCard(
                workRequest: request,
                isSelected: _selectedRequests.contains(request.id),
                isBulkMode: _isBulkMode,
                onTap: _isBulkMode
                    ? () => _toggleSelection(request.id)
                    : () => _processApproval(request),
                onApprove: _isBulkMode ? null : () => _processApproval(request),
                onReject: _isBulkMode ? null : () => _processApproval(request),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '${_selectedRequests.length} selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: _bulkReject,
              child: const Text('Bulk Reject'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _bulkApprove,
              child: const Text('Bulk Approve'),
            ),
          ],
        ),
      ),
    );
  }

  void _enableBulkMode() {
    setState(() {
      _isBulkMode = true;
      _selectedRequests.clear();
    });
  }

  void _disableBulkMode() {
    setState(() {
      _isBulkMode = false;
      _selectedRequests.clear();
    });
  }

  void _toggleSelection(String requestId) {
    setState(() {
      if (_selectedRequests.contains(requestId)) {
        _selectedRequests.remove(requestId);
      } else {
        _selectedRequests.add(requestId);
      }
    });
  }

  void _processApproval(WorkRequest request) {
    // Navigate to approval processing dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Approval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request: ${request.title}'),
            const SizedBox(height: 8),
            Text('Project: ${request.projectName}'),
            const SizedBox(height: 8),
            Text('Cost: \$${request.estimatedCost.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _approveRequest(request);
            },
            child: const Text('Approve'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectRequest(request);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    ).then((_) {
      // Refresh the list after processing
      context.read<PendingApprovalsCubit>().refreshApprovals();
    });
  }

  void _bulkApprove() {
    if (_selectedRequests.isEmpty) return;

    // Capture the context that has access to the provider
    final cubit = context.read<PendingApprovalsCubit>();

    showDialog<void>(
      context: context,
      builder: (context) => _BulkActionDialog(
        title: 'Bulk Approve',
        message:
            'Are you sure you want to approve ${_selectedRequests.length} work request(s)?',
        isApproval: true,
        onConfirm: (comments, [rejectionReason]) {
          // TODO: Implement bulk approval
          _disableBulkMode();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedRequests.length} requests approved'),
            ),
          );
          // Use the captured cubit instead of reading from dialog context
          cubit.refreshApprovals();
        },
      ),
    );
  }

  void _bulkReject() {
    if (_selectedRequests.isEmpty) return;

    // Capture the context that has access to the provider
    final cubit = context.read<PendingApprovalsCubit>();

    showDialog<void>(
      context: context,
      builder: (context) => _BulkActionDialog(
        title: 'Bulk Reject',
        message:
            'Are you sure you want to reject ${_selectedRequests.length} work request(s)?',
        isApproval: false,
        onConfirm: (comments, [rejectionReason]) {
          // TODO: Implement bulk rejection
          _disableBulkMode();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedRequests.length} requests rejected'),
            ),
          );
          // Use the captured cubit instead of reading from dialog context
          cubit.refreshApprovals();
        },
      ),
    );
  }

  void _approveRequest(WorkRequest request) {
    // Capture the context that has access to the provider
    final cubit = context.read<PendingApprovalsCubit>();

    // Show approval confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to approve "${request.title}"?'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Comments (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Work request "${request.title}" approved'),
                  backgroundColor: Colors.green,
                ),
              );
              // Use the captured cubit instead of reading from dialog context
              cubit.refreshApprovals();
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectRequest(WorkRequest request) {
    // Capture the context that has access to the provider
    final cubit = context.read<PendingApprovalsCubit>();

    // Show rejection confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject "${request.title}"?'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Rejection Reason (Required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Work request "${request.title}" rejected'),
                  backgroundColor: Colors.red,
                ),
              );
              // Use the captured cubit instead of reading from dialog context
              cubit.refreshApprovals();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _BulkActionDialog extends StatefulWidget {
  const _BulkActionDialog({
    required this.title,
    required this.message,
    required this.isApproval,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final bool isApproval;
  final void Function(String comments, [String? rejectionReason]) onConfirm;

  @override
  State<_BulkActionDialog> createState() => _BulkActionDialogState();
}

class _BulkActionDialogState extends State<_BulkActionDialog> {
  final _commentsController = TextEditingController();
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _commentsController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: 16),
          TextField(
            controller: _commentsController,
            decoration: const InputDecoration(
              labelText: 'Comments (Optional)',
              hintText: 'Add any additional comments...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          if (!widget.isApproval) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Required)',
                hintText: 'Provide reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!widget.isApproval &&
                _rejectionReasonController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rejection reason is required')),
              );
              return;
            }

            Navigator.pop(context);
            widget.onConfirm(
              _commentsController.text,
              widget.isApproval ? null : _rejectionReasonController.text,
            );
          },
          child: Text(widget.isApproval ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }
}
