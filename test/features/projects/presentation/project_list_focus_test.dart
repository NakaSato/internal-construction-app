import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:solar_mana/core/di/injection.dart';
import 'package:solar_mana/core/services/realtime_api_streams.dart';
import 'package:solar_mana/features/authentication/application/auth_bloc.dart';
import 'package:solar_mana/features/authentication/application/auth_state.dart';
import 'package:solar_mana/features/projects/application/project_bloc.dart';
import 'package:solar_mana/features/projects/domain/entities/project_api_models.dart';
import 'package:solar_mana/features/projects/presentation/screens/project_list_screen.dart';

@GenerateMocks([AuthBloc, ProjectBloc, RealtimeApiStreams])
void main() {
  late MockAuthBloc mockAuthBloc;
  late MockProjectBloc mockProjectBloc;
  late MockRealtimeApiStreams mockRealtimeApiStreams;
  late StreamController<bool> appFocusController;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockProjectBloc = MockProjectBloc();
    mockRealtimeApiStreams = MockRealtimeApiStreams();
    appFocusController = StreamController<bool>.broadcast();
    
    // Setup the GetIt instance for testing
    GetIt.I.registerSingleton<RealtimeApiStreams>(mockRealtimeApiStreams);
    
    // Mock the auth state to return authenticated
    when(mockAuthBloc.state).thenReturn(AuthAuthenticated(
      user: const User(id: '1', email: 'test@example.com'),
    ));
    
    // Mock the project state to return loading initially
    when(mockProjectBloc.state).thenReturn(const ProjectLoading());
    
    // Mock the realtime API streams
    when(mockRealtimeApiStreams.appFocusStream).thenAnswer((_) => appFocusController.stream);
    when(mockRealtimeApiStreams.isConnected).thenReturn(true);
    when(mockRealtimeApiStreams.initialize()).thenAnswer((_) async {});
  });

  tearDown(() {
    appFocusController.close();
    GetIt.I.reset();
  });

  testWidgets('Project list should refresh when app focus returns', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            BlocProvider<ProjectBloc>.value(value: mockProjectBloc),
          ],
          child: const ProjectListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state
    verify(mockProjectBloc.add(any)).called(greaterThan(0));
    
    // Reset the call count for clean verification
    clearInteractions(mockProjectBloc);
    
    // Act - simulate app focus returning
    appFocusController.add(true);
    await tester.pumpAndSettle();
    
    // Assert - verify the refresh was triggered
    verify(mockProjectBloc.add(any)).called(greaterThan(0));
  });

  testWidgets('Project list should handle account switch correctly', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            BlocProvider<ProjectBloc>.value(value: mockProjectBloc),
          ],
          child: const ProjectListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    // Reset the call count for clean verification
    clearInteractions(mockProjectBloc);
    
    // Act - simulate account switch by changing auth state and returning focus
    when(mockAuthBloc.state).thenReturn(AuthAuthenticated(
      user: const User(id: '2', email: 'another@example.com'),
    ));
    appFocusController.add(true);
    await tester.pumpAndSettle();
    
    // Assert - verify the refresh was triggered with cache clear
    verify(mockProjectBloc.add(any)).called(greaterThan(0));
  });
}
