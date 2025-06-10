import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_theme.dart';
import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'features/authentication/application/auth_bloc.dart';
import 'features/authentication/application/auth_event.dart';
import 'features/authorization/application/authorization_bloc.dart';
import 'features/image_upload/application/image_upload_bloc.dart';
import 'features/location_tracking/application/location_tracking_bloc.dart';
import 'features/work_calendar/application/work_calendar_bloc.dart';
import 'utils/api_config_verifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  // Verify API configuration
  ApiConfigVerifier.verifyConfiguration();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<AuthorizationBloc>(
          create: (context) => getIt<AuthorizationBloc>(),
        ),
        BlocProvider<ImageUploadBloc>(
          create: (context) => getIt<ImageUploadBloc>(),
        ),
        BlocProvider<LocationTrackingBloc>(
          create: (context) => getIt<LocationTrackingBloc>(),
        ),
        BlocProvider<WorkCalendarBloc>(
          create: (context) => getIt<WorkCalendarBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: '',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
