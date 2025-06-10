import 'package:flutter_bloc/flutter_bloc.dart';

import 'authorization_event.dart';
import 'authorization_state.dart';
import '../domain/services/authorization_service.dart';

/// BLoC for managing authorization state
class AuthorizationBloc extends Bloc<AuthorizationEvent, AuthorizationState> {
  AuthorizationBloc({required AuthorizationService authorizationService})
    : _authorizationService = authorizationService,
      super(const AuthorizationInitial()) {
    on<AuthorizationLoadRequested>(_onLoadRequested);
    on<AuthorizationPermissionCheckRequested>(_onPermissionCheckRequested);
    on<AuthorizationRefreshRequested>(_onRefreshRequested);
    on<AuthorizationClearRequested>(_onClearRequested);
    on<AuthorizationRolesLoadRequested>(_onRolesLoadRequested);
    on<AuthorizationPermissionsLoadRequested>(_onPermissionsLoadRequested);
  }

  final AuthorizationService _authorizationService;

  Future<void> _onLoadRequested(
    AuthorizationLoadRequested event,
    Emitter<AuthorizationState> emit,
  ) async {
    emit(const AuthorizationLoading());

    try {
      final user = event.user;

      // Check if user is active
      if (!user.isActive) {
        emit(
          const AuthorizationUnauthorized(reason: 'User account is inactive'),
        );
        return;
      }

      // Get user role
      final role = await _authorizationService.getUserRole(user);
      if (role == null) {
        emit(const AuthorizationUnauthorized(reason: 'User role not found'));
        return;
      }

      // Check if role is active
      if (!role.isActive) {
        emit(const AuthorizationUnauthorized(reason: 'User role is inactive'));
        return;
      }

      final permissions = await _authorizationService.getUserPermissions(user);

      emit(
        AuthorizationLoaded(user: user, role: role, permissions: permissions),
      );
    } catch (e) {
      emit(AuthorizationFailure(message: e.toString()));
    }
  }

  Future<void> _onPermissionCheckRequested(
    AuthorizationPermissionCheckRequested event,
    Emitter<AuthorizationState> emit,
  ) async {
    try {
      final hasPermission = await _authorizationService.hasPermission(
        event.user,
        event.resource,
        event.action,
      );

      emit(
        AuthorizationPermissionChecked(
          resource: event.resource,
          action: event.action,
          hasPermission: hasPermission,
        ),
      );
    } catch (e) {
      emit(AuthorizationFailure(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    AuthorizationRefreshRequested event,
    Emitter<AuthorizationState> emit,
  ) async {
    // Clear cache and reload
    add(AuthorizationLoadRequested(user: event.user));
  }

  Future<void> _onClearRequested(
    AuthorizationClearRequested event,
    Emitter<AuthorizationState> emit,
  ) async {
    emit(const AuthorizationInitial());
  }

  Future<void> _onRolesLoadRequested(
    AuthorizationRolesLoadRequested event,
    Emitter<AuthorizationState> emit,
  ) async {
    emit(const AuthorizationLoading());

    try {
      final roles = await _authorizationService.getAllRoles();
      emit(AuthorizationRolesLoaded(roles: roles));
    } catch (e) {
      emit(AuthorizationFailure(message: e.toString()));
    }
  }

  Future<void> _onPermissionsLoadRequested(
    AuthorizationPermissionsLoadRequested event,
    Emitter<AuthorizationState> emit,
  ) async {
    emit(const AuthorizationLoading());

    try {
      final permissions = await _authorizationService.getAllPermissions();
      emit(AuthorizationPermissionsLoaded(permissions: permissions));
    } catch (e) {
      emit(AuthorizationFailure(message: e.toString()));
    }
  }
}
