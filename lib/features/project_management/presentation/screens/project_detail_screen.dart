import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

// Project Management imports
import '../../application/project_bloc.dart';
import '../../application/project_event.dart';
import '../../application/project_state.dart';
import '../../domain/entities/project.dart';

// Authentication & Authorization
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authorization/presentation/widgets/authorization_widgets.dart';

// Daily Reports integration
import '../../../daily_reports/application/cubits/daily_reports_cubit.dart';
import '../../../daily_reports/application/models/filter_params.dart';
import '../../../daily_reports/domain/entities/daily_report.dart';
import '../../../daily_reports/presentation/screens/daily_reports_screen.dart';
import '../../../daily_reports/presentation/screens/create_daily_report_screen.dart';
import '../../../daily_reports/presentation/screens/daily_report_details_screen.dart';

// Project Detail widgets
import '../widgets/project_detail/project_header_widget.dart';
import '../widgets/project_detail/project_reports_widget.dart';
import '../widgets/project_detail/quick_actions_bottom_sheet.dart';

// Project Detail modules
import 'project_detail/constants.dart';
import 'project_detail/utils.dart';
import 'project_detail/state_widgets.dart';
import 'project_detail/tab_builders.dart';

/// Project detail screen that displays comprehensive project information
/// with role-based access control and integrated daily reports functionality.
/// 
/// Features:
/// - Role-based tab access (Admin/Manager: 7 tabs, User: 4 tabs)
/// - Real-time daily reports integration
/// - Modern Material Design 3 UI
/// - Smooth animations and transitions
/// - Comprehensive error handling
/// - Responsive design
class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  /// The unique identifier of the project to display
  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with TickerProviderStateMixin {
  // Dependencies
  late final ProjectBloc _projectBloc;
  late final DailyReportsCubit _dailyReportsCubit;
  
  // Animation controllers
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  
  // UI controllers
  late TabController _tabController;
  
  // State
  Project? _project;
  UserRole _currentUserRole = UserRole.user;

  // ============================================================================
  // INITIALIZATION & LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _initializeAnimations();
    _initializeTabController();
    _loadProjectData();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  /// Initialize dependency injection for required services
  void _initializeDependencies() {
    _projectBloc = GetIt.instance<ProjectBloc>();
    _dailyReportsCubit = GetIt.instance<DailyReportsCubit>();
  }

  /// Setup animation controllers and animations
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: ProjectDetailConstants.fadeAnimationDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: ProjectDetailConstants.animationDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: ProjectDetailConstants.defaultCurve,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: ProjectDetailConstants.slideInCurve,
    ));
  }

  /// Initialize tab controller with proper tab count for current user role
  void _initializeTabController() {
    _tabController = TabController(
      length: _getTabCountForRole(_currentUserRole),
      vsync: this,
    );
  }

  /// Load initial project data
  void _loadProjectData() {
    _projectBloc.add(const ProjectLoadRequested());
  }

  /// Clean up all controllers and resources
  void _disposeControllers() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
  }

  // ============================================================================
  // MAIN BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _projectBloc),
          BlocProvider.value(value: _dailyReportsCubit),
        ],
        child: BlocListener<ProjectBloc, ProjectState>(
          listener: _handleProjectStateChanges,
          child: BlocBuilder<ProjectBloc, ProjectState>(
            builder: _buildProjectContent,
          ),
        ),
      ),
      floatingActionButton: _project != null
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  // ============================================================================
  // STATE HANDLING & CONTENT BUILDING
  // ============================================================================

  /// Handle changes in project state (loading, error, success)
  void _handleProjectStateChanges(BuildContext context, ProjectState state) {
    if (state is ProjectLoaded) {
      _fadeController.forward();
      _slideController.forward();
    }
  }

  Widget _buildProjectContent(BuildContext context, ProjectState state) {
    return switch (state) {
      ProjectLoading() => ProjectDetailStateWidgets.buildLoadingView(context),
      ProjectError() => ProjectDetailStateWidgets.buildErrorView(
          context,
          state.message,
          () => _projectBloc.add(const ProjectLoadRequested()),
        ),
      ProjectLoaded() => _buildLoadedContent(context, state),
      _ => ProjectDetailStateWidgets.buildEmptyStateView(
          context,
          () => _projectBloc.add(const ProjectLoadRequested()),
        ),
    };
  }

  Widget _buildLoadedContent(BuildContext context, ProjectLoaded state) {
    try {
      _project = state.projects.firstWhere(
        (project) => project.projectId == widget.projectId,
      );
      _loadProjectDailyReports();
      
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildProjectDetailView(context, _project!),
        ),
      );
    } on StateError catch (e) {
      // Project not found in the list
      debugPrint('Project not found: ${widget.projectId} - Error: $e');
      return ProjectDetailStateWidgets.buildProjectNotFoundView(context);
    } catch (e) {
      // Unexpected error
      debugPrint('Unexpected error loading project: $e');
      return ProjectDetailStateWidgets.buildErrorView(
        context,
        'Failed to load project: ${e.toString()}',
        () => _projectBloc.add(const ProjectLoadRequested()),
      );
    }
  }

  // ============================================================================
  // UI COMPONENT BUILDERS
  // ============================================================================

  /// Build project detail view
  Widget _buildProjectDetailView(BuildContext context, Project project) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return ProjectDetailStateWidgets.buildAuthenticationRequiredView(context);
        }

        final user = authState.user;
        _updateUserRole(user);
        _updateTabControllerForUser();

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildProjectHeader(context, project, user),
              _buildTabBar(context),
            ],
            body: TabBarView(
              controller: _tabController,
              children: _getTabViewsForUser(project, user),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context),
        );
      },
    );
  }

  Widget _buildProjectHeader(BuildContext context, Project project, User user) {
    return ProjectHeaderWidget(
      project: project,
      onEdit: () => _handleEditProject(project),
      onShare: () => _handleShareProject(project),
      onDelete: () => _handleDeleteProject(project),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return SliverToBoxAdapter(
      child: Container(
        color: theme.colorScheme.surface,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: _getTabsForRole(_currentUserRole),
        ),
      ),
    );
  }

  /// Enhanced floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated || _project == null) {
          return const SizedBox.shrink();
        }

        return PermissionBuilder(
          user: authState.user,
          resource: 'projects',
          action: 'update',
          builder: (context, hasUpdatePermission) {
            if (!hasUpdatePermission) return const SizedBox.shrink();

            final theme = Theme.of(context);
            return AnimatedScale(
              scale: 1.0,
              duration: ProjectDetailConstants.animationDuration,
              child: FloatingActionButton.extended(
                onPressed: () => QuickActionsBottomSheet.show(context, _project!),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Quick Add'),
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                elevation: 4,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            );
          },
          fallback: const SizedBox.shrink(),
        );
      },
    );
  }

  // ============================================================================
  // TAB MANAGEMENT & USER ROLE HANDLING
  // ============================================================================

  /// Update user role based on authenticated user
  void _updateUserRole(User user) {
    _currentUserRole = UserRole.fromString(user.roleName);
  }

  /// Update tab controller when user role changes
  void _updateTabControllerForUser() {
    final newLength = _getTabCountForRole(_currentUserRole);
    
    if (_tabController.length != newLength) {
      _tabController.dispose();
      _tabController = TabController(length: newLength, vsync: this);
    }
  }

  /// Get tab count based on user role
  int _getTabCountForRole(UserRole role) {
    return role.tabCount;
  }

  /// Get tabs for specific user role
  List<Tab> _getTabsForRole(UserRole role) {
    return switch (role) {
      UserRole.admin || UserRole.manager => const [
        Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined, size: 20)),
        Tab(text: 'Master Plan', icon: Icon(Icons.account_tree_outlined, size: 20)),
        Tab(text: 'Progress', icon: Icon(Icons.trending_up_outlined, size: 20)),
        Tab(text: 'Tasks', icon: Icon(Icons.task_outlined, size: 20)),
        Tab(text: 'Daily Reports', icon: Icon(Icons.today_outlined, size: 20)),
        Tab(text: 'Weekly Reports', icon: Icon(Icons.calendar_view_week_outlined, size: 20)),
        Tab(text: 'Work Reports', icon: Icon(Icons.work_outline, size: 20)),
      ],
      UserRole.user => const [
        Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined, size: 20)),
        Tab(text: 'Daily Reports', icon: Icon(Icons.today_outlined, size: 20)),
        Tab(text: 'Weekly Reports', icon: Icon(Icons.calendar_view_week_outlined, size: 20)),
        Tab(text: 'Work Reports', icon: Icon(Icons.work_outline, size: 20)),
      ],
    };
  }

  /// Get tab views based on user permissions
  List<Widget> _getTabViewsForUser(Project project, User user) {
    return switch (_currentUserRole) {
      UserRole.admin || UserRole.manager => [
        ProjectDetailTabBuilders.buildOverviewTab(context, project, user),
        ProjectDetailStateWidgets.buildComingSoonView(context, 'Master Plan'),
        ProjectDetailTabBuilders.buildProgressTab(context, project),
        ProjectDetailTabBuilders.buildTasksTab(context, project),
        ProjectDetailTabBuilders.buildDailyReportsTab(
          context,
          project,
          user,
          _currentUserRole,
          _navigateToCreateDailyReport,
          _navigateToDailyReports,
          _viewDailyReportDetails,
          _loadProjectDailyReports,
        ),
        ProjectDetailStateWidgets.buildComingSoonView(context, 'Weekly Reports'),
        ProjectDetailStateWidgets.buildComingSoonView(context, 'Work Reports'),
      ],
      UserRole.user => [
        ProjectDetailTabBuilders.buildOverviewTab(context, project, user),
        ProjectDetailTabBuilders.buildDailyReportsTab(
          context,
          project,
          user,
          _currentUserRole,
          _navigateToCreateDailyReport,
          _navigateToDailyReports,
          _viewDailyReportDetails,
          _loadProjectDailyReports,
        ),
        ProjectDetailStateWidgets.buildComingSoonView(context, 'Weekly Reports'),
        ProjectDetailStateWidgets.buildComingSoonView(context, 'Work Reports'),
      ],
    };
  }

  // ============================================================================
  // DATA LOADING & ACTION HANDLERS
  // ============================================================================

  /// Load daily reports for the current project
  void _loadProjectDailyReports() {
    if (_project != null) {
      _dailyReportsCubit.loadDailyReports(
        filters: DailyReportsFilterParams(
          projectId: _project!.projectId,
          pageSize: ProjectDetailConstants.projectReportsPageSize,
        ),
      );
    }
  }

  /// Handle edit project action
  void _handleEditProject(Project project) {
    ProjectDetailUtils.showFeatureComingSoonSnackBar(context, 'Edit project');
  }

  /// Handle share project action
  void _handleShareProject(Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing project: ${project.projectName}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }

  /// Handle delete project action
  void _handleDeleteProject(Project project) {
    ProjectDetailUtils.showDeleteProjectDialog(context, project);
  }

  // ============================================================================
  // NAVIGATION METHODS
  // ============================================================================

  /// Navigate to daily reports screen
  void _navigateToDailyReports(Project project) {
    try {
      // Filter daily reports by project
      _dailyReportsCubit.loadDailyReports(
        filters: DailyReportsFilterParams(
          projectId: project.projectId,
          pageSize: 20,
        ),
      );
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: _dailyReportsCubit,
            child: const DailyReportsScreen(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to daily reports: $e');
      ProjectDetailUtils.showFeatureComingSoonSnackBar(context, 'Daily reports navigation');
    }
  }

  /// Navigate to create daily report screen
  void _navigateToCreateDailyReport(Project project) {
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: _dailyReportsCubit,
            child: const CreateDailyReportScreen(),
          ),
        ),
      ).then((_) {
        // Refresh daily reports when returning from create screen
        _loadProjectDailyReports();
      });
    } catch (e) {
      debugPrint('Error navigating to create daily report: $e');
      ProjectDetailUtils.showFeatureComingSoonSnackBar(context, 'Create daily report');
    }
  }

  /// Navigate to daily report details screen
  void _viewDailyReportDetails(DailyReport report) {
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: _dailyReportsCubit,
            child: DailyReportDetailsScreen(reportId: report.reportId),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to daily report details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to view report details'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
