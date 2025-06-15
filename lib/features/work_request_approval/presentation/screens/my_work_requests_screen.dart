import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/cubits/my_work_requests_cubit.dart';
import '../widgets/work_request_card.dart';
import '../widgets/ui_system/ui_system.dart';
import '../../domain/entities/work_request.dart';
import 'approval_status_screen.dart';

class MyWorkRequestsScreen extends StatefulWidget {
  const MyWorkRequestsScreen({super.key});

  @override
  State<MyWorkRequestsScreen> createState() => _MyWorkRequestsScreenState();
}

class _MyWorkRequestsScreenState extends State<MyWorkRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyWorkRequestsCubit>().loadMyWorkRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Work Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<MyWorkRequestsCubit>().refreshRequests(),
        child: BlocBuilder<MyWorkRequestsCubit, MyWorkRequestsState>(
          builder: (context, state) {
            if (state is MyWorkRequestsLoading) {
              return const WorkRequestLoadingState(
                message: 'Loading your work requests...',
              );
            }

            if (state is MyWorkRequestsError) {
              return WorkRequestErrorState(
                title: 'Error loading work requests',
                description: state.message,
                onRetry: () =>
                    context.read<MyWorkRequestsCubit>().loadMyWorkRequests(),
              );
            }

            if (state is MyWorkRequestsLoaded) {
              if (state.requests.isEmpty) {
                return WorkRequestEmptyState(
                  title: 'No work requests found',
                  description:
                      'Your work requests will appear here once you create them.',
                  icon: Icons.assignment_outlined,
                  action: WorkRequestActionButton(
                    label: 'Create New Request',
                    icon: Icons.add,
                    onPressed: _createNewRequest,
                    style: WorkRequestActionButtonStyle.primary,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return WorkRequestCard(
                    workRequest: request,
                    onViewDetails: () => _viewRequestDetails(request),
                    onSubmitForApproval:
                        request.currentStatus == WorkRequestStatus.draft
                        ? () => _submitForApproval(request)
                        : null,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRequest,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Requests'),
              onTap: () {
                Navigator.pop(context);
                // Implement filter logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.drafts),
              title: const Text('Draft'),
              onTap: () {
                Navigator.pop(context);
                // Implement filter logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending),
              title: const Text('Pending Approval'),
              onTap: () {
                Navigator.pop(context);
                // Implement filter logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Approved'),
              onTap: () {
                Navigator.pop(context);
                // Implement filter logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Rejected'),
              onTap: () {
                Navigator.pop(context);
                // Implement filter logic
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewRequestDetails(WorkRequest request) {
    // Navigate to approval status screen using MaterialPageRoute
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApprovalStatusScreen(workRequest: request),
      ),
    );
  }

  void _submitForApproval(WorkRequest request) {
    // Capture the context that has access to the provider
    final cubit = context.read<MyWorkRequestsCubit>();

    showDialog<void>(
      context: context,
      builder: (context) => _SubmitForApprovalDialog(
        workRequest: request,
        onSubmit: (comments) {
          // TODO: Implement submit for approval
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request submitted for approval')),
          );
          // Use the captured cubit instead of reading from dialog context
          cubit.refreshRequests();
        },
      ),
    );
  }

  void _createNewRequest() {
    // Show a dialog to simulate creating a new request
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Work Request'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This feature would open a form to create a new work request.',
            ),
            SizedBox(height: 8),
            Text('This functionality is currently in development.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New request creation is coming soon'),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _SubmitForApprovalDialog extends StatefulWidget {
  const _SubmitForApprovalDialog({
    required this.workRequest,
    required this.onSubmit,
  });

  final WorkRequest workRequest;
  final void Function(String comments) onSubmit;

  @override
  State<_SubmitForApprovalDialog> createState() =>
      _SubmitForApprovalDialogState();
}

class _SubmitForApprovalDialogState extends State<_SubmitForApprovalDialog> {
  final _commentsController = TextEditingController();

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit for Approval?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to submit "${widget.workRequest.title}" for approval?',
          ),
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => widget.onSubmit(_commentsController.text),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
