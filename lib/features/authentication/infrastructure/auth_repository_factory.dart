import 'package:injectable/injectable.dart';

import '../../core/config/environment_config.dart';
import '../domain/repositories/auth_repository.dart';

/// Factory for creating the appropriate auth repository based on configuration
@lazySingleton
class AuthRepositoryFactory {
  AuthRepositoryFactory(
    @Named('firebase') this._firebaseAuthRepository,
    @Named('api') this._apiAuthRepository,
  );

  final AuthRepository _firebaseAuthRepository;
  final AuthRepository _apiAuthRepository;

  /// Get the appropriate auth repository based on environment configuration
  AuthRepository getAuthRepository() {
    if (EnvironmentConfig.useFirebaseAuth) {
      return _firebaseAuthRepository;
    } else {
      return _apiAuthRepository;
    }
  }
}
