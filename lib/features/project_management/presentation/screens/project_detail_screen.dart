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
import '../../../daily_reports/domain/entities/daily_report.dart';
import '../widgets/project_detail/project_header_widget.dart';
import 'edit_project_screen.dart';
import 'project_detail/constants.dart';
import 'project_detail/state_widgets.dart';
import 'project_detail/tab_builders.dart';

/// Enhanced project detail screen with role-based access and comprehensive features
/// Supports different user roles with tailored content and functionality
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with TickerProviderStateMixin {
  late final EnhancedProjectBloc _projectBloc;
  late final DailyReportsCubit _dailyReportsCubit;
  late final TabController _tabController;

  int _tabCount = 7; // Default to full access
  UserRole _currentUserRole = UserRole.admin;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _projectBloc = GetIt.instance<EnhancedProjectBloc>();
    _dailyReportsCubit = GetIt.instance<DailyReportsCubit>();

    // Initialize with default tab count, will be updated based on user role
    _tabController = TabController(length: _tabCount, vsync: this);

    // Load project data
    _projectBloc.add(LoadProjectDetailsRequested(projectId: widget.projectId));
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    return role.hasFullAccess ? 7 : 4; // Admin/Manager: 7 tabs, User: 4 tabs
  }

  List<Tab> _buildTabs() {
    final tabs = <Tab>[
      const Tab(text: 'Overview'),
      const Tab(text: 'Progress'),
      const Tab(text: 'Tasks'),
      const Tab(text: 'Reports'),
    ];

    // Add admin/manager only tabs
    if (_currentUserRole.hasFullAccess) {
      tabs.addAll([
        const Tab(text: 'Team'),
        const Tab(text: 'Documents'),
        const Tab(text: 'Settings'),
      ]);
    }

    return tabs;
  }

  List<Widget> _buildTabViews(Project project) {
    // Ensure currentUser is available before building tabs
    if (_currentUser == null) {
      return List.generate(
        _tabCount,
        (index) => const Center(child: CircularProgressIndicator()),
      );
    }

    final views = <Widget>[
      ProjectDetailTabBuilders.buildOverviewTab(
        context,
        project,
        _currentUser!,
      ),
      ProjectDetailTabBuilders.buildProgressTab(context, project),
      ProjectDetailTabBuilders.buildTasksTab(context, project),
      ProjectDetailTabBuilders.buildDailyReportsTab(
        context,
        project,
        _currentUser!,
        _currentUserRole,
        _onNavigateToCreateReport,
        _onNavigateToDailyReports,
        _onViewReportDetails,
        _onLoadProjectReports,
      ),
    ];

    // Add admin/manager only views
    if (_currentUserRole.hasFullAccess) {
      views.addAll([
        ProjectDetailStateWidgets.buildComingSoonView(
          context,
          'Team Management',
        ),
        ProjectDetailStateWidgets.buildComingSoonView(
          context,
          'Document Management',
        ),
        ProjectDetailStateWidgets.buildComingSoonView(
          context,
          'Project Settings',
        ),
      ]);
    }

    return views;
  }

  void _onNavigateToCreateReport(Project project) {
    context.push('/projects/${project.projectId}/reports/create');
  }

  void _onNavigateToDailyReports(Project project) {
    context.push('/projects/${project.projectId}/reports');
  }

  void _onViewReportDetails(DailyReport report) {
    context.push('/reports/${report.reportId}');
  }

  void _onLoadProjectReports() {
    _dailyReportsCubit.loadDailyReports();
  }

  void _onEditProject(Project project) {
    if (_currentUser != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              EditProjectScreen(project: project, user: _currentUser!),
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
        content: Text(
          'Are you sure you want to delete "${project.projectName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
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
                    () => _projectBloc.add(
                      LoadProjectDetailsRequested(projectId: widget.projectId),
                    ),
                  );
                }

                if (projectState is EnhancedProjectDetailsLoaded) {
                  // Update current user from auth state
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _currentUser = authState.user;
                        _currentUserRole = UserRole.fromString(
                          authState.user.roleName,
                        );
                      });
                    }
                  });

                  return _buildProjectDetailContent(projectState.project);
                }

                return ProjectDetailStateWidgets.buildProjectNotFoundView(
                  context,
                );
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
              onEdit: _currentUserRole.hasFullAccess
                  ? () => _onEditProject(project)
                  : null,
              onDelete: _currentUserRole.hasFullAccess
                  ? () => _onDeleteProject(project)
                  : null,
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: _buildTabs(),
                  isScrollable: _tabCount > 4,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _buildTabViews(project),
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
