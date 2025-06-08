import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_architecture_app/features/image_upload/infrastructure/repositories/api_image_upload_repository.dart';

import '../../../../test_helpers/test_helpers.mocks.dart';

void main() {
  late ApiImageUploadRepository repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repository = ApiImageUploadRepository(mockDio);
  });

  group('ApiImageUploadRepository', () {
    group('uploadImage', () {
      test('should upload image successfully with all metadata', () async {
        // Arrange
        final testFile = File('/path/to/test_image.jpg');
        const description = 'Test image description';
        const tags = ['test', 'sample'];

        final responseData = {
          'id': 'image_123',
          'fileName': 'test_image.jpg',
          'url': 'https://example.com/images/test_image.jpg',
          'size': 1024000,
          'mimeType': 'image/jpeg',
          'uploadedAt': '2024-01-01T12:00:00.000Z',
          'description': description,
          'tags': tags,
        };

        when(
          mockDio.post('/api/images/upload', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/upload'),
          ),
        );

        // Act
        final result = await repository.uploadImage(
          imageFile: testFile,
          description: description,
          tags: tags,
        );

        // Assert
        expect(result.id, equals('image_123'));
        expect(result.fileName, equals('test_image.jpg'));
        expect(result.filePath, equals('/path/to/test_image.jpg'));
        expect(result.url, equals('https://example.com/images/test_image.jpg'));
        expect(result.size, equals(1024000));
        expect(result.mimeType, equals('image/jpeg'));
        expect(result.description, equals(description));
        expect(result.tags, equals(tags));

        verify(
          mockDio.post('/api/images/upload', data: anyNamed('data')),
        ).called(1);
      });

      test(
        'should upload image successfully without optional metadata',
        () async {
          // Arrange
          final testFile = File('/path/to/test_image.jpg');

          final responseData = {
            'id': 'image_123',
            'fileName': 'test_image.jpg',
            'url': 'https://example.com/images/test_image.jpg',
            'size': 1024000,
            'mimeType': 'image/jpeg',
            'uploadedAt': '2024-01-01T12:00:00.000Z',
            'description': null,
            'tags': null,
          };

          when(
            mockDio.post('/api/images/upload', data: anyNamed('data')),
          ).thenAnswer(
            (_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/api/images/upload'),
            ),
          );

          // Act
          final result = await repository.uploadImage(imageFile: testFile);

          // Assert
          expect(result.id, equals('image_123'));
          expect(result.description, isNull);
          expect(result.tags, isNull);

          verify(
            mockDio.post('/api/images/upload', data: anyNamed('data')),
          ).called(1);
        },
      );

      test('should throw exception when upload fails', () async {
        // Arrange
        final testFile = File('/path/to/test_image.jpg');

        when(
          mockDio.post('/api/images/upload', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/images/upload'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/api/images/upload'),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.uploadImage(imageFile: testFile),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to upload image'),
            ),
          ),
        );
      });
    });

    group('uploadMultipleImages', () {
      test('should upload multiple images successfully', () async {
        // Arrange
        final testFiles = [
          File('/path/to/image1.jpg'),
          File('/path/to/image2.png'),
        ];
        const description = 'Batch upload';
        const tags = ['batch', 'multiple'];

        final responseData = {
          'images': [
            {
              'id': 'image_1',
              'fileName': 'image1.jpg',
              'url': 'https://example.com/images/image1.jpg',
              'size': 1024000,
              'mimeType': 'image/jpeg',
              'uploadedAt': '2024-01-01T12:00:00.000Z',
              'description': description,
              'tags': tags,
            },
            {
              'id': 'image_2',
              'fileName': 'image2.png',
              'url': 'https://example.com/images/image2.png',
              'size': 2048000,
              'mimeType': 'image/png',
              'uploadedAt': '2024-01-01T12:01:00.000Z',
              'description': description,
              'tags': tags,
            },
          ],
        };

        when(
          mockDio.post('/api/images/upload-multiple', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/upload-multiple'),
          ),
        );

        // Act
        final result = await repository.uploadMultipleImages(
          imageFiles: testFiles,
          description: description,
          tags: tags,
        );

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals('image_1'));
        expect(result[0].fileName, equals('image1.jpg'));
        expect(
          result[0].filePath,
          isNull,
        ); // Not available for multiple uploads
        expect(result[1].id, equals('image_2'));
        expect(result[1].fileName, equals('image2.png'));

        verify(
          mockDio.post('/api/images/upload-multiple', data: anyNamed('data')),
        ).called(1);
      });

      test('should upload multiple images without optional metadata', () async {
        // Arrange
        final testFiles = [File('/path/to/image1.jpg')];

        final responseData = {
          'images': [
            {
              'id': 'image_1',
              'fileName': 'image1.jpg',
              'url': 'https://example.com/images/image1.jpg',
              'size': 1024000,
              'mimeType': 'image/jpeg',
              'uploadedAt': '2024-01-01T12:00:00.000Z',
              'description': null,
              'tags': null,
            },
          ],
        };

        when(
          mockDio.post('/api/images/upload-multiple', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/upload-multiple'),
          ),
        );

        // Act
        final result = await repository.uploadMultipleImages(
          imageFiles: testFiles,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result[0].description, isNull);
        expect(result[0].tags, isNull);
      });

      test('should throw exception when multiple upload fails', () async {
        // Arrange
        final testFiles = [File('/path/to/image1.jpg')];

        when(
          mockDio.post('/api/images/upload-multiple', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/images/upload-multiple'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.uploadMultipleImages(imageFiles: testFiles),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to upload multiple images'),
            ),
          ),
        );
      });
    });

    group('getUserImages', () {
      test('should get user images successfully', () async {
        // Arrange
        final responseData = {
          'images': [
            {
              'id': 'image_1',
              'fileName': 'image1.jpg',
              'url': 'https://example.com/images/image1.jpg',
              'size': 1024000,
              'mimeType': 'image/jpeg',
              'uploadedAt': '2024-01-01T12:00:00.000Z',
              'description': 'First image',
              'tags': ['tag1', 'tag2'],
            },
            {
              'id': 'image_2',
              'fileName': 'image2.png',
              'url': 'https://example.com/images/image2.png',
              'size': 2048000,
              'mimeType': 'image/png',
              'uploadedAt': '2024-01-01T12:01:00.000Z',
              'description': null,
              'tags': null,
            },
          ],
        };

        when(mockDio.get('/api/images/user')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/user'),
          ),
        );

        // Act
        final result = await repository.getUserImages();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals('image_1'));
        expect(result[0].description, equals('First image'));
        expect(result[0].tags, equals(['tag1', 'tag2']));
        expect(result[1].id, equals('image_2'));
        expect(result[1].description, isNull);
        expect(result[1].tags, isNull);

        verify(mockDio.get('/api/images/user')).called(1);
      });

      test('should return empty list when no images', () async {
        // Arrange
        final responseData = {'images': <dynamic>[]};

        when(mockDio.get('/api/images/user')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/user'),
          ),
        );

        // Act
        final result = await repository.getUserImages();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when getting user images fails', () async {
        // Arrange
        when(mockDio.get('/api/images/user')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/images/user'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getUserImages(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load user images'),
            ),
          ),
        );
      });
    });

    group('getImageById', () {
      test('should get image by ID successfully', () async {
        // Arrange
        const imageId = 'image_123';
        final responseData = {
          'id': imageId,
          'fileName': 'test_image.jpg',
          'url': 'https://example.com/images/test_image.jpg',
          'size': 1024000,
          'mimeType': 'image/jpeg',
          'uploadedAt': '2024-01-01T12:00:00.000Z',
          'description': 'Test image',
          'tags': ['test'],
        };

        when(mockDio.get('/api/images/$imageId')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
          ),
        );

        // Act
        final result = await repository.getImageById(imageId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(imageId));
        expect(result.fileName, equals('test_image.jpg'));
        expect(result.description, equals('Test image'));

        verify(mockDio.get('/api/images/$imageId')).called(1);
      });

      test('should return null when image not found (404 status)', () async {
        // Arrange
        const imageId = 'nonexistent_image';
        when(mockDio.get('/api/images/$imageId')).thenAnswer(
          (_) async => Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
          ),
        );

        // Act
        final result = await repository.getImageById(imageId);

        // Assert
        expect(result, isNull);
      });

      test('should return null when DioException with 404', () async {
        // Arrange
        const imageId = 'nonexistent_image';
        when(mockDio.get('/api/images/$imageId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/api/images/$imageId'),
            ),
          ),
        );

        // Act
        final result = await repository.getImageById(imageId);

        // Assert
        expect(result, isNull);
      });

      test('should throw exception for other errors', () async {
        // Arrange
        const imageId = 'image_123';
        when(mockDio.get('/api/images/$imageId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/api/images/$imageId'),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getImageById(imageId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get image by ID'),
            ),
          ),
        );
      });
    });

    group('deleteImage', () {
      test('should delete image successfully', () async {
        // Arrange
        const imageId = 'image_123';
        when(mockDio.delete('/api/images/$imageId')).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
          ),
        );

        // Act
        await repository.deleteImage(imageId);

        // Assert
        verify(mockDio.delete('/api/images/$imageId')).called(1);
      });

      test('should throw exception when delete fails', () async {
        // Arrange
        const imageId = 'image_123';
        when(mockDio.delete('/api/images/$imageId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.deleteImage(imageId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to delete image'),
            ),
          ),
        );
      });
    });

    group('updateImageMetadata', () {
      test('should update image metadata with description and tags', () async {
        // Arrange
        const imageId = 'image_123';
        const newDescription = 'Updated description';
        const newTags = ['updated', 'metadata'];

        final responseData = {
          'id': imageId,
          'fileName': 'test_image.jpg',
          'url': 'https://example.com/images/test_image.jpg',
          'size': 1024000,
          'mimeType': 'image/jpeg',
          'uploadedAt': '2024-01-01T12:00:00.000Z',
          'description': newDescription,
          'tags': newTags,
        };

        when(
          mockDio.put('/api/images/$imageId', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
          ),
        );

        // Act
        final result = await repository.updateImageMetadata(
          id: imageId,
          description: newDescription,
          tags: newTags,
        );

        // Assert
        expect(result.id, equals(imageId));
        expect(result.description, equals(newDescription));
        expect(result.tags, equals(newTags));

        verify(
          mockDio.put(
            '/api/images/$imageId',
            data: {'description': newDescription, 'tags': newTags},
          ),
        ).called(1);
      });

      test('should update image metadata with only description', () async {
        // Arrange
        const imageId = 'image_123';
        const newDescription = 'Updated description';

        final responseData = {
          'id': imageId,
          'fileName': 'test_image.jpg',
          'url': 'https://example.com/images/test_image.jpg',
          'size': 1024000,
          'mimeType': 'image/jpeg',
          'uploadedAt': '2024-01-01T12:00:00.000Z',
          'description': newDescription,
          'tags': null,
        };

        when(
          mockDio.put('/api/images/$imageId', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
          ),
        );

        // Act
        final result = await repository.updateImageMetadata(
          id: imageId,
          description: newDescription,
        );

        // Assert
        expect(result.description, equals(newDescription));

        verify(
          mockDio.put(
            '/api/images/$imageId',
            data: {'description': newDescription},
          ),
        ).called(1);
      });

      test('should update image metadata with only tags', () async {
        // Arrange
        const imageId = 'image_123';
        const newTags = ['updated', 'tags'];

        final responseData = {
          'id': imageId,
          'fileName': 'test_image.jpg',
          'url': 'https://example.com/images/test_image.jpg',
          'size': 1024000,
          'mimeType': 'image/jpeg',
          'uploadedAt': '2024-01-01T12:00:00.000Z',
          'description': null,
          'tags': newTags,
        };

        when(
          mockDio.put('/api/images/$imageId', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
          ),
        );

        // Act
        final result = await repository.updateImageMetadata(
          id: imageId,
          tags: newTags,
        );

        // Assert
        expect(result.tags, equals(newTags));

        verify(
          mockDio.put('/api/images/$imageId', data: {'tags': newTags}),
        ).called(1);
      });

      test('should throw exception when update fails', () async {
        // Arrange
        const imageId = 'image_123';
        when(
          mockDio.put('/api/images/$imageId', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/images/$imageId'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.updateImageMetadata(
            id: imageId,
            description: 'New description',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to update image metadata'),
            ),
          ),
        );
      });
    });

    group('searchImages', () {
      test('should search images by query and tags', () async {
        // Arrange
        const query = 'test search';
        const tags = ['search', 'test'];

        final responseData = {
          'images': [
            {
              'id': 'image_1',
              'fileName': 'search_result1.jpg',
              'url': 'https://example.com/images/search_result1.jpg',
              'size': 1024000,
              'mimeType': 'image/jpeg',
              'uploadedAt': '2024-01-01T12:00:00.000Z',
              'description': 'Test search result',
              'tags': ['test', 'search'],
            },
          ],
        };

        when(
          mockDio.get(
            '/api/images/search',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/search'),
          ),
        );

        // Act
        final result = await repository.searchImages(query: query, tags: tags);

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('image_1'));
        expect(result[0].description, equals('Test search result'));

        verify(
          mockDio.get(
            '/api/images/search',
            queryParameters: {'query': query, 'tags': 'search,test'},
          ),
        ).called(1);
      });

      test('should search images by query only', () async {
        // Arrange
        const query = 'test search';

        final responseData = {'images': <dynamic>[]};

        when(
          mockDio.get(
            '/api/images/search',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/search'),
          ),
        );

        // Act
        final result = await repository.searchImages(query: query);

        // Assert
        expect(result, isEmpty);

        verify(
          mockDio.get('/api/images/search', queryParameters: {'query': query}),
        ).called(1);
      });

      test('should search images by tags only', () async {
        // Arrange
        const tags = ['search', 'test'];

        final responseData = {'images': <dynamic>[]};

        when(
          mockDio.get(
            '/api/images/search',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/search'),
          ),
        );

        // Act
        final result = await repository.searchImages(tags: tags);

        // Assert
        expect(result, isEmpty);

        verify(
          mockDio.get(
            '/api/images/search',
            queryParameters: {'tags': 'search,test'},
          ),
        ).called(1);
      });

      test('should search images without parameters', () async {
        // Arrange
        final responseData = {'images': <dynamic>[]};

        when(
          mockDio.get(
            '/api/images/search',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/images/search'),
          ),
        );

        // Act
        final result = await repository.searchImages();

        // Assert
        expect(result, isEmpty);

        verify(
          mockDio.get(
            '/api/images/search',
            queryParameters: <String, dynamic>{},
          ),
        ).called(1);
      });

      test('should throw exception when search fails', () async {
        // Arrange
        when(
          mockDio.get(
            '/api/images/search',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/images/search'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.searchImages(query: 'test'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to search images'),
            ),
          ),
        );
      });
    });

    group('getUploadProgress', () {
      test('should provide upload progress stream', () async {
        // Arrange
        const uploadId = 'upload_123';

        // Act
        final progressStream = repository.getUploadProgress(uploadId);

        // Assert
        await expectLater(
          progressStream,
          emitsInOrder([
            0.0,
            10.0,
            20.0,
            30.0,
            40.0,
            50.0,
            60.0,
            70.0,
            80.0,
            90.0,
            100.0,
          ]),
        );
      });

      test('should complete progress stream after reaching 100%', () async {
        // Arrange
        const uploadId = 'upload_123';

        // Act
        final progressStream = repository.getUploadProgress(uploadId);

        // Assert
        await expectLater(progressStream, emitsThrough(100.0));
      });
    });
  });
}
