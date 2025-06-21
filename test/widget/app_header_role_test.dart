import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/widgets/app_header.dart';
import '../../lib/features/authentication/domain/entities/user.dart';

void main() {
  group('AppHeader Role Display Tests', () {
    // Sample users with different roles from API
    final testUsers = [
      User(
        userId: 'user_1',
        username: 'admin',
        email: 'admin@example.com',
        fullName: 'Admin User',
        roleName: 'admin', // API returns lowercase
        isEmailVerified: true,
      ),
      User(
        userId: 'user_2',
        username: 'manager',
        email: 'manager@example.com',
        fullName: 'Manager User',
        roleName: 'Manager', // API returns capitalized
        isEmailVerified: true,
      ),
      User(
        userId: 'user_3',
        username: 'tech',
        email: 'tech@example.com',
        fullName: 'Tech User',
        roleName: 'Technician', // API returns full name
        isEmailVerified: true,
      ),
      User(
        userId: 'user_4',
        username: 'dev',
        email: 'dev@example.com',
        fullName: 'Developer User',
        roleName: 'developer', // API returns lowercase
        isEmailVerified: true,
      ),
      User(
        userId: 'user_5',
        username: 'client',
        email: 'client@example.com',
        fullName: 'Client User',
        roleName: 'client',
        isEmailVerified: true,
      ),
    ];

    Widget createTestWidget(User user) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppHeader(
            user: user,
            showUserRole: true,
            showOnlineStatus: true,
            userStatus: 'online',
          ),
        ),
      );
    }

    testWidgets('AppHeader displays admin role correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(testUsers[0]));
      await tester.pumpAndSettle();

      // Should display ADMIN badge
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('Admin User'), findsOneWidget);
    });

    testWidgets('AppHeader displays manager role correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(testUsers[1]));
      await tester.pumpAndSettle();

      // Should display MANAGER badge
      expect(find.text('MANAGER'), findsOneWidget);
      expect(find.text('Manager User'), findsOneWidget);
    });

    testWidgets('AppHeader displays technician role correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(testUsers[2]));
      await tester.pumpAndSettle();

      // Should display TECH badge
      expect(find.text('TECH'), findsOneWidget);
      expect(find.text('Tech User'), findsOneWidget);
    });

    testWidgets('AppHeader displays developer role correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(testUsers[3]));
      await tester.pumpAndSettle();

      // Should display DEV badge
      expect(find.text('DEV'), findsOneWidget);
      expect(find.text('Developer User'), findsOneWidget);
    });

    testWidgets('AppHeader displays client role correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(testUsers[4]));
      await tester.pumpAndSettle();

      // Should display CLIENT badge
      expect(find.text('CLIENT'), findsOneWidget);
      expect(find.text('Client User'), findsOneWidget);
    });

    testWidgets('AppHeader can hide role badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppHeader(
              user: testUsers[0],
              showUserRole: false, // Hide role badge
              showOnlineStatus: true,
              userStatus: 'online',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should NOT display role badge
      expect(find.text('ADMIN'), findsNothing);
      // But should still display user name
      expect(find.text('Admin User'), findsOneWidget);
      // And should display online status
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('AppHeader shows different status colors', (tester) async {
      const statuses = ['online', 'away', 'busy', 'offline'];

      for (final status in statuses) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppHeader(
                user: testUsers[0],
                showUserRole: true,
                showOnlineStatus: true,
                userStatus: status,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should display the status text
        final expectedText = status[0].toUpperCase() + status.substring(1);
        expect(find.text(expectedText), findsOneWidget);
      }
    });

    testWidgets('AppHeader handles unknown role names', (tester) async {
      final unknownRoleUser = User(
        userId: 'user_unknown',
        username: 'unknown',
        email: 'unknown@example.com',
        fullName: 'Unknown Role User',
        roleName: 'custom_role_123', // Unknown role from API
        isEmailVerified: true,
      );

      await tester.pumpWidget(createTestWidget(unknownRoleUser));
      await tester.pumpAndSettle();

      // Should display formatted unknown role
      expect(find.text('CUSTOM ROLE 123'), findsOneWidget);
      expect(find.text('Unknown Role User'), findsOneWidget);
    });
  });
}
