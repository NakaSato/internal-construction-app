import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../services/session_validation_service.dart';
import '../services/token_service.dart';
import '../navigation/app_router.dart';

/// Enhanced interceptor that handles authentication errors with automatic token refresh
/// Features:
/// - Automatic token refresh on 401 errors
/// - Intelligent retry logic for failed requests
/// - Session validation before API calls
/// - Graceful logout when refresh fails
class AuthInterceptor extends Interceptor {
  static bool _isHandling401 = false; // Prevent multiple simultaneous logouts

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip session validation for auth endpoints to avoid infinite loops
    if (_isAuthEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    try {
      // Validate session and refresh token if needed before making the request
      final sessionService = GetIt.instance.get<SessionValidationService>();
      final sessionValid = await sessionService.ensureValidSession();

      if (!sessionValid) {
        // Session is invalid and cannot be restored, reject the request
        final error = DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            statusMessage: 'Session invalid - user logged out',
          ),
          type: DioExceptionType.badResponse,
        );
        handler.reject(error);
        return;
      }

      // Session is valid, add Authorization header
      final tokenService = GetIt.instance.get<TokenService>();
      final accessToken = await tokenService.getAccessToken();

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        if (kDebugMode) {
          debugPrint('✅ [AUTH_INTERCEPTOR] Added Authorization header to request: ${options.method} ${options.path}');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ [AUTH_INTERCEPTOR] No access token available for request: ${options.method} ${options.path}');
        }
      }

      // Session is valid, proceed with the request
      handler.next(options);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AUTH_INTERCEPTOR] Session validation error: $e');
      }
      // If session validation fails, proceed with the request
      // The onError handler will catch any 401 responses
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors with automatic retry
    if (err.response?.statusCode == 401 && !_isHandling401 && !_isAuthEndpoint(err.requestOptions.path)) {
      _isHandling401 = true;

      try {
        if (kDebugMode) {
          debugPrint('🔄 [AUTH_INTERCEPTOR] Handling 401 error, attempting token refresh...');
        }

        // Attempt to refresh the session
        final sessionService = GetIt.instance.get<SessionValidationService>();
        final result = await sessionService.validateSession(forceRefresh: true);

        if (result.isSuccess) {
          // Token refreshed successfully, retry the original request
          if (kDebugMode) {
            debugPrint('✅ [AUTH_INTERCEPTOR] Token refreshed, retrying request');
          }

          // Retry the original request with the new token
          try {
            final response = await Dio().fetch(err.requestOptions);
            handler.resolve(response);
            return;
          } catch (retryError) {
            if (kDebugMode) {
              debugPrint('❌ [AUTH_INTERCEPTOR] Retry failed: $retryError');
            }
            // If retry fails, proceed with the original error
            handler.next(err);
            return;
          }
        } else {
          // Token refresh failed, force logout
          if (kDebugMode) {
            debugPrint('❌ [AUTH_INTERCEPTOR] Token refresh failed: ${result.error}');
          }
          await _forceLogoutDueToAuthFailure(result.error ?? 'Token refresh failed');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [AUTH_INTERCEPTOR] Error during 401 handling: $e');
        }
        await _forceLogoutDueToAuthFailure('Authentication error: $e');
      } finally {
        // Reset the handling flag after a delay
        Future.delayed(const Duration(seconds: 2), () {
          _isHandling401 = false;
        });
      }
    }

    handler.next(err);
  }

  /// Check if the endpoint is an authentication endpoint
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/') || path.contains('/login') || path.contains('/refresh') || path.contains('/logout');
  }

  /// Force logout when authentication cannot be restored
  Future<void> _forceLogoutDueToAuthFailure(String reason) async {
    try {
      if (kDebugMode) {
        debugPrint('🚨 [AUTH_INTERCEPTOR] Forcing logout: $reason');
      }

      // Use the session validation service to handle logout
      final sessionService = GetIt.instance.get<SessionValidationService>();
      await sessionService.forceLogoutDueToInvalidSession(reason);

      // Show user notification
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
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

      if (kDebugMode) {
        debugPrint('✅ [AUTH_INTERCEPTOR] Logout completed and user redirected to login');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AUTH_INTERCEPTOR] Error during forced logout: $e');
      }
    }
  }
}
