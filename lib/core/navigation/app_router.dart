import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/home_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/image_upload/presentation/screens/image_upload_screen.dart';
import '../../features/location_tracking/presentation/screens/location_tracking_screen.dart';
import '../../features/work_calendar/presentation/screens/calendar_screen.dart';

/// Application route names
class AppRoutes {
  // Authentication routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/';
  static const String profile = '/profile';

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
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Nested routes
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) =>
                const Placeholder(), // TODO: Replace with ProfileScreen
          ),
        ],
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
        builder: (context, state) => const LocationTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
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
