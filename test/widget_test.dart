// This file contains integration tests for the main app functionality.
//
// Integration tests verify complete user flows and interactions between
// different parts of the application.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_architecture_app/main.dart';
import 'test_helpers/test_helpers.dart';

void main() {
  group('Main App Integration Tests', () {
    setUp(() {
      // Reset GetIt before each test
      GetIt.instance.reset();
      TestUtils.setupMockDependencies();
    });

    tearDown(() {
      // Clean up after each test
      GetIt.instance.reset();
    });

    testWidgets('App launches and shows correct initial state', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify the app launches without errors
      expect(find.byType(MaterialApp), findsOneWidget);

      // Add more specific assertions based on your app's initial state
      // For example, if you have a login screen as initial route:
      // expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Test navigation flows based on your routing setup
      // This will depend on your app's specific navigation structure
    });
  });
}
