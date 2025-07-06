import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check initial authentication state
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event to sign in with username and password
class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

/// Event to register with user details
class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.roleId,
  });

  final String username;
  final String email;
  final String password;
  final String fullName;
  final int roleId;

  @override
  List<Object?> get props => [username, email, password, fullName, roleId];
}

/// Event to send password reset email
class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Event to sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Event to send email verification
class AuthEmailVerificationRequested extends AuthEvent {
  const AuthEmailVerificationRequested();
}

/// Event to verify email with code
class AuthEmailVerifyRequested extends AuthEvent {
  const AuthEmailVerifyRequested({required this.verificationCode});

  final String verificationCode;

  @override
  List<Object?> get props => [verificationCode];
}

/// Event to update user profile
class AuthProfileUpdateRequested extends AuthEvent {
  const AuthProfileUpdateRequested({this.name, this.phoneNumber, this.profileImageUrl});

  final String? name;
  final String? phoneNumber;
  final String? profileImageUrl;

  @override
  List<Object?> get props => [name, phoneNumber, profileImageUrl];
}

/// Event to refresh authentication token
class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested();
}

/// Event to check if token needs refresh and automatically refresh if needed
class AuthTokenValidationRequested extends AuthEvent {
  const AuthTokenValidationRequested();
}

/// Event to handle automatic logout due to token expiration
class AuthTokenExpiredEvent extends AuthEvent {
  const AuthTokenExpiredEvent({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}
