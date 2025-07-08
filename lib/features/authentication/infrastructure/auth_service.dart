class AuthService {
  AuthService();
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthResult {
  final bool isSuccess;
  final dynamic data;
  final String? error;

  AuthResult.success(this.data) : isSuccess = true, error = null;
  AuthResult.failure(this.error) : isSuccess = false, data = null;
}
