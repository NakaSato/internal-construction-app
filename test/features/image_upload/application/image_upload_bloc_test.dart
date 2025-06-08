import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_architecture_app/features/image_upload/application/image_upload_bloc.dart';
import 'package:flutter_architecture_app/features/image_upload/application/image_upload_event.dart';
import 'package:flutter_architecture_app/features/image_upload/application/image_upload_state.dart';
import 'package:flutter_architecture_app/features/image_upload/domain/entities/uploaded_image.dart';

import '../../../test_helpers/test_helpers.mocks.dart';

void main() {
  late ImageUploadBloc imageUploadBloc;
  late MockImageUploadRepository mockRepository;

  setUp(() {
    mockRepository = MockImageUploadRepository();
    imageUploadBloc = ImageUploadBloc(mockRepository);
  });

  tearDown(() {
    imageUploadBloc.close();
  });

  group('ImageUploadBloc', () {
    final testFile = File('/test/path/image.jpg');
    final testFiles = [
      File('/test/path/image1.jpg'),
      File('/test/path/image2.jpg'),
    ];

    final testUploadedImage = UploadedImage(
      id: 'image_123',
      fileName: 'test_image.jpg',
      filePath: '/test/path/image.jpg',
      url: 'https://example.com/image.jpg',
      size: 1024000,
      mimeType: 'image/jpeg',
      uploadedAt: DateTime(2024, 1, 1, 12, 0, 0),
      description: 'Test image',
      tags: ['test', 'sample'],
    );

    final testUploadedImages = [
      testUploadedImage,
      testUploadedImage.copyWith(
        id: 'image_456',
        fileName: 'test_image2.jpg',
        url: 'https://example.com/image2.jpg',
      ),
    ];

    group('UploadImageEvent', () {
      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageUploadSuccess] when image upload is successful',
        build: () {
          when(
            mockRepository.uploadImage(
              imageFile: testFile,
              description: 'Test description',
              tags: ['test', 'sample'],
            ),
          ).thenAnswer((_) async => testUploadedImage);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(
          UploadImageEvent(
            imageFile: testFile,
            description: 'Test description',
            tags: ['test', 'sample'],
          ),
        ),
        expect: () => [
          const ImageUploadLoading(message: 'Uploading image...'),
          ImageUploadSuccess(testUploadedImage),
        ],
        verify: (_) {
          verify(
            mockRepository.uploadImage(
              imageFile: testFile,
              description: 'Test description',
              tags: ['test', 'sample'],
            ),
          ).called(1);
        },
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageUploadError] when image upload fails',
        build: () {
          when(
            mockRepository.uploadImage(
              imageFile: testFile,
              description: 'Test description',
              tags: ['test', 'sample'],
            ),
          ).thenThrow(Exception('Upload failed'));
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(
          UploadImageEvent(
            imageFile: testFile,
            description: 'Test description',
            tags: ['test', 'sample'],
          ),
        ),
        expect: () => [
          const ImageUploadLoading(message: 'Uploading image...'),
          const ImageUploadError(
            'Failed to upload image: Exception: Upload failed',
          ),
        ],
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageUploadSuccess] when uploading without description and tags',
        build: () {
          when(
            mockRepository.uploadImage(
              imageFile: testFile,
              description: null,
              tags: null,
            ),
          ).thenAnswer(
            (_) async =>
                testUploadedImage.copyWith(description: null, tags: null),
          );
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(UploadImageEvent(imageFile: testFile)),
        expect: () => [
          const ImageUploadLoading(message: 'Uploading image...'),
          isA<ImageUploadSuccess>(),
        ],
      );
    });

    group('UploadMultipleImagesEvent', () {
      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, MultipleImagesUploadSuccess] when multiple images upload is successful',
        build: () {
          when(
            mockRepository.uploadMultipleImages(
              imageFiles: testFiles,
              description: 'Batch upload',
              tags: ['batch', 'multiple'],
            ),
          ).thenAnswer((_) async => testUploadedImages);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(
          UploadMultipleImagesEvent(
            imageFiles: testFiles,
            description: 'Batch upload',
            tags: ['batch', 'multiple'],
          ),
        ),
        expect: () => [
          const ImageUploadLoading(message: 'Uploading images...'),
          MultipleImagesUploadSuccess(testUploadedImages),
        ],
        verify: (_) {
          verify(
            mockRepository.uploadMultipleImages(
              imageFiles: testFiles,
              description: 'Batch upload',
              tags: ['batch', 'multiple'],
            ),
          ).called(1);
        },
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageUploadError] when multiple images upload fails',
        build: () {
          when(
            mockRepository.uploadMultipleImages(
              imageFiles: testFiles,
              description: null,
              tags: null,
            ),
          ).thenThrow(Exception('Batch upload failed'));
          return imageUploadBloc;
        },
        act: (bloc) =>
            bloc.add(UploadMultipleImagesEvent(imageFiles: testFiles)),
        expect: () => [
          const ImageUploadLoading(message: 'Uploading images...'),
          const ImageUploadError(
            'Failed to upload images: Exception: Batch upload failed',
          ),
        ],
      );
    });

    group('LoadUserImagesEvent', () {
      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImagesLoaded] when loading user images is successful',
        build: () {
          when(
            mockRepository.getUserImages(),
          ).thenAnswer((_) async => testUploadedImages);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(const LoadUserImagesEvent()),
        expect: () => [
          const ImageUploadLoading(message: 'Loading images...'),
          ImagesLoaded(testUploadedImages),
        ],
        verify: (_) {
          verify(mockRepository.getUserImages()).called(1);
        },
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImagesLoaded] with empty list when user has no images',
        build: () {
          when(mockRepository.getUserImages()).thenAnswer((_) async => []);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(const LoadUserImagesEvent()),
        expect: () => [
          const ImageUploadLoading(message: 'Loading images...'),
          const ImagesLoaded([]),
        ],
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageUploadError] when loading user images fails',
        build: () {
          when(
            mockRepository.getUserImages(),
          ).thenThrow(Exception('Failed to fetch images'));
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(const LoadUserImagesEvent()),
        expect: () => [
          const ImageUploadLoading(message: 'Loading images...'),
          const ImageUploadError(
            'Failed to load images: Exception: Failed to fetch images',
          ),
        ],
      );
    });

    group('DeleteImageEvent', () {
      const imageId = 'image_123';

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageDeleted, ImageUploadLoading, ImagesLoaded] when deletion is successful',
        build: () {
          when(mockRepository.deleteImage(imageId)).thenAnswer((_) async {
            return null;
          });
          when(
            mockRepository.getUserImages(),
          ).thenAnswer((_) async => [testUploadedImages[1]]); // Remaining image
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(const DeleteImageEvent(imageId)),
        expect: () => [
          const ImageUploadLoading(message: 'Deleting image...'),
          const ImageDeleted(imageId),
          const ImageUploadLoading(message: 'Loading images...'),
          ImagesLoaded([testUploadedImages[1]]),
        ],
        verify: (_) {
          verify(mockRepository.deleteImage(imageId)).called(1);
          verify(mockRepository.getUserImages()).called(1);
        },
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageUploadError] when deletion fails',
        build: () {
          when(
            mockRepository.deleteImage(imageId),
          ).thenThrow(Exception('Delete failed'));
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(const DeleteImageEvent(imageId)),
        expect: () => [
          const ImageUploadLoading(message: 'Deleting image...'),
          const ImageUploadError(
            'Failed to delete image: Exception: Delete failed',
          ),
        ],
        verify: (_) {
          verify(mockRepository.deleteImage(imageId)).called(1);
          verifyNever(mockRepository.getUserImages());
        },
      );
    });

    group('UpdateImageMetadataEvent', () {
      const imageId = 'image_123';
      const updatedDescription = 'Updated description';
      const updatedTags = ['updated', 'modified'];

      final updatedImage = testUploadedImage.copyWith(
        description: updatedDescription,
        tags: updatedTags,
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageMetadataUpdated] when update is successful',
        build: () {
          when(
            mockRepository.updateImageMetadata(
              id: imageId,
              description: updatedDescription,
              tags: updatedTags,
            ),
          ).thenAnswer((_) async => updatedImage);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(
          const UpdateImageMetadataEvent(
            imageId: imageId,
            description: updatedDescription,
            tags: updatedTags,
          ),
        ),
        expect: () => [
          const ImageUploadLoading(message: 'Updating image...'),
          ImageMetadataUpdated(updatedImage),
        ],
        verify: (_) {
          verify(
            mockRepository.updateImageMetadata(
              id: imageId,
              description: updatedDescription,
              tags: updatedTags,
            ),
          ).called(1);
        },
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageUploadError] when update fails',
        build: () {
          when(
            mockRepository.updateImageMetadata(
              id: imageId,
              description: updatedDescription,
              tags: updatedTags,
            ),
          ).thenThrow(Exception('Update failed'));
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(
          const UpdateImageMetadataEvent(
            imageId: imageId,
            description: updatedDescription,
            tags: updatedTags,
          ),
        ),
        expect: () => [
          const ImageUploadLoading(message: 'Updating image...'),
          const ImageUploadError(
            'Failed to update image: Exception: Update failed',
          ),
        ],
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageMetadataUpdated] when updating only description',
        build: () {
          final partialUpdatedImage = testUploadedImage.copyWith(
            description: updatedDescription,
          );
          when(
            mockRepository.updateImageMetadata(
              id: imageId,
              description: updatedDescription,
              tags: null,
            ),
          ).thenAnswer((_) async => partialUpdatedImage);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(
          const UpdateImageMetadataEvent(
            imageId: imageId,
            description: updatedDescription,
          ),
        ),
        expect: () => [
          const ImageUploadLoading(message: 'Updating image...'),
          isA<ImageMetadataUpdated>(),
        ],
      );
    });

    group('SearchImagesEvent', () {
      const searchQuery = 'test query';
      const searchTags = ['test', 'sample'];

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageSearchResults] when search is successful',
        build: () {
          when(
            mockRepository.searchImages(query: searchQuery, tags: searchTags),
          ).thenAnswer((_) async => [testUploadedImage]);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(
          const SearchImagesEvent(query: searchQuery, tags: searchTags),
        ),
        expect: () => [
          const ImageUploadLoading(message: 'Searching images...'),
          ImageSearchResults(
            results: [testUploadedImage],
            query: searchQuery,
            tags: searchTags,
          ),
        ],
        verify: (_) {
          verify(
            mockRepository.searchImages(query: searchQuery, tags: searchTags),
          ).called(1);
        },
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageSearchResults] with empty results when no matches found',
        build: () {
          when(
            mockRepository.searchImages(query: 'nonexistent', tags: null),
          ).thenAnswer((_) async => []);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(const SearchImagesEvent(query: 'nonexistent')),
        expect: () => [
          const ImageUploadLoading(message: 'Searching images...'),
          const ImageSearchResults(
            results: [],
            query: 'nonexistent',
            tags: null,
          ),
        ],
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageUploadError] when search fails',
        build: () {
          when(
            mockRepository.searchImages(query: searchQuery, tags: null),
          ).thenThrow(Exception('Search failed'));
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(const SearchImagesEvent(query: searchQuery)),
        expect: () => [
          const ImageUploadLoading(message: 'Searching images...'),
          const ImageUploadError(
            'Failed to search images: Exception: Search failed',
          ),
        ],
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadLoading, ImageSearchResults] when searching by tags only',
        build: () {
          when(
            mockRepository.searchImages(query: null, tags: searchTags),
          ).thenAnswer((_) async => testUploadedImages);
          return imageUploadBloc;
        },
        act: (bloc) => bloc.add(const SearchImagesEvent(tags: searchTags)),
        expect: () => [
          const ImageUploadLoading(message: 'Searching images...'),
          ImageSearchResults(
            results: testUploadedImages,
            query: null,
            tags: searchTags,
          ),
        ],
      );
    });

    group('ResetImageUploadEvent', () {
      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadInitial] when reset is triggered',
        build: () => imageUploadBloc,
        seed: () => ImagesLoaded(testUploadedImages),
        act: (bloc) => bloc.add(const ResetImageUploadEvent()),
        expect: () => [const ImageUploadInitial()],
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'emits [ImageUploadInitial] when reset from error state',
        build: () => imageUploadBloc,
        seed: () => const ImageUploadError('Some error occurred'),
        act: (bloc) => bloc.add(const ResetImageUploadEvent()),
        expect: () => [const ImageUploadInitial()],
      );
    });

    group('initial state', () {
      test('should be ImageUploadInitial', () {
        expect(imageUploadBloc.state, const ImageUploadInitial());
      });
    });

    group('complex workflow scenarios', () {
      blocTest<ImageUploadBloc, ImageUploadState>(
        'handles upload followed by load user images',
        build: () {
          when(
            mockRepository.uploadImage(
              imageFile: testFile,
              description: null,
              tags: null,
            ),
          ).thenAnswer((_) async => testUploadedImage);
          when(
            mockRepository.getUserImages(),
          ).thenAnswer((_) async => [testUploadedImage]);
          return imageUploadBloc;
        },
        act: (bloc) async {
          bloc.add(UploadImageEvent(imageFile: testFile));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const LoadUserImagesEvent());
        },
        expect: () => [
          const ImageUploadLoading(message: 'Uploading image...'),
          ImageUploadSuccess(testUploadedImage),
          const ImageUploadLoading(message: 'Loading images...'),
          ImagesLoaded([testUploadedImage]),
        ],
      );

      blocTest<ImageUploadBloc, ImageUploadState>(
        'handles search followed by reset',
        build: () {
          when(
            mockRepository.searchImages(query: 'test', tags: null),
          ).thenAnswer((_) async => [testUploadedImage]);
          return imageUploadBloc;
        },
        act: (bloc) async {
          bloc.add(const SearchImagesEvent(query: 'test'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const ResetImageUploadEvent());
        },
        expect: () => [
          const ImageUploadLoading(message: 'Searching images...'),
          ImageSearchResults(
            results: [testUploadedImage],
            query: 'test',
            tags: null,
          ),
          const ImageUploadInitial(),
        ],
      );
    });
  });
}
