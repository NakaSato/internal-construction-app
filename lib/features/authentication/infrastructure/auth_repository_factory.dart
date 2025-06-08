import 'package:injectable/injectable.dart';

import '../domain/repositories/auth_repository.dart';

/// Factory for creating the appropriate auth repository based on configuration
@lazySingleton
class AuthRepositoryFactory {
  AuthRepositoryFactory(@Named('api') this._apiAuthRepository);

  final AuthRepository _apiAuthRepository;

  /// Get the appropriate auth repository - now only API-based
  AuthRepository getAuthRepository() {
    return _apiAuthRepository;
  }
}
