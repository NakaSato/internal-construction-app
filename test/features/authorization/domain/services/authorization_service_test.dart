import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/permission.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/role.dart';
import 'package:flutter_architecture_app/features/authorization/domain/repositories/authorization_repository.dart';
import 'package:flutter_architecture_app/features/authorization/domain/services/authorization_service.dart';
import 'package:flutter_architecture_app/features/authentication/domain/entities/user.dart';

import 'authorization_service_test.mocks.dart';

@GenerateMocks([AuthorizationRepository])
void main() {
  group('AuthorizationService', () {
    late AuthorizationService authorizationService;
    late MockAuthorizationRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthorizationRepository();
      authorizationService = AuthorizationService(mockRepository);
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

    const readPermission = Permission(
      id: 'perm_1',
      name: 'User Read',
      resource: 'user',
      action: 'read',
    );

    const writePermission = Permission(
      id: 'perm_2',
      name: 'User Write',
      resource: 'user',
      action: 'write',
    );

    final testRole = Role(
      id: 'role_1',
      name: 'manager',
      permissions: [readPermission, writePermission],
      isActive: true,
    );

    final inactiveRole = Role(
      id: 'role_2',
      name: 'manager',
      permissions: [readPermission, writePermission],
      isActive: false,
    );

    group('hasPermission', () {
      test('should return true when user has specific permission', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => testRole);

        // Act
        final result = await authorizationService.hasPermission(
          testUser,
          'user',
          'read',
        );

        // Assert
        expect(result, isTrue);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test(
        'should return false when user does not have specific permission',
        () async {
          // Arrange
          when(
            mockRepository.getRoleByName('manager'),
          ).thenAnswer((_) async => testRole);

          // Act
          final result = await authorizationService.hasPermission(
            testUser,
            'system',
            'admin',
          );

          // Assert
          expect(result, isFalse);
          verify(mockRepository.getRoleByName('manager')).called(1);
        },
      );

      test('should return false when role is null', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await authorizationService.hasPermission(
          testUser,
          'user',
          'read',
        );

        // Assert
        expect(result, isFalse);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test('should return false when role is inactive', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => inactiveRole);

        // Act
        final result = await authorizationService.hasPermission(
          testUser,
          'user',
          'read',
        );

        // Assert
        expect(result, isFalse);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test('should return false when repository throws exception', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await authorizationService.hasPermission(
          testUser,
          'user',
          'read',
        );

        // Assert
        expect(result, isFalse);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });
    });

    group('hasResourceAccess', () {
      test(
        'should return true when user has any permission for resource',
        () async {
          // Arrange
          when(
            mockRepository.getRoleByName('manager'),
          ).thenAnswer((_) async => testRole);

          // Act
          final result = await authorizationService.hasResourceAccess(
            testUser,
            'user',
          );

          // Assert
          expect(result, isTrue);
          verify(mockRepository.getRoleByName('manager')).called(1);
        },
      );

      test(
        'should return false when user has no permissions for resource',
        () async {
          // Arrange
          when(
            mockRepository.getRoleByName('manager'),
          ).thenAnswer((_) async => testRole);

          // Act
          final result = await authorizationService.hasResourceAccess(
            testUser,
            'system',
          );

          // Assert
          expect(result, isFalse);
          verify(mockRepository.getRoleByName('manager')).called(1);
        },
      );

      test('should return false when role is null', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await authorizationService.hasResourceAccess(
          testUser,
          'user',
        );

        // Assert
        expect(result, isFalse);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test('should return false when role is inactive', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => inactiveRole);

        // Act
        final result = await authorizationService.hasResourceAccess(
          testUser,
          'user',
        );

        // Assert
        expect(result, isFalse);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test('should return false when repository throws exception', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await authorizationService.hasResourceAccess(
          testUser,
          'user',
        );

        // Assert
        expect(result, isFalse);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });
    });

    group('getUserRole', () {
      test('should return role when user role exists', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => testRole);

        // Act
        final result = await authorizationService.getUserRole(testUser);

        // Assert
        expect(result, equals(testRole));
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test('should return null when role does not exist', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await authorizationService.getUserRole(testUser);

        // Assert
        expect(result, isNull);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test('should return null when repository throws exception', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await authorizationService.getUserRole(testUser);

        // Assert
        expect(result, isNull);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });
    });

    group('getUserPermissions', () {
      test('should return user permissions when role exists', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => testRole);

        // Act
        final result = await authorizationService.getUserPermissions(testUser);

        // Assert
        expect(result, equals([readPermission, writePermission]));
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test('should return empty list when role does not exist', () async {
        // Arrange
        when(
          mockRepository.getRoleByName('manager'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await authorizationService.getUserPermissions(testUser);

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getRoleByName('manager')).called(1);
      });

      test(
        'should return empty list when repository throws exception',
        () async {
          // Arrange
          when(
            mockRepository.getRoleByName('manager'),
          ).thenThrow(Exception('Database error'));

          // Act
          final result = await authorizationService.getUserPermissions(
            testUser,
          );

          // Assert
          expect(result, isEmpty);
          verify(mockRepository.getRoleByName('manager')).called(1);
        },
      );
    });
  });
}
