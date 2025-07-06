import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'token_service.dart';
import 'security_service.dart';
import '../di/injection.dart';
import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_event.dart';

/// Enhanced service for automatic session validation and token refresh
///
/// This service provides:
/// - Automatic token validation before API calls
/// - Intelligent token refresh with retry logic
/// - Session timeout detection and handling
/// - Graceful logout when refresh fails
/// - Background session monitoring
@LazySingleton()
class SessionValidationService {
  SessionValidationService(this._tokenService, this._securityService);

  final TokenService _tokenService;
  final SecurityService _securityService;

  // Session validation constants
  static const int _maxRefreshRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _sessionCheckInterval = Duration(minutes: 5);

  // Background session monitoring
  Timer? _sessionMonitorTimer;
  bool _isSessionValid = false;
  DateTime? _lastValidation;

  /// Validate current session and refresh token if needed
  /// Returns true if session is valid, false if user needs to re-authenticate
  Future<SessionValidationResult> validateSession({bool forceRefresh = false, bool silentMode = false}) async {
    try {
      if (kDebugMode && !silentMode) {
        debugPrint('🔍 [SESSION] Starting session validation...');
      }

      // Quick check if we have any tokens
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null) {
        if (kDebugMode && !silentMode) {
          debugPrint('❌ [SESSION] No access token found');
        }
        return SessionValidationResult.failed('No access token');
      }

      // Check if we're already in a good state (unless forced)
      if (!forceRefresh && _isSessionValid && _lastValidation != null) {
        final timeSinceLastCheck = DateTime.now().difference(_lastValidation!);
        if (timeSinceLastCheck < const Duration(minutes: 1)) {
          if (kDebugMode && !silentMode) {
            debugPrint('✅ [SESSION] Using cached validation result');
          }
          return SessionValidationResult.success();
        }
      }

      // Validate token format and expiration
      final isTokenValid = await _tokenService.isTokenValid();
      final shouldRefresh = await _tokenService.shouldRefreshToken();

      if (isTokenValid && !shouldRefresh) {
        // Token is valid, update session state
        await _updateSessionState(isValid: true);
        if (kDebugMode && !silentMode) {
          debugPrint('✅ [SESSION] Token is valid, no refresh needed');
        }
        return SessionValidationResult.success();
      }

      // Token needs refresh or is invalid
      if (kDebugMode && !silentMode) {
        debugPrint('🔄 [SESSION] Token needs refresh (valid: $isTokenValid, shouldRefresh: $shouldRefresh)');
      }

      // Attempt token refresh with retry logic
      final refreshResult = await _attemptTokenRefreshWithRetry();

      if (refreshResult.isSuccess) {
        await _updateSessionState(isValid: true);
        if (kDebugMode && !silentMode) {
          debugPrint('✅ [SESSION] Token refreshed successfully');
        }
        return SessionValidationResult.success();
      } else {
        // Refresh failed, session is invalid
        await _updateSessionState(isValid: false);
        if (kDebugMode) {
          debugPrint('❌ [SESSION] Token refresh failed: ${refreshResult.error}');
        }
        return SessionValidationResult.failed(refreshResult.error ?? 'Token refresh failed');
      }
    } catch (e) {
      await _updateSessionState(isValid: false);
      if (kDebugMode) {
        debugPrint('❌ [SESSION] Session validation error: $e');
      }
      return SessionValidationResult.failed('Session validation error: $e');
    }
  }

  /// Attempt token refresh with exponential backoff retry logic
  Future<TokenRefreshResult> _attemptTokenRefreshWithRetry() async {
    for (int attempt = 1; attempt <= _maxRefreshRetries; attempt++) {
      try {
        if (kDebugMode) {
          debugPrint('🔄 [SESSION] Token refresh attempt $attempt/$_maxRefreshRetries');
        }

        final result = await _tokenService.refreshToken();

        if (result.isSuccess) {
          if (kDebugMode) {
            debugPrint('✅ [SESSION] Token refresh succeeded on attempt $attempt');
          }
          return result;
        }

        // If this was the last attempt, return the failure
        if (attempt == _maxRefreshRetries) {
          if (kDebugMode) {
            debugPrint('❌ [SESSION] Token refresh failed after $attempt attempts');
          }
          return result;
        }

        // Wait before retrying with exponential backoff
        final delay = Duration(seconds: _retryDelay.inSeconds * attempt);
        if (kDebugMode) {
          debugPrint('⏳ [SESSION] Waiting ${delay.inSeconds}s before retry...');
        }
        await Future.delayed(delay);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [SESSION] Token refresh attempt $attempt failed: $e');
        }

        if (attempt == _maxRefreshRetries) {
          return TokenRefreshResult.failure('Token refresh failed: $e');
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: _retryDelay.inSeconds * attempt));
      }
    }

    return TokenRefreshResult.failure('Token refresh failed after all retries');
  }

  /// Update internal session state and activity tracking
  Future<void> _updateSessionState({required bool isValid}) async {
    _isSessionValid = isValid;
    _lastValidation = DateTime.now();

    if (isValid) {
      // Update last activity for session timeout tracking
      await _securityService.updateLastActivity();
    }
  }

  /// Force logout when session cannot be restored
  Future<void> forceLogoutDueToInvalidSession(String reason) async {
    try {
      if (kDebugMode) {
        debugPrint('🚨 [SESSION] Forcing logout due to invalid session: $reason');
      }

      // Stop session monitoring
      await stopSessionMonitoring();

      // Perform secure logout
      await _securityService.secureLogout();

      // Trigger auth bloc logout
      final authBloc = getIt<AuthBloc>();
      authBloc.add(const AuthSignOutRequested());

      if (kDebugMode) {
        debugPrint('✅ [SESSION] Forced logout completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [SESSION] Error during forced logout: $e');
      }
    }
  }

  /// Start background session monitoring
  Future<void> startSessionMonitoring() async {
    if (_sessionMonitorTimer?.isActive == true) {
      return; // Already monitoring
    }

    if (kDebugMode) {
      debugPrint('🕐 [SESSION] Starting background session monitoring');
    }

    _sessionMonitorTimer = Timer.periodic(_sessionCheckInterval, (timer) async {
      try {
        // Check session timeout
        final isTimedOut = await _securityService.isSessionTimedOut();
        if (isTimedOut) {
          if (kDebugMode) {
            debugPrint('⏰ [SESSION] Session timed out during background check');
          }
          timer.cancel();
          await forceLogoutDueToInvalidSession('Session timeout');
          return;
        }

        // Validate session silently
        final result = await validateSession(silentMode: true);
        if (!result.isSuccess) {
          if (kDebugMode) {
            debugPrint('💤 [SESSION] Background validation failed: ${result.error}');
          }
          timer.cancel();
          await forceLogoutDueToInvalidSession(result.error ?? 'Background validation failed');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [SESSION] Background monitoring error: $e');
        }
      }
    });

    // Initial validation
    await validateSession(silentMode: true);
  }

  /// Stop background session monitoring
  Future<void> stopSessionMonitoring() async {
    if (kDebugMode) {
      debugPrint('🛑 [SESSION] Stopping background session monitoring');
    }

    _sessionMonitorTimer?.cancel();
    _sessionMonitorTimer = null;
    _isSessionValid = false;
    _lastValidation = null;
  }

  /// Check if session monitoring is active
  bool get isMonitoring => _sessionMonitorTimer?.isActive == true;

  /// Get current session validity status
  bool get isSessionCurrentlyValid => _isSessionValid;

  /// Get time of last validation
  DateTime? get lastValidationTime => _lastValidation;

  /// Validate session before making API calls
  /// This is the main method that should be called before any API request
  Future<bool> ensureValidSession() async {
    final result = await validateSession();

    if (!result.isSuccess) {
      // Session is invalid and cannot be restored
      await forceLogoutDueToInvalidSession(result.error ?? 'Session validation failed');
      return false;
    }

    return true;
  }

  /// Reset session state (call on successful login)
  Future<void> onSuccessfulLogin() async {
    await _updateSessionState(isValid: true);
    await startSessionMonitoring();

    if (kDebugMode) {
      debugPrint('🎉 [SESSION] Session initialized after successful login');
    }
  }

  /// Handle app resume - validate session and refresh if needed
  Future<void> onAppResume() async {
    if (kDebugMode) {
      debugPrint('📱 [SESSION] App resumed - validating session');
    }

    final result = await validateSession(forceRefresh: false);

    if (!result.isSuccess) {
      await forceLogoutDueToInvalidSession('Session invalid on app resume');
    } else {
      // Restart monitoring if it was stopped
      if (!isMonitoring) {
        await startSessionMonitoring();
      }
    }
  }

  /// Handle app pause - stop monitoring to save resources
  Future<void> onAppPause() async {
    if (kDebugMode) {
      debugPrint('⏸️ [SESSION] App paused - updating activity timestamp');
    }

    // Update last activity before pausing
    if (_isSessionValid) {
      await _securityService.updateLastActivity();
    }
  }

  /// Dispose resources when service is no longer needed
  Future<void> dispose() async {
    await stopSessionMonitoring();
  }
}

/// Result of session validation operation
class SessionValidationResult {
  final bool isSuccess;
  final String? error;
  final DateTime timestamp;

  const SessionValidationResult._({required this.isSuccess, this.error, required this.timestamp});

  factory SessionValidationResult.success() {
    return SessionValidationResult._(isSuccess: true, timestamp: DateTime.now());
  }

  factory SessionValidationResult.failed(String error) {
    return SessionValidationResult._(isSuccess: false, error: error, timestamp: DateTime.now());
  }

  @override
  String toString() {
    return 'SessionValidationResult(isSuccess: $isSuccess, error: $error, timestamp: $timestamp)';
  }
}
