import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'lib/core/di/injection.dart';
import 'lib/features/authentication/application/auth_bloc.dart';
import 'lib/features/authentication/application/auth_event.dart';
import 'lib/features/authentication/application/auth_state.dart';
import 'lib/features/authentication/presentation/screens/register_screen.dart';

/// Test app to verify password validation error handling
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const PasswordValidationTestApp());
}

class PasswordValidationTestApp extends StatelessWidget {
  const PasswordValidationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Validation Test',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        child: const PasswordValidationTestScreen(),
      ),
    );
  }
}

class PasswordValidationTestScreen extends StatefulWidget {
  const PasswordValidationTestScreen({super.key});

  @override
  State<PasswordValidationTestScreen> createState() =>
      _PasswordValidationTestScreenState();
}

class _PasswordValidationTestScreenState
    extends State<PasswordValidationTestScreen> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(
    text: 'weak',
  ); // Intentionally weak password
  final _nameController = TextEditingController(text: 'Test User');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Validation Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Registration Failed: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 8),
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Registration Success: ${state.user.email}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Test Password Validation',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will test the API password validation error handling. The weak password should trigger a detailed validation error from the API.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password (intentionally weak)',
                          border: OutlineInputBorder(),
                          helperText: 'Try: "weak", "password", "123456"',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return ElevatedButton(
                            onPressed: isLoading ? null : _testRegistration,
                            child: isLoading
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Testing Registration...'),
                                    ],
                                  )
                                : const Text(
                                    'Test Registration (Expect Error)',
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<AuthBloc>(),
                                child: const RegisterScreen(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Open Full Register Screen'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expected API Response',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '{\n'
                          '  "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",\n'
                          '  "title": "One or more validation errors occurred.",\n'
                          '  "status": 400,\n'
                          '  "errors": {\n'
                          '    "Password": ["Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character"]\n'
                          '  }\n'
                          '}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _testRegistration() {
    final email = _emailController.text.trim();
    final username = email.split('@').first;

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        username: username,
        email: email,
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        roleId: 3, // Default role ID for user
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
