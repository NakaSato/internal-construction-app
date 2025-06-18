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
import '../../../daily_reports/application/states/daily_reports_state.dart';
import '../../../daily_reports/application/models/filter_params.dart';
import '../../../daily_reports/domain/entities/daily_report.dart';
import '../../../daily_reports/presentation/screens/daily_reports_screen.dart';
import '../../../daily_reports/presentation/screens/create_daily_report_screen.dart';
import '../../../daily_reports/presentation/screens/daily_report_details_screen.dart';

// Project Detail widgets
import '../widgets/project_detail/project_header_widget.dart';
import '../widgets/project_detail/project_stats_widget.dart';
import '../widgets/project_detail/project_description_widget.dart';
import '../widgets/project_detail/project_progress_widget.dart';
import '../widgets/project_detail/project_tasks_widget.dart';
import '../widgets/project_detail/project_details_widget.dart';
import '../widgets/project_detail/project_reports_widget.dart';
import '../widgets/project_detail/quick_actions_bottom_sheet.dart';

// Constants
class _ProjectDetailConstants {
  static const Duration animationDuration = Duration(milliseconds: 600);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 800);
  static const double loadingIndicatorSize = 80.0;
  static const double borderRadius = 16.0;
  static const double cardPadding = 20.0;
  static const int projectReportsPageSize = 10;
  
  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve slideInCurve = Curves.easeOutCubic;
  
  // Spacing constants
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double smallSpacing = 8.0;
}

// User role enum with enhanced functionality
enum UserRole {
  admin('ADMIN'),
  manager('MANAGER'),
  user('USER');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.value == role.toUpperCase(),
      orElse: () => UserRole.user,
    );
  }

  bool get hasFullAccess => this == UserRole.admin || this == UserRole.manager;
  bool get isFieldUser => this == UserRole.user;
  
  int get tabCount => hasFullAccess ? 7 : 4;
}

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
      duration: _ProjectDetailConstants.fadeAnimationDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: _ProjectDetailConstants.animationDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: _ProjectDetailConstants.defaultCurve,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: _ProjectDetailConstants.slideInCurve,
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
      ProjectLoading() => _buildLoadingView(context),
      ProjectError() => _buildErrorView(context, state.message),
      ProjectLoaded() => _buildLoadedContent(context, state),
      _ => _buildEmptyStateView(context),
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
      return _buildProjectNotFoundView(context);
    } catch (e) {
      // Unexpected error
      debugPrint('Unexpected error loading project: $e');
      return _buildErrorView(context, 'Failed to load project: ${e.toString()}');
    }
  }

  // ============================================================================
  // UI COMPONENT BUILDERS
  // ============================================================================

  /// Build enhanced loading view with animations and progress indicators
  Widget _buildLoadingView(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoadingIndicator(theme),
            const SizedBox(height: 32),
            _buildLoadingText(theme),
            const SizedBox(height: 8),
            _buildProgressIndicator(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Container(
      width: _ProjectDetailConstants.loadingIndicatorSize,
      height: _ProjectDetailConstants.loadingIndicatorSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLoadingText(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.5, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Text(
            'Loading project details...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      width: 120,
      height: 2,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(1),
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 3),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        },
      ),
    );
  }

  // Project detail view
  Widget _buildProjectDetailView(BuildContext context, Project project) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return _buildAuthenticationRequiredView(context);
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

  Widget _buildEnhancedStatsSection(Project project) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Overview',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: _ProjectDetailConstants.defaultSpacing),
        ProjectStatsWidget(project: project),
      ],
    );
  }

  Widget _buildEnhancedDescriptionSection(Project project) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_ProjectDetailConstants.borderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(_ProjectDetailConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Description',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: _ProjectDetailConstants.defaultSpacing),
          ProjectDescriptionWidget(project: project),
        ],
      ),
    );
  }

  Widget _buildEnhancedProgressSection(Project project) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress & Budget',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: _ProjectDetailConstants.defaultSpacing),
        ProjectProgressWidget(project: project),
      ],
    );
  }

  Widget _buildEnhancedTasksSection(Project project) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to full tasks list
                _showFeatureComingSoonSnackBar('Task management');
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: _ProjectDetailConstants.defaultSpacing),
        ProjectTasksWidget(
          project: project,
          onViewAllTasks: () {
            _showFeatureComingSoonSnackBar('Task management');
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedDetailsSection(Project project) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: _ProjectDetailConstants.defaultSpacing),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(_ProjectDetailConstants.borderRadius),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: ProjectDetailsWidget(project: project),
        ),
      ],
    );
  }

  // Enhanced floating action button
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
              duration: _ProjectDetailConstants.animationDuration,
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

  Widget _buildAuthenticationRequiredView(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Required'),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please sign in to view project details',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/auth'),
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Project Data',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No project data is currently available',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                _projectBloc.add(const ProjectLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Error Loading Project',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  _projectBloc.add(const ProjectLoadRequested());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectNotFoundView(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Not Found'),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'Project Not Found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The requested project could not be found',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Utility methods
  void _updateUserRole(User user) {
    _currentUserRole = UserRole.fromString(user.roleName);
  }

  void _updateTabControllerForUser() {
    final newLength = _getTabCountForRole(_currentUserRole);
    
    if (_tabController.length != newLength) {
      _tabController.dispose();
      _tabController = TabController(length: newLength, vsync: this);
    }
  }

  int _getTabCountForRole(UserRole role) {
    return role.tabCount;
  }

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

  void _loadProjectDailyReports() {
    if (_project != null) {
      _dailyReportsCubit.loadDailyReports(
        filters: DailyReportsFilterParams(
          projectId: _project!.projectId,
          pageSize: _ProjectDetailConstants.projectReportsPageSize,
        ),
      );
    }
  }

  // Enhanced action handlers with better user feedback
  void _handleEditProject(Project project) {
    _showFeatureComingSoonSnackBar('Edit project');
  }

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

  void _handleDeleteProject(Project project) {
    _showDeleteProjectDialog(context, project);
  }

  void _showFeatureComingSoonSnackBar(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName functionality coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteProjectDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.projectName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Tab content builders with improved organization
  Widget _buildOverviewTab(Project project, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_ProjectDetailConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedStatsSection(project),
          const SizedBox(height: _ProjectDetailConstants.largeSpacing),
          _buildEnhancedDescriptionSection(project),
          const SizedBox(height: _ProjectDetailConstants.largeSpacing),
          _buildEnhancedDetailsSection(project),
        ],
      ),
    );
  }

  Widget _buildMasterPlanTab(Project project) {
    return _buildComingSoonView('Master Plan');
  }

  Widget _buildProgressTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_ProjectDetailConstants.cardPadding),
      child: Column(children: [_buildEnhancedProgressSection(project)]),
    );
  }

  Widget _buildTasksTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_ProjectDetailConstants.cardPadding),
      child: Column(children: [_buildEnhancedTasksSection(project)]),
    );
  }

  Widget _buildDailyReportsTab(Project project, User user) {
    final theme = Theme.of(context);
    final isUser = _currentUserRole.isFieldUser;
    final isManagerOrAdmin = _currentUserRole.hasFullAccess;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_ProjectDetailConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyReportsHeader(theme, isUser, isManagerOrAdmin, project),
          const SizedBox(height: _ProjectDetailConstants.cardPadding),
          _buildProjectReportsWidget(project),
          const SizedBox(height: _ProjectDetailConstants.cardPadding),
          _buildRoleSpecificContent(isUser, isManagerOrAdmin, project, user),
        ],
      ),
    );
  }

  Widget _buildDailyReportsHeader(ThemeData theme, bool isUser, bool isManagerOrAdmin, Project project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isUser ? 'Add Daily Report' : 'Daily Reports',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isUser)
          FilledButton.icon(
            onPressed: () => _navigateToCreateDailyReport(project),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Report'),
          ),
        if (isManagerOrAdmin)
          TextButton.icon(
            onPressed: () => _navigateToDailyReports(project),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('View All'),
          ),
      ],
    );
  }

  Widget _buildProjectReportsWidget(Project project) {
    return ProjectReportsWidget(
      project: project,
      onViewAllReports: () => _navigateToDailyReports(project),
      onCreateNewReport: () => _navigateToCreateDailyReport(project),
    );
  }

  Widget _buildRoleSpecificContent(bool isUser, bool isManagerOrAdmin, Project project, User user) {
    if (isUser) {
      return _buildUserDailyReportsContent(project, user);
    } else if (isManagerOrAdmin) {
      return _buildManagerAdminDailyReportsContent(project, user);
    }
    return const SizedBox.shrink();
  }

  Widget _buildWeeklyReportsTab(Project project) {
    return _buildComingSoonView('Weekly Reports');
  }

  Widget _buildWorkReportsTab(Project project) {
    return _buildComingSoonView('Work Reports');
  }

  Widget _buildComingSoonView(String featureName) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_ProjectDetailConstants.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: _ProjectDetailConstants.defaultSpacing),
            Text(
              '$featureName - Coming Soon',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: _ProjectDetailConstants.smallSpacing),
            Text(
              'This feature is currently under development',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods with error handling
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
      _showFeatureComingSoonSnackBar('Daily reports navigation');
    }
  }

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
      _showFeatureComingSoonSnackBar('Create daily report');
    }
  }

  /// Role-based access control system:
  /// - ADMIN: Full access to all 7 tabs (Overview, Master Plan, Progress, Tasks, Daily Reports, Weekly Reports, Work Reports)
  /// - MANAGER: Project Management access to all 7 tabs (same as ADMIN)
  /// - USER: Field Operations access limited to 4 tabs (Overview, Daily Reports, Weekly Reports, Work Reports)
  ///
  /// This matches the test accounts from user.md:
  /// - test_admin@example.com (ADMIN role) - Full system access
  /// - test_manager@example.com (MANAGER role) - Project management access
  /// - test_user@example.com (USER role) - Field operations access

  // Helper method to get tab views based on user permissions
  List<Widget> _getTabViewsForUser(Project project, User user) {
    return switch (_currentUserRole) {
      UserRole.admin || UserRole.manager => [
        _buildOverviewTab(project, user),
        _buildMasterPlanTab(project),
        _buildProgressTab(project),
        _buildTasksTab(project),
        _buildDailyReportsTab(project, user),
        _buildWeeklyReportsTab(project),
        _buildWorkReportsTab(project),
      ],
      UserRole.user => [
        _buildOverviewTab(project, user),
        _buildDailyReportsTab(project, user),
        _buildWeeklyReportsTab(project),
        _buildWorkReportsTab(project),
      ],
    };
  }

  // Role-specific daily reports views
  Widget _buildUserDailyReportsContent(Project project, User user) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCreateReportCard(theme, project),
        const SizedBox(height: _ProjectDetailConstants.cardPadding),
        Text(
          'Your Recent Reports',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildUserRecentReports(project, user),
      ],
    );
  }

  Widget _buildCreateReportCard(ThemeData theme, Project project) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_ProjectDetailConstants.borderRadius),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_ProjectDetailConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_add,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Create Daily Report',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _ProjectDetailConstants.defaultSpacing),
            Text(
              'Document your daily work progress, achievements, and any issues encountered.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: _ProjectDetailConstants.cardPadding),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _navigateToCreateDailyReport(project),
                icon: const Icon(Icons.add),
                label: const Text('Create New Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerAdminDailyReportsContent(Project project, User user) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reports overview stats
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reports Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildReportStatCard(
                        context,
                        'This Week',
                        '12',
                        Icons.today,
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildReportStatCard(
                        context,
                        'This Month',
                        '45',
                        Icons.calendar_month,
                        theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildReportStatCard(
                        context,
                        'Team Members',
                        '8',
                        Icons.people,
                        theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Recent reports from all team members
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Team Reports',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () => _navigateToDailyReports(project),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTeamRecentReports(project, user),
      ],
    );
  }

  Widget _buildReportStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRecentReports(Project project, User user) {
    final theme = Theme.of(context);

    return BlocBuilder<DailyReportsCubit, DailyReportsState>(
      builder: (context, state) {
        if (state is DailyReportsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DailyReportsLoaded) {
          // Filter reports by current user (technician)
          final userReports = state.reports
              .where((report) => report.technicianId == user.userId)
              .take(3) // Show only the 3 most recent
              .toList();

          if (userReports.isEmpty) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reports yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first daily report to get started',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            children: userReports.map((report) {
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(report.status, theme),
                    child: Icon(
                      _getStatusIcon(report.status),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _formatReportDate(report.reportDate),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${report.workStartTime} - ${report.workEndTime}'),
                      if (report.workProgressItems.isNotEmpty)
                        Text(
                          report.workProgressItems.first.taskDescription,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      report.status.displayName,
                      style: theme.textTheme.bodySmall,
                    ),
                    backgroundColor: _getStatusColor(report.status, theme).withValues(alpha: 0.2),
                    side: BorderSide.none,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onTap: () => _viewDailyReportDetails(report),
                ),
              );
            }).toList(),
          );
        }

        // Show empty state for error or other states
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load reports',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadProjectDailyReports,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamRecentReports(Project project, User user) {
    final theme = Theme.of(context);

    return BlocBuilder<DailyReportsCubit, DailyReportsState>(
      builder: (context, state) {
        if (state is DailyReportsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DailyReportsLoaded) {
          // Show all team reports (not filtered by user)
          final teamReports = state.reports.take(5).toList(); // Show recent 5

          if (teamReports.isEmpty) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No team reports yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            children: teamReports.map((report) {
              final technicianName = report.technician?.fullName ?? 'Unknown User';
              final initials = _getInitials(technicianName);
              
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          technicianName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatReportDate(report.reportDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${report.workStartTime} - ${report.workEndTime}'),
                      if (report.workProgressItems.isNotEmpty)
                        Text(
                          report.workProgressItems.first.taskDescription,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => _viewDailyReportDetails(report),
                ),
              );
            }).toList(),
          );
        }

        // Show error state
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load team reports',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadProjectDailyReports,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to navigate to daily report details with error handling
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

  // Helper methods for daily report status display
  Color _getStatusColor(DailyReportStatus status, ThemeData theme) {
    switch (status) {
      case DailyReportStatus.draft:
        return Colors.grey;
      case DailyReportStatus.submitted:
        return Colors.orange;
      case DailyReportStatus.approved:
        return Colors.green;
      case DailyReportStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(DailyReportStatus status) {
    switch (status) {
      case DailyReportStatus.draft:
        return Icons.edit;
      case DailyReportStatus.submitted:
        return Icons.schedule;
      case DailyReportStatus.approved:
        return Icons.check;
      case DailyReportStatus.rejected:
        return Icons.close;
    }
  }

  String _formatReportDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}

// Add these missing model classes or ensure they exist in the Project entity
extension ProjectExtensions on Project {
  // If these properties don't exist, add them to your Project entity
  List<ProjectTask> get tasks => [];
  List<RecentReport> get recentReports => [];
  double? get budget => null;
  double? get actualCost => null;
  int? get totalTasks => taskCount;
  int? get completedTasks => completedTaskCount;
}

class ProjectTask {
  final String title;
  final String status;
  final DateTime dueDate;

  ProjectTask({
    required this.title,
    required this.status,
    required this.dueDate,
  });
}

class RecentReport {
  final DateTime reportDate;
  final String userName;
  final String hoursWorked;

  RecentReport({
    required this.reportDate,
    required this.userName,
    required this.hoursWorked,
  });
}
