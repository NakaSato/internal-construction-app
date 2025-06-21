import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/core/widgets/dashboard/project_statistics_section.dart';
import '../../lib/features/project_management/application/project_bloc.dart';
import '../../lib/features/project_management/application/project_state.dart';
import '../../lib/features/project_management/domain/entities/project.dart';

class MockProjectBloc extends Mock implements ProjectBloc {}

void main() {
  group('ProjectStatisticsSection', () {
    late MockProjectBloc mockProjectBloc;

    setUp(() {
      mockProjectBloc = MockProjectBloc();
    });

    Widget createTestWidget({
      ProjectStatus? selectedStatus,
      ValueChanged<ProjectStatus?>? onStatusSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<ProjectBloc>(
            create: (_) => mockProjectBloc,
            child: ProjectStatisticsSection(
              selectedStatus: selectedStatus,
              onStatusSelected: onStatusSelected,
            ),
          ),
        ),
      );
    }

    List<Project> createTestProjects() {
      return [
        Project(
          projectId: '1',
          projectName: 'Project 1',
          address: 'Address 1',
          clientInfo: 'Client 1',
          status: 'In Progress',
          startDate: DateTime.now(),
          estimatedEndDate: DateTime.now().add(const Duration(days: 30)),
        ),
        Project(
          projectId: '2',
          projectName: 'Project 2',
          address: 'Address 2',
          clientInfo: 'Client 2',
          status: 'Completed',
          startDate: DateTime.now().subtract(const Duration(days: 60)),
          estimatedEndDate: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Project(
          projectId: '3',
          projectName: 'Project 3',
          address: 'Address 3',
          clientInfo: 'Client 3',
          status: 'Planning',
          startDate: DateTime.now().add(const Duration(days: 10)),
          estimatedEndDate: DateTime.now().add(const Duration(days: 40)),
        ),
        Project(
          projectId: '4',
          projectName: 'Project 4',
          address: 'Address 4',
          clientInfo: 'Client 4',
          status: 'On Hold',
          startDate: DateTime.now().subtract(const Duration(days: 20)),
          estimatedEndDate: DateTime.now().add(const Duration(days: 10)),
        ),
      ];
    }

    testWidgets('displays loading state when ProjectLoading', (tester) async {
      when(() => mockProjectBloc.state).thenReturn(const ProjectLoading());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state when ProjectError', (tester) async {
      const errorMessage = 'Failed to load projects';
      when(
        () => mockProjectBloc.state,
      ).thenReturn(const ProjectError(message: errorMessage));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Failed to load statistics'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays correct statistics when ProjectLoaded', (
      tester,
    ) async {
      final projects = createTestProjects();
      when(
        () => mockProjectBloc.state,
      ).thenReturn(ProjectLoaded(projects: projects));

      await tester.pumpWidget(createTestWidget());

      // Check that all statistic cards are displayed
      expect(find.text('All Projects'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('On Hold'), findsOneWidget);

      // Check that counts are correct
      expect(find.text('4'), findsOneWidget); // All projects
      expect(
        find.text('1'),
        findsNWidgets(4),
      ); // 1 project each for other statuses
    });

    testWidgets('does not display cancelled status when no cancelled projects', (
      tester,
    ) async {
      final projects = createTestProjects();
      when(
        () => mockProjectBloc.state,
      ).thenReturn(ProjectLoaded(projects: projects));

      await tester.pumpWidget(createTestWidget());

      // Cancelled should not be displayed since there are no cancelled projects
      expect(find.text('Cancelled'), findsNothing);
    });

    testWidgets('calls onStatusSelected when status card is tapped', (
      tester,
    ) async {
      final projects = createTestProjects();
      when(
        () => mockProjectBloc.state,
      ).thenReturn(ProjectLoaded(projects: projects));

      ProjectStatus? selectedStatus;
      await tester.pumpWidget(
        createTestWidget(onStatusSelected: (status) => selectedStatus = status),
      );

      // Tap on the "In Progress" card
      await tester.tap(find.text('In Progress'));
      await tester.pump();

      expect(selectedStatus, equals(ProjectStatus.inProgress));
    });

    testWidgets('displays empty state when no projects', (tester) async {
      when(
        () => mockProjectBloc.state,
      ).thenReturn(const ProjectLoaded(projects: []));

      await tester.pumpWidget(createTestWidget());

      // Should show all status cards with 0 counts
      expect(find.text('All Projects'), findsOneWidget);
      expect(find.text('0'), findsAtLeastNWidgets(1));
    });

    testWidgets('is horizontally scrollable', (tester) async {
      final projects = createTestProjects();
      when(
        () => mockProjectBloc.state,
      ).thenReturn(ProjectLoaded(projects: projects));

      await tester.pumpWidget(createTestWidget());

      // Find the SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify it's configured for horizontal scrolling
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, equals(Axis.horizontal));
    });
  });
}
