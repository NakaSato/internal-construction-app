import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/repositories/auth_repository.dart';
import '../infrastructure/auth_repository_factory.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepositoryFactory) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);
    on<AuthEmailVerifyRequested>(_onEmailVerifyRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  final AuthRepositoryFactory _authRepositoryFactory;

  /// Get the appropriate auth repository based on configuration
  AuthRepository get _authRepository =>
      _authRepositoryFactory.getAuthRepository();

  /// Handle checking initial authentication state
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
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
  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
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
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
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
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(const AuthPasswordResetSent());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle sign out
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle email verification request
  Future<void> _onEmailVerificationRequested(
    AuthEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.sendEmailVerification();
      emit(const AuthEmailVerificationSent());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle email verification with code
  Future<void> _onEmailVerifyRequested(
    AuthEmailVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.verifyEmail(event.verificationCode);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle profile update
  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
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
}
