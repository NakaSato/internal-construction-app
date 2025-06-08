import 'package:equatable/equatable.dart';

import '../domain/entities/user.dart';

/// Authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when authentication status is unknown
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when checking authentication status
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when authentication operation fails
class AuthFailure extends AuthState {
  const AuthFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// State when password reset email is sent successfully
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

/// State when email verification is sent successfully
class AuthEmailVerificationSent extends AuthState {
  const AuthEmailVerificationSent();
}

/// State when email is verified successfully
class AuthEmailVerified extends AuthState {
  const AuthEmailVerified({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// State when profile is updated successfully
class AuthProfileUpdated extends AuthState {
  const AuthProfileUpdated({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}
