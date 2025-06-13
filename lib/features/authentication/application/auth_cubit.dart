import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/repositories/auth_repository.dart';
import '../infrastructure/auth_repository_factory.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepositoryFactory) : super(const AuthInitial());

  final AuthRepositoryFactory _authRepositoryFactory;

  /// Get the appropriate auth repository based on configuration
  AuthRepository get _authRepository =>
      _authRepositoryFactory.getAuthRepository();

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
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
}
