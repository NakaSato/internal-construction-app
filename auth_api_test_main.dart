import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'lib/core/di/injection.dart';
import 'lib/features/authentication/application/auth_bloc.dart';
import 'lib/features/authentication/application/auth_event.dart';
import 'lib/features/authentication/application/auth_state.dart';
import 'lib/features/authentication/presentation/screens/enhanced_login_screen.dart';

/// Test app to verify authentication API integration
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const AuthApiTestApp());
}

class AuthApiTestApp extends StatelessWidget {
  const AuthApiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth API Test',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        child: const AuthTestScreen(),
      ),
    );
  }
}

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _passwordController = TextEditingController(text: 'SecurePassword123!');
  final _usernameController = TextEditingController(text: 'testvalidation');
  final _registerEmailController = TextEditingController(
    text: 'testvalidation@example.com',
  );
  final _registerPasswordController = TextEditingController(
    text: 'weak', // Intentionally weak password to test validation
  );
  final _fullNameController = TextEditingController(text: 'Test Validation');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication API Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Success: Logged in as ${state.user.email}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(state),
                const SizedBox(height: 24),
                _buildLoginSection(),
                const SizedBox(height: 24),
                _buildRegisterSection(),
                const SizedBox(height: 24),
                _buildActionsSection(state),
                const SizedBox(height: 24),
                _buildEnhancedLoginSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(AuthState state) {
    String status;
    Color color;
    IconData icon;

    if (state is AuthLoading) {
      status = 'Loading...';
      color = Colors.orange;
      icon = Icons.hourglass_empty;
    } else if (state is AuthAuthenticated) {
      status = 'Authenticated as ${state.user.email}';
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (state is AuthUnauthenticated) {
      status = 'Not authenticated';
      color = Colors.grey;
      icon = Icons.person_outline;
    } else if (state is AuthFailure) {
      status = 'Authentication failed: ${state.message}';
      color = Colors.red;
      icon = Icons.error;
    } else {
      status = 'Unknown state';
      color = Colors.grey;
      icon = Icons.help;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                status,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Login API',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email/Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthSignInRequested(
                    username: _emailController.text,
                    password: _passwordController.text,
                  ),
                );
              },
              child: const Text('Test Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Register API',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _registerEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _registerPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthRegisterRequested(
                    username: _usernameController.text,
                    email: _registerEmailController.text,
                    password: _registerPasswordController.text,
                    fullName: _fullNameController.text,
                    roleId: 3, // Default user role
                  ),
                );
              },
              child: const Text('Test Register'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(AuthState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthCheckRequested());
                    },
                    child: const Text('Check Auth'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state is AuthAuthenticated
                        ? () {
                            context.read<AuthBloc>().add(
                              const AuthSignOutRequested(),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedLoginSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enhanced Login Screen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Test the enhanced login screen with sign out functionality',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: const EnhancedLoginScreen(),
                    ),
                  ),
                );
              },
              child: const Text('Open Enhanced Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }
}
