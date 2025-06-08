import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/image_upload/presentation/screens/image_upload_screen.dart';
import '../widgets/main_app_screen.dart';

/// Application route names
class AppRoutes {
  // Authentication routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/';
  static const String profile = '/profile';

  // Bottom navigation routes
  static const String dashboard = '/dashboard';
  static const String featured = '/featured';

  // Feature routes
  static const String imageUpload = '/image-upload';
  static const String locationTracking = '/location';
  static const String calendar = '/calendar';
  static const String calendarDetail = '/calendar/:id';

  // Private constructor to prevent instantiation
  AppRoutes._();
}

/// Global navigation key for app-wide navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Application router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Authentication routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainAppScreen(),
        routes: [
          // Nested routes
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) =>
                const MainAppScreen(initialTabIndex: 4), // Profile tab
          ),
        ],
      ),

      // Bottom navigation tab routes for deep linking
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const MainAppScreen(initialTabIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.featured,
        name: 'featured',
        builder: (context, state) => const MainAppScreen(initialTabIndex: 1),
      ),

      // Feature routes
      GoRoute(
        path: AppRoutes.imageUpload,
        name: 'image-upload',
        builder: (context, state) => const ImageUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationTracking,
        name: 'location',
        builder: (context, state) => const MainAppScreen(initialTabIndex: 3),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        builder: (context, state) => const MainAppScreen(initialTabIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.calendarDetail,
        name: 'calendar-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Placeholder(
            fallbackHeight: 200,
            fallbackWidth: 200,
            child: Text(
              'Calendar Detail: $id',
            ), // TODO: Replace with CalendarDetailScreen(id: id)
          );
        },
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
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),

    // Redirect logic (e.g., authentication checks)
    redirect: (context, state) {
      // TODO: Implement authentication redirect logic
      // Example:
      // final isLoggedIn = AuthService.isLoggedIn;
      // final isLoginRoute = state.matchedLocation.startsWith('/login');
      //
      // if (!isLoggedIn && !isLoginRoute) {
      //   return AppRoutes.login;
      // }
      //
      // if (isLoggedIn && isLoginRoute) {
      //   return AppRoutes.home;
      // }

      return null; // No redirect needed
    },
  );

  // Private constructor to prevent instantiation
  AppRouter._();
}
