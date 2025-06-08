import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_architecture_app/features/authentication/application/auth_bloc.dart';
import 'package:flutter_architecture_app/features/authentication/application/auth_event.dart';
import 'package:flutter_architecture_app/features/authentication/application/auth_state.dart';
import 'package:flutter_architecture_app/features/authentication/domain/entities/user.dart';

import '../../../test_helpers/test_helpers.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRepositoryFactory mockAuthRepositoryFactory;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepositoryFactory = MockAuthRepositoryFactory();
    mockAuthRepository = MockAuthRepository();

    // Mock factory to return our mock repository
    when(
      mockAuthRepositoryFactory.getAuthRepository(),
    ).thenReturn(mockAuthRepository);

    authBloc = AuthBloc(mockAuthRepositoryFactory);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    final testUser = User(
      userId: 'test_user_id',
      username: 'testuser',
      email: 'test@example.com',
      fullName: 'Test User',
      roleName: 'Technician',
      isEmailVerified: true,
      profileImageUrl: 'https://example.com/profile.jpg',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is authenticated',
        build: () {
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [const AuthLoading(), AuthAuthenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when user is not authenticated',
        build: () {
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [const AuthLoading(), const AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when getCurrentUser throws exception',
        build: () {
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenThrow(Exception('Failed to get current user'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(message: 'Exception: Failed to get current user'),
        ],
      );
    });

    group('AuthSignInRequested', () {
      const email = 'test@example.com';
      const password = 'password123';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign in is successful',
        build: () {
          when(
            mockAuthRepository.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthSignInRequested(username: email, password: password),
        ),
        expect: () => [const AuthLoading(), AuthAuthenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when sign in fails',
        build: () {
          when(
            mockAuthRepository.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenThrow(Exception('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthSignInRequested(username: email, password: password),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(message: 'Exception: Invalid credentials'),
        ],
      );
    });

    group('AuthRegisterRequested', () {
      const username = 'testuser';
      const email = 'test@example.com';
      const password = 'password123';
      const fullName = 'Test User';
      const roleId = 1;

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when registration is successful',
        build: () {
          when(
            mockAuthRepository.registerWithEmailAndPassword(
              email: email,
              password: password,
              name: fullName,
            ),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            username: username,
            email: email,
            password: password,
            fullName: fullName,
            roleId: roleId,
          ),
        ),
        expect: () => [const AuthLoading(), AuthAuthenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when registration fails',
        build: () {
          when(
            mockAuthRepository.registerWithEmailAndPassword(
              email: email,
              password: password,
              name: fullName,
            ),
          ).thenThrow(Exception('Email already exists'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            username: username,
            email: email,
            password: password,
            fullName: fullName,
            roleId: roleId,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(message: 'Exception: Email already exists'),
        ],
      );
    });

    group('AuthPasswordResetRequested', () {
      const email = 'test@example.com';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthPasswordResetSent] when password reset is successful',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email)).thenAnswer((
            _,
          ) async {
            return null;
          });
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: email)),
        expect: () => [const AuthLoading(), const AuthPasswordResetSent()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when password reset fails',
        build: () {
          when(
            mockAuthRepository.sendPasswordResetEmail(email),
          ).thenThrow(Exception('Email not found'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: email)),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(message: 'Exception: Email not found'),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when sign out is successful',
        build: () {
          when(mockAuthRepository.signOut()).thenAnswer((_) async {
            return null;
          });
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [const AuthLoading(), const AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when sign out fails',
        build: () {
          when(
            mockAuthRepository.signOut(),
          ).thenThrow(Exception('Failed to sign out'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(message: 'Exception: Failed to sign out'),
        ],
      );
    });

    group('AuthEmailVerificationRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthEmailVerificationSent] when email verification is successful',
        build: () {
          when(mockAuthRepository.sendEmailVerification()).thenAnswer((
            _,
          ) async {
            return null;
          });
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthEmailVerificationRequested()),
        expect: () => [const AuthLoading(), const AuthEmailVerificationSent()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when email verification fails',
        build: () {
          when(
            mockAuthRepository.sendEmailVerification(),
          ).thenThrow(Exception('Failed to send verification email'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthEmailVerificationRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(
            message: 'Exception: Failed to send verification email',
          ),
        ],
      );
    });

    group('AuthEmailVerifyRequested', () {
      const verificationCode = '123456';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when email verification is successful',
        build: () {
          when(
            mockAuthRepository.verifyEmail(verificationCode),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthEmailVerifyRequested(verificationCode: verificationCode),
        ),
        expect: () => [const AuthLoading(), AuthAuthenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when email verification fails',
        build: () {
          when(
            mockAuthRepository.verifyEmail(verificationCode),
          ).thenThrow(Exception('Invalid verification code'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthEmailVerifyRequested(verificationCode: verificationCode),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(message: 'Exception: Invalid verification code'),
        ],
      );
    });

    group('AuthProfileUpdateRequested', () {
      const updatedName = 'Updated Name';
      const updatedProfileImage = 'https://example.com/new-profile.jpg';

      final updatedUser = testUser.copyWith(
        fullName: updatedName,
        profileImageUrl: updatedProfileImage,
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when profile update is successful',
        build: () {
          when(
            mockAuthRepository.updateProfile(
              name: updatedName,
              profileImageUrl: updatedProfileImage,
            ),
          ).thenAnswer((_) async => updatedUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthProfileUpdateRequested(
            name: updatedName,
            profileImageUrl: updatedProfileImage,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: updatedUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when profile update fails',
        build: () {
          when(
            mockAuthRepository.updateProfile(
              name: updatedName,
              profileImageUrl: updatedProfileImage,
            ),
          ).thenThrow(Exception('Failed to update profile'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthProfileUpdateRequested(
            name: updatedName,
            profileImageUrl: updatedProfileImage,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(message: 'Exception: Failed to update profile'),
        ],
      );
    });

    group('initial state', () {
      test('should be AuthInitial', () {
        expect(authBloc.state, const AuthInitial());
      });
    });
  });
}
