import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_architecture_app/features/authorization/application/authorization_bloc.dart';
import 'package:flutter_architecture_app/features/authorization/application/authorization_event.dart';
import 'package:flutter_architecture_app/features/authorization/application/authorization_state.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/permission.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/role.dart';
import 'package:flutter_architecture_app/features/authorization/presentation/widgets/authorization_widgets.dart';
import 'package:flutter_architecture_app/features/authentication/domain/entities/user.dart';

import 'authorization_widgets_test.mocks.dart';

@GenerateMocks([AuthorizationBloc])
void main() {
  group('Authorization Widgets', () {
    late MockAuthorizationBloc mockAuthorizationBloc;
    late User testUser;
    late Role testRole;
    late Permission testPermission;

    setUp(() {
      mockAuthorizationBloc = MockAuthorizationBloc();

      testUser = User(
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

      testPermission = const Permission(
        id: 'perm_1',
        name: 'User Read',
        resource: 'user',
        action: 'read',
      );

      testRole = Role(
        id: 'role_1',
        name: 'manager',
        permissions: [testPermission],
        isActive: true,
      );

      when(
        mockAuthorizationBloc.stream,
      ).thenAnswer((_) => const Stream<AuthorizationState>.empty());
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: BlocProvider<AuthorizationBloc>(
          create: (_) => mockAuthorizationBloc,
          child: Scaffold(body: child),
        ),
      );
    }

    group('PermissionBuilder', () {
      testWidgets('shows loading widget when state is AuthorizationLoading', (
        tester,
      ) async {
        // Arrange
        when(
          mockAuthorizationBloc.state,
        ).thenReturn(const AuthorizationLoading());

        // Act
        await tester.pumpWidget(
          createTestWidget(
            PermissionBuilder(
              user: testUser,
              resource: 'user',
              action: 'read',
              builder: (context, hasPermission) =>
                  Text('Has permission: $hasPermission'),
              loading: const Text('Loading...'),
            ),
          ),
        );

        // Assert
        expect(find.text('Loading...'), findsOneWidget);
        expect(find.textContaining('Has permission:'), findsNothing);
      });

      testWidgets(
        'shows default loading when no custom loading widget provided',
        (tester) async {
          // Arrange
          when(
            mockAuthorizationBloc.state,
          ).thenReturn(const AuthorizationLoading());

          // Act
          await tester.pumpWidget(
            createTestWidget(
              PermissionBuilder(
                user: testUser,
                resource: 'user',
                action: 'read',
                builder: (context, hasPermission) =>
                    Text('Has permission: $hasPermission'),
              ),
            ),
          );

          // Assert
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows builder result when state is AuthorizationLoaded with permission',
        (tester) async {
          // Arrange
          final loadedState = AuthorizationLoaded(
            user: testUser,
            role: testRole,
            permissions: [testPermission],
          );
          when(mockAuthorizationBloc.state).thenReturn(loadedState);

          // Act
          await tester.pumpWidget(
            createTestWidget(
              PermissionBuilder(
                user: testUser,
                resource: 'user',
                action: 'read',
                builder: (context, hasPermission) =>
                    Text('Has permission: $hasPermission'),
              ),
            ),
          );

          // Assert
          expect(find.text('Has permission: true'), findsOneWidget);
        },
      );

      testWidgets(
        'shows builder result when state is AuthorizationLoaded without permission',
        (tester) async {
          // Arrange
          final loadedState = AuthorizationLoaded(
            user: testUser,
            role: testRole,
            permissions: [], // No permissions
          );
          when(mockAuthorizationBloc.state).thenReturn(loadedState);

          // Act
          await tester.pumpWidget(
            createTestWidget(
              PermissionBuilder(
                user: testUser,
                resource: 'user',
                action: 'write', // Different action
                builder: (context, hasPermission) =>
                    Text('Has permission: $hasPermission'),
              ),
            ),
          );

          // Assert
          expect(find.text('Has permission: false'), findsOneWidget);
        },
      );

      testWidgets(
        'shows builder result when state is AuthorizationPermissionChecked with permission',
        (tester) async {
          // Arrange
          when(mockAuthorizationBloc.state).thenReturn(
            const AuthorizationPermissionChecked(
              resource: 'user',
              action: 'read',
              hasPermission: true,
            ),
          );

          // Act
          await tester.pumpWidget(
            createTestWidget(
              PermissionBuilder(
                user: testUser,
                resource: 'user',
                action: 'read',
                builder: (context, hasPermission) =>
                    Text('Has permission: $hasPermission'),
              ),
            ),
          );

          // Assert
          expect(find.text('Has permission: true'), findsOneWidget);
        },
      );

      testWidgets(
        'shows builder result when state is AuthorizationPermissionChecked without permission',
        (tester) async {
          // Arrange
          when(mockAuthorizationBloc.state).thenReturn(
            const AuthorizationPermissionChecked(
              resource: 'user',
              action: 'read',
              hasPermission: false,
            ),
          );

          // Act
          await tester.pumpWidget(
            createTestWidget(
              PermissionBuilder(
                user: testUser,
                resource: 'user',
                action: 'read',
                builder: (context, hasPermission) =>
                    Text('Has permission: $hasPermission'),
              ),
            ),
          );

          // Assert
          expect(find.text('Has permission: false'), findsOneWidget);
        },
      );

      testWidgets(
        'triggers permission check when no authorization data available',
        (tester) async {
          // Arrange
          when(
            mockAuthorizationBloc.state,
          ).thenReturn(const AuthorizationInitial());

          // Act
          await tester.pumpWidget(
            createTestWidget(
              PermissionBuilder(
                user: testUser,
                resource: 'user',
                action: 'read',
                builder: (context, hasPermission) =>
                    Text('Has permission: $hasPermission'),
              ),
            ),
          );

          // Assert
          verify(mockAuthorizationBloc.add(any)).called(1);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'ignores AuthorizationPermissionChecked for different resource/action',
        (tester) async {
          // Arrange
          when(mockAuthorizationBloc.state).thenReturn(
            const AuthorizationPermissionChecked(
              resource: 'post', // Different resource
              action: 'read',
              hasPermission: true,
            ),
          );

          // Act
          await tester.pumpWidget(
            createTestWidget(
              PermissionBuilder(
                user: testUser,
                resource: 'user',
                action: 'read',
                builder: (context, hasPermission) =>
                    Text('Has permission: $hasPermission'),
              ),
            ),
          );

          // Assert
          verify(mockAuthorizationBloc.add(any)).called(1);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );
    });

    group('PermissionGate', () {
      testWidgets('shows child when user has permission', (tester) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            PermissionGate(
              user: testUser,
              resource: 'user',
              action: 'read',
              child: const Text('Protected Content'),
            ),
          ),
        );

        // Assert
        expect(find.text('Protected Content'), findsOneWidget);
      });

      testWidgets('shows fallback when user does not have permission', (
        tester,
      ) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [], // No permissions
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            PermissionGate(
              user: testUser,
              resource: 'user',
              action: 'read',
              child: const Text('Protected Content'),
              fallback: const Text('Access Denied'),
            ),
          ),
        );

        // Assert
        expect(find.text('Protected Content'), findsNothing);
        expect(find.text('Access Denied'), findsOneWidget);
      });

      testWidgets(
        'shows nothing when user does not have permission and no fallback',
        (tester) async {
          // Arrange
          final loadedState = AuthorizationLoaded(
            user: testUser,
            role: testRole,
            permissions: [], // No permissions
          );
          when(mockAuthorizationBloc.state).thenReturn(loadedState);

          // Act
          await tester.pumpWidget(
            createTestWidget(
              PermissionGate(
                user: testUser,
                resource: 'user',
                action: 'read',
                child: const Text('Protected Content'),
              ),
            ),
          );

          // Assert
          expect(find.text('Protected Content'), findsNothing);
          expect(find.byType(SizedBox), findsOneWidget);
        },
      );

      testWidgets('shows loading widget during authorization loading', (
        tester,
      ) async {
        // Arrange
        when(
          mockAuthorizationBloc.state,
        ).thenReturn(const AuthorizationLoading());

        // Act
        await tester.pumpWidget(
          createTestWidget(
            PermissionGate(
              user: testUser,
              resource: 'user',
              action: 'read',
              child: const Text('Protected Content'),
              loading: const Text('Checking permissions...'),
            ),
          ),
        );

        // Assert
        expect(find.text('Checking permissions...'), findsOneWidget);
        expect(find.text('Protected Content'), findsNothing);
      });
    });

    group('RoleBasedWidget', () {
      testWidgets('shows admin widget when user is admin', (tester) async {
        // Arrange
        final adminRole = Role(
          id: 'admin_role',
          name: 'admin',
          permissions: [testPermission],
          isActive: true,
        );
        final loadedState = AuthorizationLoaded(
          user: testUser.copyWith(roleName: 'admin'),
          role: adminRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            RoleBasedWidget(
              user: testUser,
              adminWidget: const Text('Admin Panel'),
              managerWidget: const Text('Manager Panel'),
              userWidget: const Text('User Panel'),
            ),
          ),
        );

        // Assert
        expect(find.text('Admin Panel'), findsOneWidget);
        expect(find.text('Manager Panel'), findsNothing);
        expect(find.text('User Panel'), findsNothing);
      });

      testWidgets('shows manager widget when user is manager', (tester) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            RoleBasedWidget(
              user: testUser,
              adminWidget: const Text('Admin Panel'),
              managerWidget: const Text('Manager Panel'),
              userWidget: const Text('User Panel'),
            ),
          ),
        );

        // Assert
        expect(find.text('Admin Panel'), findsNothing);
        expect(find.text('Manager Panel'), findsOneWidget);
        expect(find.text('User Panel'), findsNothing);
      });

      testWidgets('shows user widget when user is regular user', (
        tester,
      ) async {
        // Arrange
        final userRole = Role(
          id: 'user_role',
          name: 'user',
          permissions: [testPermission],
          isActive: true,
        );
        final loadedState = AuthorizationLoaded(
          user: testUser.copyWith(roleName: 'user'),
          role: userRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            RoleBasedWidget(
              user: testUser,
              adminWidget: const Text('Admin Panel'),
              managerWidget: const Text('Manager Panel'),
              userWidget: const Text('User Panel'),
            ),
          ),
        );

        // Assert
        expect(find.text('Admin Panel'), findsNothing);
        expect(find.text('Manager Panel'), findsNothing);
        expect(find.text('User Panel'), findsOneWidget);
      });

      testWidgets('shows fallback when no matching widget is provided', (
        tester,
      ) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            RoleBasedWidget(
              user: testUser,
              adminWidget: const Text('Admin Panel'),
              fallbackWidget: const Text('Default Content'),
            ),
          ),
        );

        // Assert
        expect(find.text('Admin Panel'), findsNothing);
        expect(find.text('Default Content'), findsOneWidget);
      });

      testWidgets('shows nothing when no matching widget and no fallback', (
        tester,
      ) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            RoleBasedWidget(
              user: testUser,
              adminWidget: const Text('Admin Panel'),
            ),
          ),
        );

        // Assert
        expect(find.text('Admin Panel'), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('triggers authorization load when data not available', (
        tester,
      ) async {
        // Arrange
        when(
          mockAuthorizationBloc.state,
        ).thenReturn(const AuthorizationInitial());

        // Act
        await tester.pumpWidget(
          createTestWidget(
            RoleBasedWidget(
              user: testUser,
              adminWidget: const Text('Admin Panel'),
              loading: const Text('Loading roles...'),
            ),
          ),
        );

        // Assert
        verify(mockAuthorizationBloc.add(any)).called(1);
        expect(find.text('Loading roles...'), findsOneWidget);
      });
    });

    group('AdminOnlyWidget', () {
      testWidgets('shows child when user has admin permission', (tester) async {
        // Arrange
        final adminPermission = Permission(
          id: 'admin_perm',
          name: 'System Admin',
          resource: 'system',
          action: 'admin',
        );
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole.copyWith(permissions: [adminPermission]),
          permissions: [adminPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            AdminOnlyWidget(user: testUser, child: const Text('Admin Content')),
          ),
        );

        // Assert
        expect(find.text('Admin Content'), findsOneWidget);
      });

      testWidgets('shows fallback when user does not have admin permission', (
        tester,
      ) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission], // No admin permission
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            AdminOnlyWidget(
              user: testUser,
              child: const Text('Admin Content'),
              fallback: const Text('Not Admin'),
            ),
          ),
        );

        // Assert
        expect(find.text('Admin Content'), findsNothing);
        expect(find.text('Not Admin'), findsOneWidget);
      });
    });

    group('ManagerOnlyWidget', () {
      testWidgets('shows child when user has manager permission', (
        tester,
      ) async {
        // Arrange
        final managerPermission = Permission(
          id: 'manager_perm',
          name: 'System Manage',
          resource: 'system',
          action: 'manage',
        );
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole.copyWith(permissions: [managerPermission]),
          permissions: [managerPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ManagerOnlyWidget(
              user: testUser,
              child: const Text('Manager Content'),
            ),
          ),
        );

        // Assert
        expect(find.text('Manager Content'), findsOneWidget);
      });

      testWidgets('shows fallback when user does not have manager permission', (
        tester,
      ) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission], // No manager permission
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ManagerOnlyWidget(
              user: testUser,
              child: const Text('Manager Content'),
              fallback: const Text('Not Manager'),
            ),
          ),
        );

        // Assert
        expect(find.text('Manager Content'), findsNothing);
        expect(find.text('Not Manager'), findsOneWidget);
      });
    });

    group('ElevatedAccessWidget', () {
      testWidgets('shows child when user has elevated access', (tester) async {
        // Arrange
        final adminRole = Role(
          id: 'admin_role',
          name: 'admin',
          permissions: [testPermission],
          isActive: true,
        );
        final loadedState = AuthorizationLoaded(
          user: testUser.copyWith(roleName: 'admin'),
          role: adminRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ElevatedAccessWidget(
              user: testUser,
              child: const Text('Elevated Content'),
            ),
          ),
        );

        // Assert
        expect(find.text('Elevated Content'), findsOneWidget);
      });

      testWidgets('shows fallback when user does not have elevated access', (
        tester,
      ) async {
        // Arrange
        final userRole = Role(
          id: 'user_role',
          name: 'user',
          permissions: [testPermission],
          isActive: true,
        );
        final loadedState = AuthorizationLoaded(
          user: testUser.copyWith(roleName: 'user'),
          role: userRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ElevatedAccessWidget(
              user: testUser,
              child: const Text('Elevated Content'),
              fallback: const Text('Access Denied'),
            ),
          ),
        );

        // Assert
        expect(find.text('Elevated Content'), findsNothing);
        expect(find.text('Access Denied'), findsOneWidget);
      });

      testWidgets('triggers authorization load when data not available', (
        tester,
      ) async {
        // Arrange
        when(
          mockAuthorizationBloc.state,
        ).thenReturn(const AuthorizationInitial());

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ElevatedAccessWidget(
              user: testUser,
              child: const Text('Elevated Content'),
              loading: const Text('Checking access...'),
            ),
          ),
        );

        // Assert
        verify(mockAuthorizationBloc.add(any)).called(1);
        expect(find.text('Checking access...'), findsOneWidget);
      });
    });

    group('ConditionalWidget', () {
      testWidgets('shows enabled child when user has permission', (
        tester,
      ) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [testPermission],
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ConditionalWidget(
              user: testUser,
              resource: 'user',
              action: 'read',
              enabledChild: const Text('Enabled Button'),
              disabledChild: const Text('Disabled Button'),
            ),
          ),
        );

        // Assert
        expect(find.text('Enabled Button'), findsOneWidget);
        expect(find.text('Disabled Button'), findsNothing);
      });

      testWidgets('shows disabled child when user does not have permission', (
        tester,
      ) async {
        // Arrange
        final loadedState = AuthorizationLoaded(
          user: testUser,
          role: testRole,
          permissions: [], // No permissions
        );
        when(mockAuthorizationBloc.state).thenReturn(loadedState);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ConditionalWidget(
              user: testUser,
              resource: 'user',
              action: 'read',
              enabledChild: const Text('Enabled Button'),
              disabledChild: const Text('Disabled Button'),
            ),
          ),
        );

        // Assert
        expect(find.text('Enabled Button'), findsNothing);
        expect(find.text('Disabled Button'), findsOneWidget);
      });

      testWidgets('shows loading widget during authorization loading', (
        tester,
      ) async {
        // Arrange
        when(
          mockAuthorizationBloc.state,
        ).thenReturn(const AuthorizationLoading());

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ConditionalWidget(
              user: testUser,
              resource: 'user',
              action: 'read',
              enabledChild: const Text('Enabled Button'),
              disabledChild: const Text('Disabled Button'),
              loading: const Text('Loading state...'),
            ),
          ),
        );

        // Assert
        expect(find.text('Loading state...'), findsOneWidget);
        expect(find.text('Enabled Button'), findsNothing);
        expect(find.text('Disabled Button'), findsNothing);
      });
    });
  });
}
