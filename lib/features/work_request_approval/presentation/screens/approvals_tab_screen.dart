import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'pending_approvals_screen.dart';
import 'my_work_requests_screen.dart';
import 'approval_dashboard_screen.dart';
import '../../application/cubits/pending_approvals_cubit.dart';
import '../../application/cubits/my_work_requests_cubit.dart';
import '../../domain/usecases/get_my_work_requests_usecase.dart';
import '../../domain/usecases/get_pending_approvals_usecase.dart';
import '../../infrastructure/repositories/mock_work_request_approval_repository.dart';

/// Enhanced approvals screen with comprehensive tab navigation
class ApprovalsTabScreen extends StatefulWidget {
  const ApprovalsTabScreen({super.key});

  @override
  State<ApprovalsTabScreen> createState() => _ApprovalsTabScreenState();
}

class _ApprovalsTabScreenState extends State<ApprovalsTabScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Approvals'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.assignment), text: 'My Requests'),
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Pending Approvals
          BlocProvider(
            create: (context) => PendingApprovalsCubit(
              GetPendingApprovalsUseCase(MockWorkRequestApprovalRepository()),
            )..loadPendingApprovals(),
            child: const PendingApprovalsScreen(),
          ),

          // Tab 2: My Work Requests
          BlocProvider(
            create: (context) => MyWorkRequestsCubit(
              GetMyWorkRequestsUseCase(MockWorkRequestApprovalRepository()),
            ),
            child: const MyWorkRequestsScreen(),
          ),

          // Tab 3: Approval Dashboard/Statistics
          const ApprovalDashboardScreen(),
        ],
      ),
    );
  }
}
