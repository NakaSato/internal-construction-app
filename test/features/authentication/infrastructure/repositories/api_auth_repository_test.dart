import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_architecture_app/features/authentication/infrastructure/repositories/api_auth_repository.dart';
import 'package:flutter_architecture_app/features/authentication/infrastructure/services/auth_api_service.dart';
import 'package:flutter_architecture_app/features/authentication/infrastructure/models/auth_response_model.dart';
import 'package:flutter_architecture_app/features/authentication/infrastructure/models/user_model.dart';

import 'api_auth_repository_test.mocks.dart';

// Generate mocks using build_runner: dart run build_runner build
@GenerateMocks([AuthApiService, FlutterSecureStorage])
void main() {
  group('ApiAuthRepository', () {
    late ApiAuthRepository repository;
    late MockAuthApiService mockApiService;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockApiService = MockAuthApiService();
      mockSecureStorage = MockFlutterSecureStorage();
      repository = ApiAuthRepository(mockApiService, mockSecureStorage);
    });

    group('signInWithEmailAndPassword', () {
      test('should return user when login is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const token = 'mock_jwt_token';

        final userModel = UserModel(
          userId: '1',
          username: 'testuser',
          email: email,
          fullName: 'Test User',
          roleName: 'Technician',
          isActive: true,
          profileImageUrl: null,
          phoneNumber: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final authResponse = LoginResponseApiResponse(
          success: true,
          message: 'Login successful',
          data: LoginResponse(
            token: token,
            refreshToken: 'refresh_token',
            user: userModel,
          ),
        );

        when(mockApiService.login(any)).thenAnswer((_) async => authResponse);
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.userId, equals('1'));
        expect(result.email, equals(email));
        expect(result.fullName, equals('Test User'));

        verify(mockApiService.login(any)).called(1);
        verify(
          mockSecureStorage.write(key: 'auth_token', value: token),
        ).called(1);
        verify(
          mockSecureStorage.write(key: 'refresh_token', value: 'refresh_token'),
        ).called(1);
      });

      test('should throw exception when login fails with 401', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';

        when(mockApiService.login(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/login'),
              statusCode: 401,
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Invalid email or password'),
            ),
          ),
        );
      });

      test(
        'should throw exception when API returns unsuccessful response',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          final authResponse = LoginResponseApiResponse(
            success: false,
            message: 'Invalid credentials',
            data: null,
          );

          when(mockApiService.login(any)).thenAnswer((_) async => authResponse);

          // Act & Assert
          expect(
            () => repository.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Invalid credentials'),
              ),
            ),
          );
        },
      );
    });

    group('registerWithEmailAndPassword', () {
      test('should return user when registration is successful', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const name = 'New User';

        final userModel = UserModel(
          userId: '2',
          username: 'newuser',
          email: email,
          fullName: name,
          roleName: 'Technician',
          isActive: true,
          profileImageUrl: null,
          phoneNumber: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final authResponse = UserDtoApiResponse(
          success: true,
          message: 'Registration successful',
          data: userModel,
        );

        when(
          mockApiService.register(any),
        ).thenAnswer((_) async => authResponse);
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.registerWithEmailAndPassword(
          email: email,
          password: password,
          name: name,
        );

        // Assert
        expect(result.userId, equals('2'));
        expect(result.email, equals(email));
        expect(result.fullName, equals(name));

        verify(mockApiService.register(any)).called(1);
        // Registration doesn't automatically store tokens
        verifyNever(
          mockSecureStorage.write(key: 'auth_token', value: anyNamed('value')),
        );
      });

      test('should throw exception when user already exists', () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'password123';
        const name = 'Existing User';

        when(mockApiService.register(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/register'),
            response: Response(
              requestOptions: RequestOptions(path: '/register'),
              statusCode: 409,
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.registerWithEmailAndPassword(
            email: email,
            password: password,
            name: name,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('User already exists'),
            ),
          ),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return cached user when available', () async {
        // Arrange
        final userModel = UserModel(
          userId: '1',
          username: 'testuser',
          email: 'test@example.com',
          fullName: 'Test User',
          roleName: 'Technician',
          isActive: true,
          profileImageUrl: null,
          phoneNumber: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final userJson = userModel.toJson();
        final userJsonString = jsonEncode(userJson);

        when(
          mockSecureStorage.read(key: 'cached_user'),
        ).thenAnswer((_) async => userJsonString);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.email, equals('test@example.com'));
      });

      test('should return null when no cached user and no token', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'cached_user'),
        ).thenAnswer((_) async => null);
        when(
          mockSecureStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });

      test('should return null when no cached user but token exists', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'cached_user'),
        ).thenAnswer((_) async => null);
        when(
          mockSecureStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => 'some_token');

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('isAuthenticated', () {
      test('should return true when token exists', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => 'valid_token');

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when token does not exist', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when token is empty', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => '');

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });
    });

    group('refreshAuthToken', () {
      test('should return new token when refresh is successful', () async {
        // Arrange
        const refreshToken = 'valid_refresh_token';
        const newToken = 'new_access_token';

        final refreshResponse = StringApiResponse(
          success: true,
          message: 'Token refreshed',
          data: newToken,
        );

        when(
          mockSecureStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => refreshToken);
        when(
          mockApiService.refreshToken(any),
        ).thenAnswer((_) async => refreshResponse);
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.refreshAuthToken();

        // Assert
        expect(result, equals(newToken));
        verify(
          mockSecureStorage.write(key: 'auth_token', value: newToken),
        ).called(1);
      });

      test('should return null when refresh token is not available', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.refreshAuthToken();

        // Assert
        expect(result, isNull);
        verifyNever(mockApiService.refreshToken(any));
      });

      test('should return null when refresh fails', () async {
        // Arrange
        const refreshToken = 'invalid_refresh_token';

        when(
          mockSecureStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => refreshToken);
        when(
          mockApiService.refreshToken(any),
        ).thenThrow(Exception('Refresh failed'));

        // Act
        final result = await repository.refreshAuthToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('token management', () {
      test('getAuthToken should return stored token', () async {
        // Arrange
        const token = 'stored_token';
        when(
          mockSecureStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => token);

        // Act
        final result = await repository.getAuthToken();

        // Assert
        expect(result, equals(token));
      });

      test('storeAuthToken should save token to secure storage', () async {
        // Arrange
        const token = 'new_token';
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await repository.storeAuthToken(token);

        // Assert
        verify(
          mockSecureStorage.write(key: 'auth_token', value: token),
        ).called(1);
      });

      test(
        'removeAuthToken should delete tokens from secure storage',
        () async {
          // Arrange
          when(
            mockSecureStorage.delete(key: anyNamed('key')),
          ).thenAnswer((_) async {});

          // Act
          await repository.removeAuthToken();

          // Assert
          verify(mockSecureStorage.delete(key: 'auth_token')).called(1);
          verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
        },
      );
    });

    group('unimplemented methods', () {
      test('sendPasswordResetEmail should throw UnimplementedError', () async {
        expect(
          () => repository.sendPasswordResetEmail('test@example.com'),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('sendEmailVerification should throw UnimplementedError', () async {
        expect(
          () => repository.sendEmailVerification(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('verifyEmail should throw UnimplementedError', () async {
        expect(
          () => repository.verifyEmail('123456'),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('updateProfile should throw UnimplementedError', () async {
        expect(
          () => repository.updateProfile(name: 'New Name'),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('deleteAccount should throw UnimplementedError', () async {
        expect(
          () => repository.deleteAccount(),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
}
