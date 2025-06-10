import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_architecture_app/features/authorization/infrastructure/repositories/api_authorization_repository.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/permission.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/role.dart';
import 'package:flutter_architecture_app/features/authorization/infrastructure/models/permission_model.dart';
import 'package:flutter_architecture_app/features/authorization/infrastructure/models/role_model.dart';
import 'package:flutter_architecture_app/features/authorization/infrastructure/models/authorization_response_model.dart';

import 'api_authorization_repository_test.mocks.dart';

@GenerateMocks([Dio, FlutterSecureStorage])
void main() {
  group('ApiAuthorizationRepository', () {
    late ApiAuthorizationRepository repository;
    late MockDio mockDio;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockDio = MockDio();
      mockSecureStorage = MockFlutterSecureStorage();
      repository = ApiAuthorizationRepository(
        dio: mockDio,
        secureStorage: mockSecureStorage,
      );
    });

    const testPermission = Permission(
      id: 'perm_1',
      name: 'User Read',
      resource: 'user',
      action: 'read',
      description: 'Permission to read user data',
    );

    final testRole = Role(
      id: 'role_1',
      name: 'manager',
      permissions: [testPermission],
      description: 'Manager role',
      isActive: true,
    );

    final testRoleModel = RoleModel.fromEntity(testRole);
    final testPermissionModel = PermissionModel.fromEntity(testPermission);

    group('getRoleByName', () {
      test('should return role when found in API', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'cached_role_manager'),
        ).thenAnswer((_) async => null);

        final roleResponse = RoleApiResponse(
          success: true,
          message: 'Role found',
          data: testRoleModel,
        );

        when(mockDio.get('/api/roles/manager')).thenAnswer(
          (_) async => Response(
            data: roleResponse.toJson(),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/roles/manager'),
          ),
        );

        when(
          mockSecureStorage.write(key: 'cached_role_manager', value: any),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getRoleByName('manager');

        // Assert
        expect(result, isNotNull);
        expect(result!.name, equals('manager'));
        expect(result.permissions, hasLength(1));
        verify(mockDio.get('/api/roles/manager')).called(1);
        verify(
          mockSecureStorage.write(key: 'cached_role_manager', value: any),
        ).called(1);
      });

      test('should return cached role when available', () async {
        // Arrange
        final cachedRoleJson = testRoleModel.toJson();
        when(
          mockSecureStorage.read(key: 'cached_role_manager'),
        ).thenAnswer((_) async => jsonEncode(cachedRoleJson));

        // Act
        final result = await repository.getRoleByName('manager');

        // Assert
        expect(result, isNotNull);
        expect(result!.name, equals('manager'));
        verifyNever(mockDio.get(any));
      });

      test('should return null when role not found (404)', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'cached_role_notfound'),
        ).thenAnswer((_) async => null);

        when(mockDio.get('/api/roles/notfound')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/roles/notfound'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/api/roles/notfound'),
            ),
          ),
        );

        // Act
        final result = await repository.getRoleByName('notfound');

        // Assert
        expect(result, isNull);
        verify(mockDio.get('/api/roles/notfound')).called(1);
      });

      test(
        'should throw exception when API call fails with non-404 error',
        () async {
          // Arrange
          when(
            mockSecureStorage.read(key: 'cached_role_manager'),
          ).thenAnswer((_) async => null);

          when(mockDio.get('/api/roles/manager')).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/api/roles/manager'),
              response: Response(
                statusCode: 500,
                requestOptions: RequestOptions(path: '/api/roles/manager'),
              ),
            ),
          );

          // Act & Assert
          expect(
            () => repository.getRoleByName('manager'),
            throwsA(isA<Exception>()),
          );
          verify(mockDio.get('/api/roles/manager')).called(1);
        },
      );
    });

    group('getAllRoles', () {
      test('should return all roles from API', () async {
        // Arrange
        final rolesResponse = RolesListApiResponse(
          success: true,
          message: 'Roles retrieved',
          data: [testRoleModel],
        );

        when(mockDio.get('/api/roles')).thenAnswer(
          (_) async => Response(
            data: rolesResponse.toJson(),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/roles'),
          ),
        );

        // Act
        final result = await repository.getAllRoles();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.name, equals('manager'));
        verify(mockDio.get('/api/roles')).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(mockDio.get('/api/roles')).thenThrow(
          DioException(requestOptions: RequestOptions(path: '/api/roles')),
        );

        // Act & Assert
        expect(() => repository.getAllRoles(), throwsA(isA<Exception>()));
        verify(mockDio.get('/api/roles')).called(1);
      });
    });

    group('getAllPermissions', () {
      test('should return all permissions from API', () async {
        // Arrange
        final permissionsResponse = PermissionsListApiResponse(
          success: true,
          message: 'Permissions retrieved',
          data: [testPermissionModel],
        );

        when(mockDio.get('/api/permissions')).thenAnswer(
          (_) async => Response(
            data: permissionsResponse.toJson(),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/permissions'),
          ),
        );

        // Act
        final result = await repository.getAllPermissions();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.name, equals('User Read'));
        verify(mockDio.get('/api/permissions')).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(mockDio.get('/api/permissions')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/permissions'),
          ),
        );

        // Act & Assert
        expect(() => repository.getAllPermissions(), throwsA(isA<Exception>()));
        verify(mockDio.get('/api/permissions')).called(1);
      });
    });

    group('checkPermission', () {
      test('should return true when user has permission', () async {
        // Arrange
        final permissionCheckResponse = PermissionCheckResponse(
          success: true,
          message: 'Permission check completed',
          hasPermission: true,
        );

        when(mockDio.post('/api/permissions/check', data: any)).thenAnswer(
          (_) async => Response(
            data: permissionCheckResponse.toJson(),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/permissions/check'),
          ),
        );

        // Act
        final result = await repository.hasRolePermission(
          'user',
          'user',
          'read',
        );

        // Assert
        expect(result, isTrue);
        verify(mockDio.post('/api/permissions/check', data: any)).called(1);
      });

      test('should return false when user does not have permission', () async {
        // Arrange
        final permissionCheckResponse = PermissionCheckResponse(
          success: true,
          message: 'Permission check completed',
          hasPermission: false,
        );

        when(mockDio.post('/api/permissions/check', data: any)).thenAnswer(
          (_) async => Response(
            data: permissionCheckResponse.toJson(),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/permissions/check'),
          ),
        );

        // Act
        final result = await repository.hasRolePermission(
          'user',
          'admin',
          'delete',
        );

        // Assert
        expect(result, isFalse);
        verify(mockDio.post('/api/permissions/check', data: any)).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(mockDio.post('/api/permissions/check', data: any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/permissions/check'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.hasRolePermission('user', 'user', 'read'),
          throwsA(isA<Exception>()),
        );
        verify(mockDio.post('/api/permissions/check', data: any)).called(1);
      });
    });

    group('caching', () {
      test('should cache role data successfully', () async {
        // Arrange
        when(
          mockSecureStorage.write(key: any, value: any),
        ).thenAnswer((_) async {});

        // Act
        await repository.cacheRoleData(testRole);

        // Assert
        verify(
          mockSecureStorage.write(key: 'cached_role_manager', value: any),
        ).called(1);
      });

      test('should get cached role successfully', () async {
        // Arrange
        final cachedRoleJson = testRoleModel.toJson();
        when(
          mockSecureStorage.read(key: 'cached_role_manager'),
        ).thenAnswer((_) async => jsonEncode(cachedRoleJson));

        // Act
        final result = await repository.getCachedRole('manager');

        // Assert
        expect(result, isNotNull);
        expect(result!.name, equals('manager'));
        verify(mockSecureStorage.read(key: 'cached_role_manager')).called(1);
      });

      test('should return null when no cached role exists', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'cached_role_manager'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCachedRole('manager');

        // Assert
        expect(result, isNull);
        verify(mockSecureStorage.read(key: 'cached_role_manager')).called(1);
      });

      test('should clear cached role successfully', () async {
        // Arrange
        when(mockSecureStorage.delete(key: any)).thenAnswer((_) async {});

        // Act
        await repository.clearRoleCache();

        // Assert
        verify(mockSecureStorage.delete(key: 'cached_role_manager')).called(1);
      });
    });
  });
}
