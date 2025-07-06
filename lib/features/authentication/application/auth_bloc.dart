import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/services/token_service.dart';
import '../../../core/services/security_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../infrastructure/auth_repository_factory.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepositoryFactory, this._tokenService, this._securityService) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);
    on<AuthEmailVerifyRequested>(_onEmailVerifyRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthTokenValidationRequested>(_onTokenValidationRequested);
    on<AuthTokenExpiredEvent>(_onTokenExpiredEvent);
  }

  final AuthRepositoryFactory _authRepositoryFactory;
  final TokenService _tokenService;
  final SecurityService _securityService;

  /// Get the appropriate auth repository based on configuration
  AuthRepository get _authRepository => _authRepositoryFactory.getAuthRepository();

  /// Handle checking initial authentication state
  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle sign in with email and password
  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.username, // username field contains email
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle user registration
  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.fullName,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle password reset request
  Future<void> _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(const AuthPasswordResetSent());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle sign out
  Future<void> _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle email verification request
  Future<void> _onEmailVerificationRequested(AuthEmailVerificationRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      await _authRepository.sendEmailVerification();
      emit(const AuthEmailVerificationSent());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle email verification with code
  Future<void> _onEmailVerifyRequested(AuthEmailVerifyRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.verifyEmail(event.verificationCode);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle profile update
  Future<void> _onProfileUpdateRequested(AuthProfileUpdateRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.updateProfile(
        name: event.name,
        phoneNumber: event.phoneNumber,
        profileImageUrl: event.profileImageUrl,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle token refresh
  Future<void> _onTokenRefreshRequested(AuthTokenRefreshRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final refreshResult = await _tokenService.refreshToken();

      if (refreshResult.isSuccess && refreshResult.token != null) {
        emit(AuthTokenRefreshed(token: refreshResult.token!));

        // Check if we have a current user after token refresh
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        }
      } else {
        // Token refresh failed, force logout
        await _securityService.secureLogout();
        emit(AuthTokenExpired(message: refreshResult.error ?? 'Token refresh failed'));
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      // Token refresh failed, force logout
      await _securityService.secureLogout();
      emit(AuthTokenExpired(message: e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle token validation
  Future<void> _onTokenValidationRequested(AuthTokenValidationRequested event, Emitter<AuthState> emit) async {
    try {
      final isValid = await _tokenService.isTokenValid();

      if (isValid) {
        // Check if token needs refresh
        final shouldRefresh = await _tokenService.shouldRefreshToken();
        if (shouldRefresh) {
          // Automatically refresh token
          add(const AuthTokenRefreshRequested());
        } else {
          emit(const AuthTokenValid());
        }
      } else {
        // Token is invalid, try to refresh
        add(const AuthTokenRefreshRequested());
      }
    } catch (e) {
      emit(const AuthTokenInvalid());
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle token expired event
  Future<void> _onTokenExpiredEvent(AuthTokenExpiredEvent event, Emitter<AuthState> emit) async {
    try {
      await _securityService.secureLogout();
      emit(AuthTokenExpired(message: event.message));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
