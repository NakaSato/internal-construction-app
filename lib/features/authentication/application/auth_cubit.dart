import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/storage/preferences_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../infrastructure/auth_repository_factory.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepositoryFactory, this._preferencesService) : super(const AuthInitial());

  final AuthRepositoryFactory _authRepositoryFactory;
  final PreferencesService _preferencesService;

  /// Get the appropriate auth repository based on configuration
  AuthRepository get _authRepository => _authRepositoryFactory.getAuthRepository();

  Future<void> signIn({required String email, required String password, bool rememberMe = false}) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signInWithEmailAndPassword(email: email, password: password);

      // Handle remember me functionality
      if (rememberMe) {
        await _preferencesService.setSavedUsername(email);
        await _preferencesService.setRememberMe(true);
      } else {
        await _preferencesService.clearSavedUsername();
        await _preferencesService.setRememberMe(false);
      }

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
      // Clear remember me data on sign out
      await _preferencesService.clearLoginPreferences();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Load saved login preferences (username and remember me flag)
  Future<Map<String, dynamic>> loadSavedPreferences() async {
    try {
      final savedUsername = _preferencesService.getSavedUsername();
      final rememberMe = _preferencesService.getRememberMe();

      return {'username': savedUsername, 'rememberMe': rememberMe};
    } catch (e) {
      return {'username': null, 'rememberMe': false};
    }
  }

  /// Clear saved login preferences
  Future<void> clearSavedPreferences() async {
    try {
      await _preferencesService.clearLoginPreferences();
    } catch (e) {
      // Handle error silently
      debugPrint('Error clearing preferences: $e');
    }
  }
}
