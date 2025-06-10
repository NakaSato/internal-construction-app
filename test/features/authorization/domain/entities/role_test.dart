import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/permission.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/role.dart';

void main() {
  group('Role', () {
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

    const adminPermission = Permission(
      id: 'perm_3',
      name: 'System Admin',
      resource: 'system',
      action: 'admin',
    );

    final testRole = Role(
      id: 'role_1',
      name: 'User Manager',
      permissions: [readPermission, writePermission],
      description: 'Role for managing users',
      isActive: true,
    );

    final testRoleMinimal = Role(
      id: 'role_2',
      name: 'Basic Role',
      permissions: [readPermission],
    );

    group('constructor', () {
      test('should create role with all fields', () {
        expect(testRole.id, equals('role_1'));
        expect(testRole.name, equals('User Manager'));
        expect(testRole.permissions, equals([readPermission, writePermission]));
        expect(testRole.description, equals('Role for managing users'));
        expect(testRole.isActive, isTrue);
      });

      test('should create role with defaults for optional fields', () {
        expect(testRoleMinimal.id, equals('role_2'));
        expect(testRoleMinimal.name, equals('Basic Role'));
        expect(testRoleMinimal.permissions, equals([readPermission]));
        expect(testRoleMinimal.description, isNull);
        expect(testRoleMinimal.isActive, isTrue);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final role1 = Role(
          id: 'role_1',
          name: 'User Manager',
          permissions: [readPermission, writePermission],
          description: 'Role for managing users',
          isActive: true,
        );

        final role2 = Role(
          id: 'role_1',
          name: 'User Manager',
          permissions: [readPermission, writePermission],
          description: 'Role for managing users',
          isActive: true,
        );

        expect(role1, equals(role2));
        expect(role1.hashCode, equals(role2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final role1 = Role(
          id: 'role_1',
          name: 'User Manager',
          permissions: [readPermission],
        );

        final role2 = Role(
          id: 'role_2',
          name: 'User Manager',
          permissions: [readPermission],
        );

        expect(role1, isNot(equals(role2)));
      });
    });

    group('hasPermission', () {
      test('should return true when role has specific permission', () {
        final result = testRole.hasPermission('user', 'read');
        expect(result, isTrue);
      });

      test('should return true when role has write permission', () {
        final result = testRole.hasPermission('user', 'write');
        expect(result, isTrue);
      });

      test(
        'should return false when role does not have specific permission',
        () {
          final result = testRole.hasPermission('system', 'admin');
          expect(result, isFalse);
        },
      );

      test('should return false when resource matches but action does not', () {
        final result = testRole.hasPermission('user', 'delete');
        expect(result, isFalse);
      });

      test('should return false when action matches but resource does not', () {
        final result = testRole.hasPermission('calendar', 'read');
        expect(result, isFalse);
      });
    });

    group('hasResourceAccess', () {
      test('should return true when role has any permission for resource', () {
        final result = testRole.hasResourceAccess('user');
        expect(result, isTrue);
      });

      test('should return false when role has no permissions for resource', () {
        final result = testRole.hasResourceAccess('system');
        expect(result, isFalse);
      });
    });

    group('getResourcePermissions', () {
      test('should return all permissions for specific resource', () {
        final result = testRole.getResourcePermissions('user');
        expect(result, equals([readPermission, writePermission]));
      });

      test('should return empty list when no permissions for resource', () {
        final result = testRole.getResourcePermissions('system');
        expect(result, isEmpty);
      });

      test(
        'should return single permission when only one exists for resource',
        () {
          final roleWithAdmin = Role(
            id: 'admin_role',
            name: 'Admin',
            permissions: [readPermission, adminPermission],
          );

          final userPerms = roleWithAdmin.getResourcePermissions('user');
          final systemPerms = roleWithAdmin.getResourcePermissions('system');

          expect(userPerms, equals([readPermission]));
          expect(systemPerms, equals([adminPermission]));
        },
      );
    });

    group('JSON serialization', () {
      test('should convert to JSON correctly with all fields', () {
        final json = testRole.toJson();

        expect(json['id'], equals('role_1'));
        expect(json['name'], equals('User Manager'));
        expect(json['description'], equals('Role for managing users'));
        expect(json['isActive'], isTrue);
        expect(json['permissions'], isA<List>());
        expect(json['permissions'].length, equals(2));
      });

      test('should convert to JSON correctly with minimal fields', () {
        final json = testRoleMinimal.toJson();

        expect(json['id'], equals('role_2'));
        expect(json['name'], equals('Basic Role'));
        expect(json['description'], isNull);
        expect(json['isActive'], isTrue);
        expect(json['permissions'], isA<List>());
        expect(json['permissions'].length, equals(1));
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'role_1',
          'name': 'User Manager',
          'permissions': [readPermission.toJson(), writePermission.toJson()],
          'description': 'Role for managing users',
          'isActive': true,
        };

        final role = Role.fromJson(json);

        expect(role.id, equals('role_1'));
        expect(role.name, equals('User Manager'));
        expect(role.permissions, hasLength(2));
        expect(role.description, equals('Role for managing users'));
        expect(role.isActive, isTrue);
      });

      test('should round-trip JSON conversion', () {
        final json = testRole.toJson();
        final restored = Role.fromJson(json);

        expect(restored, equals(testRole));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final result = testRole.toString();

        expect(
          result,
          equals('Role(name: User Manager, permissions: 2, isActive: true)'),
        );
      });
    });

    group('props', () {
      test('should return all properties for equality comparison', () {
        final props = testRole.props;

        expect(
          props,
          equals([
            'role_1',
            'User Manager',
            [readPermission, writePermission],
            'Role for managing users',
            true,
          ]),
        );
      });
    });
  });
}
