import '../entities/user.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({required String email, required String password});

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user
  Future<User?> getCurrentUser();

  /// Get stored authentication token
  Future<String?> getAuthToken();

  /// Store authentication token securely
  Future<void> storeAuthToken(String token);

  /// Remove stored authentication token
  Future<void> removeAuthToken();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Verify email with verification code
  Future<User> verifyEmail(String verificationCode);

  /// Update user profile
  Future<User> updateProfile({String? name, String? phoneNumber, String? profileImageUrl});

  /// Delete user account
  Future<void> deleteAccount();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
