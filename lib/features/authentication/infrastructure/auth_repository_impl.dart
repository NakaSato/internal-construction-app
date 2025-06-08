import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../core/config/app_constants.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth, this._secureStorage);

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      final user = _mapFirebaseUserToUser(credential.user!);

      // Store auth token
      final token = await credential.user!.getIdToken();
      if (token != null) {
        await storeAuthToken(token);
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  @override
  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Registration failed');
      }

      // Update display name
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();

      final user = _mapFirebaseUserToUser(credential.user!);

      // Store auth token
      final token = await credential.user!.getIdToken();
      if (token != null) {
        await storeAuthToken(token);
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during registration');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    // TODO: Implement Google Sign In
    // This requires additional setup with google_sign_in package
    throw UnimplementedError('Google Sign In not implemented yet');
  }

  @override
  Future<User> signInWithApple() async {
    // TODO: Implement Apple Sign In
    // This requires additional setup with sign_in_with_apple package
    throw UnimplementedError('Apple Sign In not implemented yet');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await removeAuthToken();
    } catch (e) {
      throw Exception('Failed to sign out');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return _mapFirebaseUserToUser(firebaseUser);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.userTokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> storeAuthToken(String token) async {
    try {
      await _secureStorage.write(key: AppConstants.userTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to store auth token');
    }
  }

  @override
  Future<void> removeAuthToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.userTokenKey);
      await _secureStorage.delete(key: AppConstants.userIdKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to remove auth token');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await getAuthToken();
      final user = _firebaseAuth.currentUser;
      return token != null && user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to send email verification');
    }
  }

  @override
  Future<void> verifyEmail(String verificationCode) async {
    // Note: Firebase doesn't use verification codes for email verification
    // This would be implemented if using a custom backend
    throw UnimplementedError(
      'Email verification with code not implemented for Firebase',
    );
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      if (name != null) {
        await user.updateDisplayName(name);
      }

      if (profileImageUrl != null) {
        await user.updatePhotoURL(profileImageUrl);
      }

      await user.reload();
      final updatedUser = _firebaseAuth.currentUser!;

      return _mapFirebaseUserToUser(updatedUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      await user.delete();
      await removeAuthToken();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to delete account');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser != null ? _mapFirebaseUserToUser(firebaseUser) : null;
    });
  }

  /// Map Firebase User to domain User entity
  User _mapFirebaseUserToUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      profileImageUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime,
      updatedAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  /// Map Firebase exceptions to user-friendly error messages
  String _mapFirebaseException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
