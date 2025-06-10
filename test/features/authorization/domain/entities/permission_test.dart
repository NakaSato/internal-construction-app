import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_architecture_app/features/authorization/domain/entities/permission.dart';

void main() {
  group('Permission', () {
    const testPermission = Permission(
      id: 'perm_1',
      name: 'User Read',
      resource: 'user',
      action: 'read',
      description: 'Permission to read user data',
    );

    const testPermissionMinimal = Permission(
      id: 'perm_2',
      name: 'User Write',
      resource: 'user',
      action: 'write',
    );

    group('constructor', () {
      test('should create permission with all fields', () {
        expect(testPermission.id, equals('perm_1'));
        expect(testPermission.name, equals('User Read'));
        expect(testPermission.resource, equals('user'));
        expect(testPermission.action, equals('read'));
        expect(
          testPermission.description,
          equals('Permission to read user data'),
        );
      });

      test('should create permission with optional description as null', () {
        expect(testPermissionMinimal.id, equals('perm_2'));
        expect(testPermissionMinimal.name, equals('User Write'));
        expect(testPermissionMinimal.resource, equals('user'));
        expect(testPermissionMinimal.action, equals('write'));
        expect(testPermissionMinimal.description, isNull);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        const permission1 = Permission(
          id: 'perm_1',
          name: 'User Read',
          resource: 'user',
          action: 'read',
          description: 'Permission to read user data',
        );

        const permission2 = Permission(
          id: 'perm_1',
          name: 'User Read',
          resource: 'user',
          action: 'read',
          description: 'Permission to read user data',
        );

        expect(permission1, equals(permission2));
        expect(permission1.hashCode, equals(permission2.hashCode));
      });

      test('should not be equal when properties differ', () {
        const permission1 = Permission(
          id: 'perm_1',
          name: 'User Read',
          resource: 'user',
          action: 'read',
        );

        const permission2 = Permission(
          id: 'perm_2',
          name: 'User Read',
          resource: 'user',
          action: 'read',
        );

        expect(permission1, isNot(equals(permission2)));
      });
    });

    group('JSON serialization', () {
      test('should convert to JSON correctly with all fields', () {
        final json = testPermission.toJson();

        expect(
          json,
          equals({
            'id': 'perm_1',
            'name': 'User Read',
            'resource': 'user',
            'action': 'read',
            'description': 'Permission to read user data',
          }),
        );
      });

      test('should convert to JSON correctly with null description', () {
        final json = testPermissionMinimal.toJson();

        expect(
          json,
          equals({
            'id': 'perm_2',
            'name': 'User Write',
            'resource': 'user',
            'action': 'write',
            'description': null,
          }),
        );
      });

      test('should create from JSON correctly with all fields', () {
        final json = {
          'id': 'perm_1',
          'name': 'User Read',
          'resource': 'user',
          'action': 'read',
          'description': 'Permission to read user data',
        };

        final permission = Permission.fromJson(json);

        expect(permission, equals(testPermission));
      });

      test('should create from JSON correctly with null description', () {
        final json = {
          'id': 'perm_2',
          'name': 'User Write',
          'resource': 'user',
          'action': 'write',
          'description': null,
        };

        final permission = Permission.fromJson(json);

        expect(permission, equals(testPermissionMinimal));
      });

      test('should round-trip JSON conversion', () {
        final json = testPermission.toJson();
        final restored = Permission.fromJson(json);

        expect(restored, equals(testPermission));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final result = testPermission.toString();

        expect(
          result,
          equals('Permission(name: User Read, resource: user, action: read)'),
        );
      });
    });

    group('props', () {
      test('should return all properties for equality comparison', () {
        final props = testPermission.props;

        expect(
          props,
          equals([
            'perm_1',
            'User Read',
            'user',
            'read',
            'Permission to read user data',
          ]),
        );
      });
    });
  });
}
