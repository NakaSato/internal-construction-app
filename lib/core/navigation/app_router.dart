import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_state.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';

import '../../features/calendar/presentation/screens/calendar_management_screen.dart';
import '../../features/calendar/presentation/screens/modern_schedule_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/projects/presentation/screens/image_project_card_list_screen.dart';
import '../../features/projects/presentation/screens/create_project_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../widgets/main_app_screen.dart';

/// Application route names
class AppRoutes {
  // Authentication routes
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/';
  static const String profile = '/profile';

  // Bottom navigation routes
  static const String dashboard = '/dashboard';
  static const String approvals = '/approvals';

  // Feature routes
  static const String calendar = '/calendar';
  static const String calendarDetail = '/calendar/:id';
  static const String calendarManagement = '/calendar-management';
  static const String modernSchedule = '/modern-schedule';

  // Project management routes
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String createProject = '/projects/create';

  // Notification routes
  static const String notifications = '/notifications';

  // Private constructor to prevent instantiation
  AppRoutes._();
}

/// Global navigation key for app-wide navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Application router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.login, // Start with login screen for authentication-first approach
    debugLogDiagnostics: true,
    routes: [
      // Authentication routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(), // Use enhanced login screen
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Protected main app routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainAppScreen(),
        routes: [
          // Nested routes
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const MainAppScreen(initialTabIndex: 3), // Profile tab
          ),
        ],
      ),

      // Protected bottom navigation tab routes for deep linking
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const MainAppScreen(initialTabIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.approvals,
        name: 'approvals',
        builder: (context, state) => const MainAppScreen(initialTabIndex: 2),
      ),

      // Protected feature routes
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        builder: (context, state) => const MainAppScreen(initialTabIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.calendarManagement,
        name: 'calendar-management',
        builder: (context, state) => const CalendarManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.modernSchedule,
        name: 'modern-schedule',
        builder: (context, state) => const ModernScheduleScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendarDetail,
        name: 'calendar-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Placeholder(fallbackHeight: 200, fallbackWidth: 200, child: Text('Calendar Detail: $id'));
        },
      ),
      GoRoute(path: '/projects', name: 'projects', builder: (context, state) => const ImageProjectCardListScreen()),
      GoRoute(
        path: '/projects/create',
        name: 'create-project',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        name: 'project-detail',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return ProjectDetailScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Go to Login')),
          ],
        ),
      ),
    ),

    // Authentication-first redirect logic
    redirect: (context, state) {
      // Get the current authentication state
      try {
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;

        final currentLocation = state.matchedLocation;
        final isAuthRoute = _isAuthenticationRoute(currentLocation);
        final isAuthenticated = authState is AuthAuthenticated;

        // If user is not authenticated and trying to access protected routes
        if (!isAuthenticated && !isAuthRoute) {
          return AppRoutes.login;
        }

        // If user is authenticated and on auth routes, redirect to home
        if (isAuthenticated && isAuthRoute) {
          return AppRoutes.home;
        }

        // No redirect needed
        return null;
      } catch (e) {
        // If auth context is not available, redirect to login
        return AppRoutes.login;
      }
    },
  );

  /// Check if the current route is an authentication route
  static bool _isAuthenticationRoute(String location) {
    return location.startsWith(AppRoutes.login) || location.startsWith(AppRoutes.forgotPassword);
  }

  // Private constructor to prevent instantiation
  AppRouter._();
}
