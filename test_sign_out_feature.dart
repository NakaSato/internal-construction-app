// Simple test file to verify sign out functionality in enhanced login screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'lib/core/di/injection.dart';
import 'lib/features/authentication/application/auth_bloc.dart';
import 'lib/features/authentication/application/auth_event.dart';
import 'lib/features/authentication/application/auth_state.dart';
import 'lib/features/authentication/presentation/screens/enhanced_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const TestSignOutApp());
}

class TestSignOutApp extends StatelessWidget {
  const TestSignOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Sign Out Feature',
      home: BlocProvider<AuthBloc>(
        create: (context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        child: const EnhancedLoginScreen(),
      ),
    );
  }
}
