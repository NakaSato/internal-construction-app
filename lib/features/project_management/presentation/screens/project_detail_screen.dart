import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../application/project_bloc.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_api_models.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../daily_reports/application/cubits/daily_reports_cubit.dart';
import '../../../wbs/application/cubits/wbs_cubit.dart';
import '../../../wbs/domain/usecases/wbs_usecases.dart';
import '../../../wbs/presentation/widgets/wbs_tree_widget.dart';
import '../../../wbs/presentation/widgets/wbs_task_details_widget.dart';
import '../../../wbs/presentation/widgets/wbs_progress_widget.dart';
import '../widgets/project_detail/project_header_widget.dart';
import '../widgets/project_detail/project_details_widget.dart';
import 'edit_project_screen.dart';
import 'project_detail/constants.dart';
import 'project_detail/state_widgets.dart';

/// Enhanced project detail screen with role-based access and comprehensive features
/// Supports different user roles with tailored content and functionality
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with TickerProviderStateMixin {
  late final EnhancedProjectBloc _projectBloc;
  late final DailyReportsCubit _dailyReportsCubit;
  late final WbsCubit _wbsCubit;
  late final TabController _tabController;

  int _tabCount = 8; // Default to full access (added WBS tab)
  UserRole _currentUserRole = UserRole.admin;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _projectBloc = GetIt.instance<EnhancedProjectBloc>();
    _dailyReportsCubit = GetIt.instance<DailyReportsCubit>();

    // Initialize WBS cubit with dependencies
    _wbsCubit = WbsCubit(
      getProjectWbs: GetIt.instance<GetProjectWbs>(),
      getWbsTask: GetIt.instance<GetWbsTask>(),
      createWbsTask: GetIt.instance<CreateWbsTask>(),
      updateWbsTask: GetIt.instance<UpdateWbsTask>(),
      updateTaskStatus: GetIt.instance<UpdateTaskStatus>(),
      deleteWbsTask: GetIt.instance<DeleteWbsTask>(),
    );

    // Initialize with default tab count, will be updated based on user role
    _tabController = TabController(length: _tabCount, vsync: this);

    // Initialize real-time connection (if not already connected)
    _projectBloc.add(const InitializeRealTimeConnection());

    // Load project data
    _projectBloc.add(LoadProjectDetailsRequested(projectId: widget.projectId));

    // Load WBS data for the project
    _wbsCubit.loadProjectWbs(widget.projectId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wbsCubit.close();
    super.dispose();
  }

  void _updateTabsBasedOnRole(User user) {
    final role = UserRole.fromString(user.roleName);
    final newTabCount = _getTabCountForRole(role);

    // Defer state updates to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_tabCount != newTabCount) {
        setState(() {
          _currentUserRole = role;
          _currentUser = user;
          _tabCount = newTabCount;
          _tabController.dispose();
          _tabController = TabController(length: _tabCount, vsync: this);
        });
      } else {
        setState(() {
          _currentUserRole = role;
          _currentUser = user;
        });
      }
    });
  }

  int _getTabCountForRole(UserRole role) {
    return role.hasFullAccess ? 8 : 5; // Admin/Manager: 8 tabs, User: 5 tabs (includes WBS)
  }

  List<Tab> _buildTabs() {
    final tabs = <Tab>[
      const Tab(text: 'Overview'),
      const Tab(text: 'Progress'),
      const Tab(text: 'WBS'),
      const Tab(text: 'Tasks'),
      const Tab(text: 'Reports'),
    ];

    // Add admin/manager only tabs
    if (_currentUserRole.hasFullAccess) {
      tabs.addAll([const Tab(text: 'Team'), const Tab(text: 'Documents'), const Tab(text: 'Settings')]);
    }

    return tabs;
  }

  void _onEditProject(Project project) {
    if (_currentUser != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditProjectScreen(project: project, user: _currentUser!),
        ),
      );
    }
  }

  void _onDeleteProject(Project project) {
    // Show confirmation dialog and handle project deletion
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.projectName}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement project deletion through API
              context.pop(); // Return to previous screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _projectBloc),
        BlocProvider.value(value: _dailyReportsCubit),
        BlocProvider.value(value: _wbsCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            _updateTabsBasedOnRole(authState.user);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return ProjectDetailStateWidgets.buildErrorView(
                context,
                'Authentication required',
                () => context.go('/login'),
              );
            }

            return BlocBuilder<EnhancedProjectBloc, EnhancedProjectState>(
              builder: (context, projectState) {
                if (projectState is EnhancedProjectLoading) {
                  return ProjectDetailStateWidgets.buildLoadingView(context);
                }

                if (projectState is EnhancedProjectError) {
                  return ProjectDetailStateWidgets.buildErrorView(
                    context,
                    projectState.message,
                    () => _projectBloc.add(LoadProjectDetailsRequested(projectId: widget.projectId)),
                  );
                }

                if (projectState is EnhancedProjectDetailsLoaded) {
                  // Update current user from auth state
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _currentUser = authState.user;
                        _currentUserRole = UserRole.fromString(authState.user.roleName);
                      });
                    }
                  });

                  return _buildProjectDetailContent(projectState.project);
                }

                return ProjectDetailStateWidgets.buildProjectNotFoundView(context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProjectDetailContent(EnhancedProject enhancedProject) {
    // Convert EnhancedProject to Project for widgets that expect the older type
    // This is a temporary adapter until all widgets are updated to use EnhancedProject
    final project = Project(
      projectId: enhancedProject.projectId,
      projectName: enhancedProject.projectName,
      description: '', // EnhancedProject doesn't have description field
      address: enhancedProject.address,
      clientInfo: enhancedProject.clientInfo,
      priority: ProjectPriority.medium, // Default priority
      status: enhancedProject.status,
      startDate: enhancedProject.startDate,
      estimatedEndDate: enhancedProject.estimatedEndDate,
      actualEndDate: enhancedProject.actualEndDate,
      createdAt: enhancedProject.createdAt,
      updatedAt: enhancedProject.updatedAt,
    );
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            ProjectHeaderWidget(
              project: project,
              onEdit: _currentUserRole.hasFullAccess ? () => _onEditProject(project) : null,
              onDelete: _currentUserRole.hasFullAccess ? () => _onDeleteProject(project) : null,
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: _buildTabs(),
                  isScrollable: _tabCount > 4,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(controller: _tabController, children: _buildTabContent(project)),
      ),
    );
  }

  List<Widget> _buildTabContent(Project project) {
    final tabs = <Widget>[
      // Overview Tab
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ProjectDetailsWidget(project: project),
      ),

      // Progress Tab
      const Center(child: Text('Progress content coming soon')),

      // WBS Tab
      BlocBuilder<WbsCubit, WbsState>(
        builder: (context, state) {
          if (state is WbsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WbsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading WBS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  Text(state.message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _wbsCubit.loadProjectWbs(project.projectId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WbsLoaded) {
            return _buildWbsContent(state);
          }

          // Initial state - load WBS
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Loading Work Breakdown Structure...'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _wbsCubit.loadProjectWbs(project.projectId),
                  child: const Text('Load WBS'),
                ),
              ],
            ),
          );
        },
      ),

      // Tasks Tab
      const Center(child: Text('Tasks content coming soon')),

      // Reports Tab
      const Center(child: Text('Reports content coming soon')),
    ];

    // Add admin/manager only tabs
    if (_currentUserRole.hasFullAccess) {
      tabs.addAll([
        const Center(child: Text('Team content coming soon')),
        const Center(child: Text('Documents content coming soon')),
        const Center(child: Text('Settings content coming soon')),
      ]);
    }

    return tabs;
  }

  Widget _buildWbsContent(WbsLoaded state) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    if (isTablet) {
      // Two-pane layout for tablets
      return Row(
        children: [
          // Left pane - WBS tree and progress
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Progress summary
                WbsProgressWidget(wbsStructure: state.wbsStructure),
                const Divider(height: 1),
                // WBS tree
                Expanded(
                  child: WbsTreeWidget(
                    wbsStructure: state.wbsStructure,
                    selectedTask: state.selectedTask,
                    onTaskSelected: (task) {
                      _wbsCubit.selectTask(task.wbsId);
                    },
                    onTaskStatusChanged: (taskId, status) {
                      _wbsCubit.updateTaskStatusOnly(taskId: taskId, status: status);
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right pane - Task details
          Expanded(
            flex: 1,
            child: WbsTaskDetailsWidget(
              task: state.selectedTask,
              onTaskUpdated: (task) {
                _wbsCubit.updateTask(taskId: task.wbsId, task: task);
              },
              onTaskDeleted: (taskId) {
                _wbsCubit.deleteTask(taskId);
              },
            ),
          ),
        ],
      );
    } else {
      // Single pane layout for mobile
      return Column(
        children: [
          // Progress summary (collapsed on mobile)
          WbsProgressWidget(wbsStructure: state.wbsStructure, isCollapsed: true),
          const Divider(height: 1),
          // WBS tree
          Expanded(
            child: WbsTreeWidget(
              wbsStructure: state.wbsStructure,
              selectedTask: state.selectedTask,
              onTaskSelected: (task) {
                _wbsCubit.selectTask(task.wbsId);
                _showTaskDetailsBottomSheet(task);
              },
              onTaskStatusChanged: (taskId, status) {
                _wbsCubit.updateTaskStatusOnly(taskId: taskId, status: status);
              },
            ),
          ),
        ],
      );
    }
  }

  void _showTaskDetailsBottomSheet(dynamic task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: WbsTaskDetailsWidget(
                  task: task,
                  onTaskUpdated: (updatedTask) {
                    _wbsCubit.updateTask(taskId: updatedTask.wbsId, task: updatedTask);
                    Navigator.of(context).pop();
                  },
                  onTaskDeleted: (taskId) {
                    _wbsCubit.deleteTask(taskId);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom delegate for sticky tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
