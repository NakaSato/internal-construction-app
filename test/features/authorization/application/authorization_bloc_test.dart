import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_architecture_app/features/authorization/application/authorization_bloc.dart';
import 'package:flutter_architecture_app/features/authorization/application/authorization_event.dart';
import 'package:flutter_architecture_app/features/authorization/application/authorization_state.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/permission.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/role.dart';
import 'package:flutter_architecture_app/features/authorization/domain/services/authorization_service.dart';
import 'package:flutter_architecture_app/features/authentication/domain/entities/user.dart';

import 'authorization_bloc_test.mocks.dart';

@GenerateMocks([AuthorizationService])
void main() {
  group('AuthorizationBloc', () {
    late AuthorizationBloc authorizationBloc;
    late MockAuthorizationService mockAuthorizationService;

    setUp(() {
      mockAuthorizationService = MockAuthorizationService();
      authorizationBloc = AuthorizationBloc(
        authorizationService: mockAuthorizationService,
      );
    });

    tearDown(() {
      authorizationBloc.close();
    });

    final testUser = User(
      userId: 'user_1',
      username: 'testuser',
      email: 'test@example.com',
      fullName: 'Test User',
      roleName: 'manager',
      isEmailVerified: true,
      isActive: true,
      phoneNumber: null,
      profileImageUrl: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final inactiveUser = testUser.copyWith(isActive: false);

    const testPermission = Permission(
      id: 'perm_1',
      name: 'User Read',
      resource: 'user',
      action: 'read',
    );

    final testRole = Role(
      id: 'role_1',
      name: 'manager',
      permissions: [testPermission],
      isActive: true,
    );

    final inactiveRole = testRole.copyWith(isActive: false);

    test('initial state is AuthorizationInitial', () {
      expect(authorizationBloc.state, const AuthorizationInitial());
    });

    group('AuthorizationLoadRequested', () {
      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationLoaded] when user authorization is loaded successfully',
        build: () {
          when(
            mockAuthorizationService.getUserRole(testUser),
          ).thenAnswer((_) async => testRole);
          when(
            mockAuthorizationService.getUserPermissions(testUser),
          ).thenAnswer((_) async => [testPermission]);
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(AuthorizationLoadRequested(user: testUser)),
        expect: () => [
          const AuthorizationLoading(),
          AuthorizationLoaded(
            user: testUser,
            role: testRole,
            permissions: [testPermission],
          ),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getUserRole(testUser)).called(1);
          verify(
            mockAuthorizationService.getUserPermissions(testUser),
          ).called(1);
        },
      );

      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationUnauthorized] when user is inactive',
        build: () => authorizationBloc,
        act: (bloc) => bloc.add(AuthorizationLoadRequested(user: inactiveUser)),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationUnauthorized(reason: 'User account is inactive'),
        ],
        verify: (_) {
          verifyNever(mockAuthorizationService.getUserRole(any));
        },
      );

      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationUnauthorized] when user role not found',
        build: () {
          when(
            mockAuthorizationService.getUserRole(testUser),
          ).thenAnswer((_) async => null);
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(AuthorizationLoadRequested(user: testUser)),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationUnauthorized(reason: 'User role not found'),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getUserRole(testUser)).called(1);
        },
      );

      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationUnauthorized] when role is inactive',
        build: () {
          when(
            mockAuthorizationService.getUserRole(testUser),
          ).thenAnswer((_) async => inactiveRole);
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(AuthorizationLoadRequested(user: testUser)),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationUnauthorized(reason: 'User role is inactive'),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getUserRole(testUser)).called(1);
        },
      );

      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationFailure] when loading fails',
        build: () {
          when(
            mockAuthorizationService.getUserRole(testUser),
          ).thenThrow(Exception('Database error'));
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(AuthorizationLoadRequested(user: testUser)),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationFailure(
            message: 'Failed to load authorization: Exception: Database error',
          ),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getUserRole(testUser)).called(1);
        },
      );
    });

    group('AuthorizationPermissionCheckRequested', () {
      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationPermissionChecked] when permission check succeeds',
        build: () {
          when(
            mockAuthorizationService.hasPermission(testUser, 'user', 'read'),
          ).thenAnswer((_) async => true);
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(
          AuthorizationPermissionCheckRequested(
            user: testUser,
            resource: 'user',
            action: 'read',
          ),
        ),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationPermissionChecked(
            resource: 'user',
            action: 'read',
            hasPermission: true,
          ),
        ],
        verify: (_) {
          verify(
            mockAuthorizationService.hasPermission(testUser, 'user', 'read'),
          ).called(1);
        },
      );

      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationPermissionChecked] when user does not have permission',
        build: () {
          when(
            mockAuthorizationService.hasPermission(testUser, 'user', 'write'),
          ).thenAnswer((_) async => false);
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(
          AuthorizationPermissionCheckRequested(
            user: testUser,
            resource: 'user',
            action: 'write',
          ),
        ),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationPermissionChecked(
            resource: 'user',
            action: 'write',
            hasPermission: false,
          ),
        ],
        verify: (_) {
          verify(
            mockAuthorizationService.hasPermission(testUser, 'user', 'write'),
          ).called(1);
        },
      );

      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationFailure] when permission check fails',
        build: () {
          when(
            mockAuthorizationService.hasPermission(testUser, 'user', 'read'),
          ).thenThrow(Exception('Permission check error'));
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(
          AuthorizationPermissionCheckRequested(
            user: testUser,
            resource: 'user',
            action: 'read',
          ),
        ),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationFailure(
            message:
                'Failed to check permission: Exception: Permission check error',
          ),
        ],
        verify: (_) {
          verify(
            mockAuthorizationService.hasPermission(testUser, 'user', 'read'),
          ).called(1);
        },
      );
    });

    group('AuthorizationRefreshRequested', () {
      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationLoaded] when refresh is successful',
        build: () {
          when(
            mockAuthorizationService.getUserRole(testUser),
          ).thenAnswer((_) async => testRole);
          when(
            mockAuthorizationService.getUserPermissions(testUser),
          ).thenAnswer((_) async => [testPermission]);
          return authorizationBloc;
        },
        seed: () => AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission],
        ),
        act: (bloc) => bloc.add(AuthorizationRefreshRequested(user: testUser)),
        expect: () => [
          const AuthorizationLoading(),
          AuthorizationLoaded(
            user: testUser,
            role: testRole,
            permissions: [testPermission],
          ),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getUserRole(testUser)).called(1);
          verify(
            mockAuthorizationService.getUserPermissions(testUser),
          ).called(1);
        },
      );
    });

    group('AuthorizationClearRequested', () {
      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationInitial] when clear is requested',
        build: () => authorizationBloc,
        seed: () => AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission],
        ),
        act: (bloc) => bloc.add(const AuthorizationClearRequested()),
        expect: () => [const AuthorizationInitial()],
      );
    });

    group('AuthorizationRolesLoadRequested', () {
      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationRolesLoaded] when roles are loaded successfully',
        build: () {
          when(
            mockAuthorizationService.getAllRoles(),
          ).thenAnswer((_) async => [testRole]);
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(const AuthorizationRolesLoadRequested()),
        expect: () => [
          const AuthorizationLoading(),
          AuthorizationRolesLoaded(roles: [testRole]),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getAllRoles()).called(1);
        },
      );

      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationFailure] when loading roles fails',
        build: () {
          when(
            mockAuthorizationService.getAllRoles(),
          ).thenThrow(Exception('Failed to load roles'));
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(const AuthorizationRolesLoadRequested()),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationFailure(
            message: 'Failed to load roles: Exception: Failed to load roles',
          ),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getAllRoles()).called(1);
        },
      );
    });

    group('AuthorizationPermissionsLoadRequested', () {
      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationPermissionsLoaded] when permissions are loaded successfully',
        build: () {
          when(
            mockAuthorizationService.getAllPermissions(),
          ).thenAnswer((_) async => [testPermission]);
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(const AuthorizationPermissionsLoadRequested()),
        expect: () => [
          const AuthorizationLoading(),
          AuthorizationPermissionsLoaded(permissions: [testPermission]),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getAllPermissions()).called(1);
        },
      );

      blocTest<AuthorizationBloc, AuthorizationState>(
        'emits [AuthorizationLoading, AuthorizationFailure] when loading permissions fails',
        build: () {
          when(
            mockAuthorizationService.getAllPermissions(),
          ).thenThrow(Exception('Failed to load permissions'));
          return authorizationBloc;
        },
        act: (bloc) => bloc.add(const AuthorizationPermissionsLoadRequested()),
        expect: () => [
          const AuthorizationLoading(),
          const AuthorizationFailure(
            message:
                'Failed to load permissions: Exception: Failed to load permissions',
          ),
        ],
        verify: (_) {
          verify(mockAuthorizationService.getAllPermissions()).called(1);
        },
      );
    });
  });
}
