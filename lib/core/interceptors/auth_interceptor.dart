import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_event.dart';
import '../navigation/app_router.dart';

/// Interceptor that handles authentication errors (401)
/// Automatically logs out user and redirects to login when token is invalid
class AuthInterceptor extends Interceptor {
  static bool _isHandling401 = false; // Prevent multiple simultaneous logouts

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401 && !_isHandling401) {
      _isHandling401 = true;
      _handleUnauthorized();
    }

    handler.next(err);
  }

  /// Handle unauthorized access by logging out user and redirecting to login
  void _handleUnauthorized() async {
    try {
      // Get the AuthBloc from dependency injection
      final authBloc = GetIt.instance.get<AuthBloc>();

      // Trigger logout
      authBloc.add(const AuthSignOutRequested());

      // Navigate to login screen using the global navigator key
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        // Show a snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to login
        context.go(AppRoutes.login);
      }

      debugPrint('🔐 Auth Interceptor: Token invalid/expired - User logged out and redirected to login');
    } catch (e) {
      debugPrint('❌ Auth Interceptor: Error handling 401 - $e');
    } finally {
      // Reset the handling flag after a delay to allow for new 401s
      Future.delayed(const Duration(seconds: 2), () {
        _isHandling401 = false;
      });
    }
  }
}
