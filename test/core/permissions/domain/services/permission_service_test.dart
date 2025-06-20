import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import '../../../../../lib/core/permissions/domain/services/permission_service.dart';
import '../../../../../lib/core/permissions/domain/entities/permission.dart';
import '../../../../../lib/core/permissions/domain/usecases/check_user_permission.dart';
import '../../../../../lib/core/permissions/domain/usecases/get_user_permissions.dart';
import '../../../../../lib/core/permissions/domain/usecases/check_multiple_permissions.dart';
import '../../../../../lib/core/errors/failures.dart';

// Generate mocks
@GenerateMocks([
  CheckUserPermissionUseCase,
  GetUserPermissionsUseCase,
  CheckMultiplePermissionsUseCase,
])
import 'permission_service_test.mocks.dart';

void main() {
  late PermissionService permissionService;
  late MockCheckUserPermissionUseCase mockCheckUserPermissionUseCase;
  late MockGetUserPermissionsUseCase mockGetUserPermissionsUseCase;
  late MockCheckMultiplePermissionsUseCase mockCheckMultiplePermissionsUseCase;

  setUp(() {
    mockCheckUserPermissionUseCase = MockCheckUserPermissionUseCase();
    mockGetUserPermissionsUseCase = MockGetUserPermissionsUseCase();
    mockCheckMultiplePermissionsUseCase = MockCheckMultiplePermissionsUseCase();

    permissionService = PermissionService(
      checkUserPermissionUseCase: mockCheckUserPermissionUseCase,
      getUserPermissionsUseCase: mockGetUserPermissionsUseCase,
      checkMultiplePermissionsUseCase: mockCheckMultiplePermissionsUseCase,
    );
  });

  group('PermissionService', () {
    const testUserId = 'test-user-id';
    const testResource = 'projects';
    const testAction = 'view';

    group('hasPermission', () {
      test('should return true when user has permission', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await permissionService.hasPermission(
          testUserId,
          testResource,
          testAction,
        );

        // Assert
        expect(result, isTrue);
        verify(
          mockCheckUserPermissionUseCase(
            CheckUserPermissionParams(
              userId: testUserId,
              resource: testResource,
              action: testAction,
            ),
          ),
        ).called(1);
      });

      test('should return false when user does not have permission', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Right(false));

        // Act
        final result = await permissionService.hasPermission(
          testUserId,
          testResource,
          testAction,
        );

        // Assert
        expect(result, isFalse);
      });

      test('should return false when use case fails', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

        // Act
        final result = await permissionService.hasPermission(
          testUserId,
          testResource,
          testAction,
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('convenience methods', () {
      test('canView should check view permission', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await permissionService.canView(
          testUserId,
          testResource,
        );

        // Assert
        expect(result, isTrue);
        verify(
          mockCheckUserPermissionUseCase(
            CheckUserPermissionParams(
              userId: testUserId,
              resource: testResource,
              action: 'view',
            ),
          ),
        ).called(1);
      });

      test('canCreate should check create permission', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await permissionService.canCreate(
          testUserId,
          testResource,
        );

        // Assert
        expect(result, isTrue);
        verify(
          mockCheckUserPermissionUseCase(
            CheckUserPermissionParams(
              userId: testUserId,
              resource: testResource,
              action: 'create',
            ),
          ),
        ).called(1);
      });

      test('canUpdate should check update permission', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await permissionService.canUpdate(
          testUserId,
          testResource,
        );

        // Assert
        expect(result, isTrue);
        verify(
          mockCheckUserPermissionUseCase(
            CheckUserPermissionParams(
              userId: testUserId,
              resource: testResource,
              action: 'update',
            ),
          ),
        ).called(1);
      });

      test('canDelete should check delete permission', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await permissionService.canDelete(
          testUserId,
          testResource,
        );

        // Assert
        expect(result, isTrue);
        verify(
          mockCheckUserPermissionUseCase(
            CheckUserPermissionParams(
              userId: testUserId,
              resource: testResource,
              action: 'delete',
            ),
          ),
        ).called(1);
      });

      test('canManage should check manage permission', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await permissionService.canManage(
          testUserId,
          testResource,
        );

        // Assert
        expect(result, isTrue);
        verify(
          mockCheckUserPermissionUseCase(
            CheckUserPermissionParams(
              userId: testUserId,
              resource: testResource,
              action: 'manage',
            ),
          ),
        ).called(1);
      });
    });

    group('project-specific permissions', () {
      test('canViewProjects should check projects view permission', () async {
        // Arrange
        when(
          mockCheckUserPermissionUseCase(any),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await permissionService.canViewProjects(testUserId);

        // Assert
        expect(result, isTrue);
        verify(
          mockCheckUserPermissionUseCase(
            CheckUserPermissionParams(
              userId: testUserId,
              resource: 'projects',
              action: 'view',
            ),
          ),
        ).called(1);
      });

      test(
        'canManageProjects should check projects manage permission',
        () async {
          // Arrange
          when(
            mockCheckUserPermissionUseCase(any),
          ).thenAnswer((_) async => const Right(true));

          // Act
          final result = await permissionService.canManageProjects(testUserId);

          // Assert
          expect(result, isTrue);
          verify(
            mockCheckUserPermissionUseCase(
              CheckUserPermissionParams(
                userId: testUserId,
                resource: 'projects',
                action: 'manage',
              ),
            ),
          ).called(1);
        },
      );
    });

    group('checkMultiplePermissions', () {
      test('should return permission results for multiple checks', () async {
        // Arrange
        final permissionChecks = [
          const PermissionCheck(resource: 'projects', action: 'view'),
          const PermissionCheck(resource: 'projects', action: 'create'),
        ];
        final expectedResults = {
          'projects:view': true,
          'projects:create': false,
        };

        when(
          mockCheckMultiplePermissionsUseCase(any),
        ).thenAnswer((_) async => Right(expectedResults));

        // Act
        final result = await permissionService.checkMultiplePermissions(
          testUserId,
          permissionChecks,
        );

        // Assert
        expect(result, equals(expectedResults));
        verify(
          mockCheckMultiplePermissionsUseCase(
            CheckMultiplePermissionsParams(
              userId: testUserId,
              permissionChecks: permissionChecks,
            ),
          ),
        ).called(1);
      });

      test('should return empty map when use case fails', () async {
        // Arrange
        final permissionChecks = [
          const PermissionCheck(resource: 'projects', action: 'view'),
        ];

        when(
          mockCheckMultiplePermissionsUseCase(any),
        ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

        // Act
        final result = await permissionService.checkMultiplePermissions(
          testUserId,
          permissionChecks,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('hasAnyPermission', () {
      test(
        'should return true when user has at least one permission',
        () async {
          // Arrange
          final permissionChecks = [
            const PermissionCheck(resource: 'projects', action: 'view'),
            const PermissionCheck(resource: 'projects', action: 'create'),
          ];
          final results = {'projects:view': true, 'projects:create': false};

          when(
            mockCheckMultiplePermissionsUseCase(any),
          ).thenAnswer((_) async => Right(results));

          // Act
          final result = await permissionService.hasAnyPermission(
            testUserId,
            permissionChecks,
          );

          // Assert
          expect(result, isTrue);
        },
      );

      test('should return false when user has no permissions', () async {
        // Arrange
        final permissionChecks = [
          const PermissionCheck(resource: 'projects', action: 'view'),
          const PermissionCheck(resource: 'projects', action: 'create'),
        ];
        final results = {'projects:view': false, 'projects:create': false};

        when(
          mockCheckMultiplePermissionsUseCase(any),
        ).thenAnswer((_) async => Right(results));

        // Act
        final result = await permissionService.hasAnyPermission(
          testUserId,
          permissionChecks,
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('hasAllPermissions', () {
      test('should return true when user has all permissions', () async {
        // Arrange
        final permissionChecks = [
          const PermissionCheck(resource: 'projects', action: 'view'),
          const PermissionCheck(resource: 'projects', action: 'create'),
        ];
        final results = {'projects:view': true, 'projects:create': true};

        when(
          mockCheckMultiplePermissionsUseCase(any),
        ).thenAnswer((_) async => Right(results));

        // Act
        final result = await permissionService.hasAllPermissions(
          testUserId,
          permissionChecks,
        );

        // Assert
        expect(result, isTrue);
      });

      test(
        'should return false when user is missing some permissions',
        () async {
          // Arrange
          final permissionChecks = [
            const PermissionCheck(resource: 'projects', action: 'view'),
            const PermissionCheck(resource: 'projects', action: 'create'),
          ];
          final results = {'projects:view': true, 'projects:create': false};

          when(
            mockCheckMultiplePermissionsUseCase(any),
          ).thenAnswer((_) async => Right(results));

          // Act
          final result = await permissionService.hasAllPermissions(
            testUserId,
            permissionChecks,
          );

          // Assert
          expect(result, isFalse);
        },
      );
    });
  });
}
