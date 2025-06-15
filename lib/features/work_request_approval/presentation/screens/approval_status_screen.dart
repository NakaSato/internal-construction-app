import 'package:flutter/material.dart';
import '../../domain/entities/work_request.dart';
import '../../domain/entities/approval_history.dart';
import '../widgets/approval_status_card.dart';
import '../widgets/approval_history_card.dart';

class ApprovalStatusScreen extends StatefulWidget {
  const ApprovalStatusScreen({super.key, required this.workRequest});

  final WorkRequest workRequest;

  @override
  State<ApprovalStatusScreen> createState() => _ApprovalStatusScreenState();
}

class _ApprovalStatusScreenState extends State<ApprovalStatusScreen> {
  final List<ApprovalHistory> _mockHistory = [
    ApprovalHistory(
      id: '1',
      workRequestId: 'wr1',
      action: 'AdminApproved',
      newStatus: 'Approved',
      approverName: 'Test Administrator',
      processedAt: DateTime.now().subtract(const Duration(hours: 3)),
      comments:
          'Final approval granted. Good project scope and budget estimation.',
    ),
    ApprovalHistory(
      id: '2',
      workRequestId: 'wr1',
      action: 'ManagerApproved',
      newStatus: 'Pending Admin Approval',
      approverName: 'Test Manager',
      processedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      comments: 'Looks good to me. Forwarding to admin for final approval.',
    ),
    ApprovalHistory(
      id: '3',
      workRequestId: 'wr1',
      action: 'Submitted',
      newStatus: 'Pending Manager Approval',
      approverName: 'System',
      processedAt: DateTime.now().subtract(const Duration(days: 2)),
      comments: 'Work request submitted for approval process.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Details'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ApprovalStatusCard(workRequest: widget.workRequest),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approval History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track the progress of your work request through the approval process.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _mockHistory.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No history available',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Approval history will appear here once actions are taken.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final historyItem = _mockHistory[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: index == _mockHistory.length - 1 ? 16 : 0,
                        ),
                        child: ApprovalHistoryCard(
                          history: historyItem,
                          isLast: index == _mockHistory.length - 1,
                        ),
                      );
                    }, childCount: _mockHistory.length),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // TODO: Implement refresh logic
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh data
    });
  }
}
