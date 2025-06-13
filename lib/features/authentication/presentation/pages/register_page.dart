import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/auth_cubit.dart';
import '../../application/auth_state.dart';
import '../widgets/alert_dialog_widget.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            _showErrorDialog(context, state.message);
          } else if (state is AuthAuthenticated) {
            _showSuccessDialog(context, 'Registration successful!');
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Trigger registration
                      },
                      child: Text('Register'),
                    ),
                    if (state is AuthLoading) ...[
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialogWidget(
        title: 'Registration Failed',
        message: message,
        type: AlertType.error,
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialogWidget(
        title: 'Success',
        message: message,
        type: AlertType.success,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
