import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/solar_app_theme.dart';
import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'features/authentication/application/auth_bloc.dart';
import 'features/authentication/application/auth_event.dart';
import 'features/authorization/application/authorization_bloc.dart';
import 'features/daily_reports/application/cubits/daily_reports_cubit.dart';
import 'features/project_management/application/project_bloc.dart';
import 'features/work_calendar/application/work_calendar_bloc.dart';

/// The main application widget that configures the Flutter app.
///
/// This widget is responsible for:
/// - Setting up global state providers (BLoCs/Cubits)
/// - Configuring the Material app with theme and routing
/// - Providing dependency injection context to the widget tree
class ConstructionApp extends StatelessWidget {
  const ConstructionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Authentication state management
        BlocProvider<AuthBloc>(create: (context) => getIt<AuthBloc>()..add(const AuthCheckRequested())),

        // Authorization state management
        BlocProvider<AuthorizationBloc>(create: (context) => getIt<AuthorizationBloc>()),

        // Work calendar state management
        BlocProvider<WorkCalendarBloc>(create: (context) => getIt<WorkCalendarBloc>()),

        // Project management state management
        BlocProvider<EnhancedProjectBloc>(create: (context) => getIt<EnhancedProjectBloc>()),

        // Daily reports state management
        BlocProvider<DailyReportsCubit>(create: (context) => getIt<DailyReportsCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Solar Manager',

        // Theme configuration - Using new solar-themed design
        theme: SolarAppTheme.themeData,
        themeMode: ThemeMode.light, // Using light theme with solar colors
        // Routing configuration
        routerConfig: AppRouter.router,

        // Development settings
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
