import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/cubits/process_approval_cubit.dart';
import '../../domain/entities/work_request.dart';
import '../../domain/entities/approval_requests.dart';

class ProcessApprovalScreen extends StatefulWidget {
  const ProcessApprovalScreen({super.key, required this.workRequest});

  final WorkRequest workRequest;

  @override
  State<ProcessApprovalScreen> createState() => _ProcessApprovalScreenState();
}

class _ProcessApprovalScreenState extends State<ProcessApprovalScreen> {
  ApprovalAction? _selectedAction;
  final _commentsController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentsController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Process Approval')),
      body: BlocListener<ProcessApprovalCubit, ProcessApprovalState>(
        listener: (context, state) {
          if (state is ProcessApprovalSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _selectedAction == ApprovalAction.approve
                      ? 'Work request approved successfully'
                      : 'Work request rejected successfully',
                ),
                backgroundColor: _selectedAction == ApprovalAction.approve
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is ProcessApprovalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequestSummary(),
                      const SizedBox(height: 24),
                      _buildActionSelection(),
                      const SizedBox(height: 24),
                      _buildCommentsField(),
                      if (_selectedAction == ApprovalAction.reject) ...[
                        const SizedBox(height: 16),
                        _buildRejectionReasonField(),
                      ],
                      const SizedBox(height: 24),
                      _buildEscalateOption(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSummary() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Title', widget.workRequest.title),
            _buildSummaryRow('Project', widget.workRequest.projectName),
            _buildSummaryRow('Description', widget.workRequest.description),
            _buildSummaryRow(
              'Priority',
              widget.workRequest.priority.displayName,
            ),
            _buildSummaryRow(
              'Estimated Cost',
              '\$${widget.workRequest.estimatedCost.toStringAsFixed(2)}',
            ),
            _buildSummaryRow(
              'Submitted By',
              widget.workRequest.submittedByName,
            ),
            _buildSummaryRow(
              'Submitted Date',
              _formatDate(widget.workRequest.submittedDate),
            ),
            if (widget.workRequest.daysPending > 0)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pending for ${widget.workRequest.daysPending} day(s)',
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Decision',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('Approve'),
                selected: _selectedAction == ApprovalAction.approve,
                onSelected: (selected) {
                  setState(() {
                    _selectedAction = selected ? ApprovalAction.approve : null;
                  });
                },
                selectedColor: Colors.green.withOpacity(0.2),
                checkmarkColor: Colors.green[800],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilterChip(
                label: const Text('Reject'),
                selected: _selectedAction == ApprovalAction.reject,
                onSelected: (selected) {
                  setState(() {
                    _selectedAction = selected ? ApprovalAction.reject : null;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.errorContainer,
                checkmarkColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsField() {
    return TextFormField(
      controller: _commentsController,
      decoration: const InputDecoration(
        labelText: 'Comments (Optional)',
        hintText: 'Add any additional comments for your decision...',
        border: OutlineInputBorder(),
      ),
      maxLines: 4,
    );
  }

  Widget _buildRejectionReasonField() {
    return TextFormField(
      controller: _rejectionReasonController,
      decoration: InputDecoration(
        labelText: 'Rejection Reason (Required)',
        hintText: 'Provide a clear reason for rejection...',
        border: const OutlineInputBorder(),
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      maxLines: 3,
      validator: (value) {
        if (_selectedAction == ApprovalAction.reject &&
            (value == null || value.trim().isEmpty)) {
          return 'Rejection reason is required';
        }
        return null;
      },
    );
  }

  Widget _buildEscalateOption() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alternative Actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _showEscalateDialog,
              icon: const Icon(Icons.trending_up),
              label: const Text('Escalate Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<ProcessApprovalCubit, ProcessApprovalState>(
        builder: (context, state) {
          final isLoading = state is ProcessApprovalLoading;

          return SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedAction != null && !isLoading
                  ? _processApproval
                  : null,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _selectedAction == ApprovalAction.approve
                          ? 'Confirm Approval'
                          : _selectedAction == ApprovalAction.reject
                          ? 'Confirm Rejection'
                          : 'Select Action',
                    ),
            ),
          );
        },
      ),
    );
  }

  void _processApproval() {
    if (_selectedAction == null) return;

    if (!_formKey.currentState!.validate()) return;

    context.read<ProcessApprovalCubit>().processApproval(
      widget.workRequest.id,
      _selectedAction!,
      comments: _commentsController.text.trim().isEmpty
          ? null
          : _commentsController.text.trim(),
      rejectionReason: _selectedAction == ApprovalAction.reject
          ? _rejectionReasonController.text.trim()
          : null,
    );
  }

  void _showEscalateDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _EscalateDialog(
        workRequest: widget.workRequest,
        onEscalate: (reason, comments) {
          Navigator.pop(context);
          // TODO: Implement escalation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request escalated successfully')),
          );
          Navigator.pop(context, true);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EscalateDialog extends StatefulWidget {
  const _EscalateDialog({required this.workRequest, required this.onEscalate});

  final WorkRequest workRequest;
  final void Function(String reason, String? comments) onEscalate;

  @override
  State<_EscalateDialog> createState() => _EscalateDialogState();
}

class _EscalateDialogState extends State<_EscalateDialog> {
  final _reasonController = TextEditingController();
  final _commentsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escalate Request'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escalate "${widget.workRequest.title}" to a higher authority?',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Escalation Reason (Required)',
                hintText: 'Provide reason for escalation...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escalation reason is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Additional Comments (Optional)',
                hintText: 'Add any additional comments...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onEscalate(
                _reasonController.text.trim(),
                _commentsController.text.trim().isEmpty
                    ? null
                    : _commentsController.text.trim(),
              );
            }
          },
          child: const Text('Escalate'),
        ),
      ],
    );
  }
}
