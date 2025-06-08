import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_state.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../navigation/app_router.dart';
import 'main_app_screen.dart';

/// Wrapper widget that handles authentication state and routes accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigate based on authentication state changes
        if (state is AuthAuthenticated) {
          // User logged in, navigate to home
          context.go(AppRoutes.home);
        } else if (state is AuthUnauthenticated) {
          // User logged out, navigate to login
          context.go(AppRoutes.login);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state) {
            case AuthInitial _:
            case AuthLoading _:
              return const _LoadingScreen();
            case AuthAuthenticated _:
              return const MainAppScreen();
            case AuthUnauthenticated _:
            case AuthFailure _:
              return const LoginScreen();
            default:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}

/// Loading screen shown while checking authentication status
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 64, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Flutter Architecture App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Checking authentication...',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}
