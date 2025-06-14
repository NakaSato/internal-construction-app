import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_theme.dart';
import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'features/authentication/application/auth_bloc.dart';
import 'features/authentication/application/auth_event.dart';

/// Enhanced login demo showcasing the new modern login screen
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const EnhancedLoginDemoApp());
}

/// Enhanced Login Demo Application
class EnhancedLoginDemoApp extends StatelessWidget {
  const EnhancedLoginDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Enhanced Login Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return Scaffold(
            body: Stack(
              children: [
                child ?? const SizedBox.shrink(),
                // Demo controls overlay
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: _buildDemoControls(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDemoControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Demo Controls',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _buildDemoButton(
            context,
            'Enhanced Login',
            Icons.star,
            () => context.go('/login'),
          ),
          const SizedBox(height: 4),
          _buildDemoButton(
            context,
            'Classic Login',
            Icons.login,
            () => context.go('/classic-login'),
          ),
          const SizedBox(height: 4),
          _buildDemoButton(
            context,
            'Register',
            Icons.person_add,
            () => context.go('/register'),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 120,
      height: 32,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
