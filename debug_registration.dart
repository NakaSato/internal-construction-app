import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'lib/core/di/injection.dart';
import 'lib/features/authentication/application/auth_bloc.dart';
import 'lib/features/authentication/application/auth_event.dart';
import 'lib/features/authentication/application/auth_state.dart';

/// Debug specific registration issue
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const DebugRegistrationApp());
}

class DebugRegistrationApp extends StatelessWidget {
  const DebugRegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Registration',
      home: BlocProvider<AuthBloc>(
        create: (context) => getIt<AuthBloc>(),
        child: const DebugRegistrationScreen(),
      ),
    );
  }
}

class DebugRegistrationScreen extends StatefulWidget {
  const DebugRegistrationScreen({super.key});

  @override
  State<DebugRegistrationScreen> createState() =>
      _DebugRegistrationScreenState();
}

class _DebugRegistrationScreenState extends State<DebugRegistrationScreen> {
  final _emailController = TextEditingController(text: 'test@gmail.com');
  final _passwordController = TextEditingController(text: 'Test@pass');
  final _nameController = TextEditingController(text: 'TEST');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Registration Issue')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Registration Error'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Error Message:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          state.message,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Check the console logs for detailed API response information.',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is AuthAuthenticated) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Success!'),
                content: Text(
                  'Registration successful for: ${state.user.email}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Debug Registration',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Testing the exact values that caused the error:',
                style: TextStyle(fontSize: 16),
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
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  helperText: 'Current: Test@pass (missing digit)',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return ElevatedButton(
                    onPressed: isLoading ? null : _debugRegister,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Debug Register'),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Password Analysis:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildPasswordAnalysis(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _passwordController.text = 'Test@pass123'; // Add digits
                  });
                },
                child: const Text('Fix Password (Add Digits)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordAnalysis() {
    final password = _passwordController.text;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final isLongEnough = password.length >= 8;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequirement('Length >= 8 characters', isLongEnough),
          _buildRequirement('Has uppercase letter', hasUpper),
          _buildRequirement('Has lowercase letter', hasLower),
          _buildRequirement('Has digit', hasDigit),
          _buildRequirement('Has special character', hasSpecial),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.cancel,
          color: met ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  void _debugRegister() {
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
