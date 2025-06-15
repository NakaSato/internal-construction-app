import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

// Core imports
import '../navigation/app_router.dart';
import 'app_bottom_bar.dart';
import 'common_widgets.dart';
import 'app_header.dart';

// Feature imports - Authentication
import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_state.dart';

// Feature imports - Calendar Management
import '../../features/calendar_management/presentation/screens/calendar_management_screen.dart';
import '../../features/calendar_management/application/calendar_management_bloc.dart';
import '../../features/calendar_management/application/calendar_management_event.dart'
    as cm_events;
import '../../features/calendar_management/config/mock_calendar_management_di.dart';

// Feature imports - Work Request Approval
import '../../features/work_request_approval/presentation/screens/my_work_requests_screen.dart';
import '../../features/work_request_approval/application/cubits/my_work_requests_cubit.dart';
import '../../features/work_request_approval/domain/usecases/get_my_work_requests_usecase.dart';
import '../../features/work_request_approval/infrastructure/repositories/mock_work_request_approval_repository.dart';

// Feature imports - Project Management
import '../../features/project_management/application/project_bloc.dart';
import '../../features/project_management/application/project_state.dart';
import '../../features/project_management/application/project_event.dart';
import '../../features/project_management/presentation/widgets/project_card.dart';

// Feature imports - Profile
import '../../features/profile/presentation/screens/profile_screen.dart';

/// Tab indices for bottom navigation
enum AppTab {
  dashboard(0),
  calendar(1),
  approvals(2),
  profile(3);

  const AppTab(this.value);
  final int value;
}

/// Main application screen that handles authentication state and bottom navigation
class MainAppScreen extends StatefulWidget {
  /// Optional initial tab index for deep linking support
  final int? initialTabIndex;

  const MainAppScreen({super.key, this.initialTabIndex});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late TabController _tabController;

  // Constants for better maintainability
  static const double _defaultPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex ?? AppTab.dashboard.value;
    _tabController = TabController(
      length: AppTab.values.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Redirect to login if user becomes unauthenticated
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthLoading() => const Scaffold(
              body: Center(child: LoadingIndicator()),
            ),
            AuthAuthenticated() => _buildAuthenticatedApp(context, state),
            AuthUnauthenticated() => const Scaffold(
              body: Center(child: LoadingIndicator()),
            ),
            AuthFailure() => _buildAuthErrorState(context, state),
            _ => const Scaffold(body: Center(child: LoadingIndicator())),
          };
        },
      ),
    );
  }

  /// Builds authentication error state UI
  Widget _buildAuthErrorState(BuildContext context, AuthFailure state) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedApp(BuildContext context, AuthAuthenticated state) {
    // Initialize calendar management dependencies
    configureCalendarManagementDependencies();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home/Dashboard - uses the existing authenticated home
          _buildDashboardTab(context, state),
          // Calendar - Enhanced Calendar Management with API integration
          MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    GetIt.instance<CalendarManagementBloc>()
                      ..add(const cm_events.CalendarEventsRequested()),
              ),
            ],
            child: const CalendarManagementScreen(),
          ),
          // Work Request Approvals
          BlocProvider(
            create: (context) => MyWorkRequestsCubit(
              GetMyWorkRequestsUseCase(MockWorkRequestApprovalRepository()),
            ),
            child: const MyWorkRequestsScreen(),
          ),
          // Profile - extracted to dedicated screen
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (mounted && index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  /// Dashboard tab content (replaces the original HomeScreen content)
  Widget _buildDashboardTab(BuildContext context, AuthAuthenticated state) {
    return Scaffold(
      appBar: AppHeader(
        user: state.user,
        title: 'Dashboard',
        heroContext: 'dashboard',
        showNotificationBadge: true,
        notificationCount: 3,
        onProfileTap: () => _navigateToProfileTab(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshDashboard(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(_defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Section - Outside of card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search projects',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Advanced filters coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.filter_list,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Filters',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: (value) {},
                ),
              ),
              _buildProjectListCard(context),
              // Add space for future dashboard sections
              const SizedBox(height: _defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to profile tab
  void _navigateToProfileTab() {
    setState(() {
      _currentIndex = AppTab.profile.value;
    });
  }

  /// Refresh dashboard content
  Future<void> _refreshDashboard(BuildContext context) async {
    try {
      // Refresh projects
      final projectBloc = context.read<ProjectBloc>();
      projectBloc.add(const ProjectLoadRequested());

      // Wait a moment to show refresh indicator
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      // Show error message if refresh fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing dashboard: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Project list card with all projects in compact format
  Widget _buildProjectListCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(
              _defaultPadding,
              _defaultPadding,
              _defaultPadding,
              2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Spacer(),
                BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, state) {
                    if (state is ProjectLoaded) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.projects.length}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(_defaultPadding),
            child: BlocProvider(
              create: (context) =>
                  GetIt.instance<ProjectBloc>()
                    ..add(const ProjectLoadRequested()),
              child: BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return _buildLoadingState(context);
                  } else if (state is ProjectLoaded) {
                    final allProjects = state.projects;

                    if (allProjects.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return _buildProjectList(context, allProjects);
                  } else if (state is ProjectError) {
                    return _buildErrorState(context, state.message);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading projects...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No projects yet',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Create your first project to get started',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              // Navigate to create project
              context.push('/projects/create');
            },
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Create Project'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load projects',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                context.read<ProjectBloc>().add(
                  const ProjectRefreshRequested(),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, List<dynamic> allProjects) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectBloc>().add(const ProjectRefreshRequested());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 250));
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: allProjects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final project = allProjects[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 50)),
                curve: Curves.easeOutCubic,
                child: ProjectCard(
                  project: project,
                  isCompact: true,
                  onTap: () {
                    context.push('/projects/${project.id}');
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
