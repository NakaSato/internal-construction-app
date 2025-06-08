import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/uploaded_image.dart';
import '../../domain/repositories/image_upload_repository.dart';

/// API-based implementation of ImageUploadRepository
@LazySingleton(as: ImageUploadRepository)
class ApiImageUploadRepository implements ImageUploadRepository {
  ApiImageUploadRepository(this._dio);

  final Dio _dio;

  @override
  Future<UploadedImage> uploadImage({
    required File imageFile,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        if (description != null) 'description': description,
        if (tags != null) 'tags': tags.join(','),
      });

      final response = await _dio.post('/api/images/upload', data: formData);

      return UploadedImage(
        id: response.data['id'] as String,
        fileName: response.data['fileName'] as String,
        filePath: imageFile.path,
        url: response.data['url'] as String,
        size: response.data['size'] as int,
        mimeType: response.data['mimeType'] as String,
        uploadedAt: DateTime.parse(response.data['uploadedAt'] as String),
        description: response.data['description'] as String?,
        tags: (response.data['tags'] as List<dynamic>?)?.cast<String>(),
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<List<UploadedImage>> uploadMultipleImages({
    required List<File> imageFiles,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final formData = FormData();

      for (int i = 0; i < imageFiles.length; i++) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              imageFiles[i].path,
              filename: imageFiles[i].path.split('/').last,
            ),
          ),
        );
      }

      if (description != null) {
        formData.fields.add(MapEntry('description', description));
      }
      if (tags != null) {
        formData.fields.add(MapEntry('tags', tags.join(',')));
      }

      final response = await _dio.post(
        '/api/images/upload-multiple',
        data: formData,
      );

      return (response.data['images'] as List<dynamic>)
          .map(
            (imageData) => UploadedImage(
              id: imageData['id'] as String,
              fileName: imageData['fileName'] as String,
              filePath: null, // Not available for multiple uploads
              url: imageData['url'] as String,
              size: imageData['size'] as int,
              mimeType: imageData['mimeType'] as String,
              uploadedAt: DateTime.parse(imageData['uploadedAt'] as String),
              description: imageData['description'] as String?,
              tags: (imageData['tags'] as List<dynamic>?)?.cast<String>(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  @override
  Future<List<UploadedImage>> getUserImages() async {
    try {
      final response = await _dio.get('/api/images/user');

      return (response.data['images'] as List<dynamic>)
          .map(
            (imageData) => UploadedImage(
              id: imageData['id'] as String,
              fileName: imageData['fileName'] as String,
              filePath: null,
              url: imageData['url'] as String,
              size: imageData['size'] as int,
              mimeType: imageData['mimeType'] as String,
              uploadedAt: DateTime.parse(imageData['uploadedAt'] as String),
              description: imageData['description'] as String?,
              tags: (imageData['tags'] as List<dynamic>?)?.cast<String>(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load user images: $e');
    }
  }

  @override
  Future<UploadedImage?> getImageById(String id) async {
    try {
      final response = await _dio.get('/api/images/$id');

      if (response.statusCode == 404) {
        return null;
      }

      final imageData = response.data;
      return UploadedImage(
        id: imageData['id'] as String,
        fileName: imageData['fileName'] as String,
        filePath: null,
        url: imageData['url'] as String,
        size: imageData['size'] as int,
        mimeType: imageData['mimeType'] as String,
        uploadedAt: DateTime.parse(imageData['uploadedAt'] as String),
        description: imageData['description'] as String?,
        tags: (imageData['tags'] as List<dynamic>?)?.cast<String>(),
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to get image by ID: $e');
    }
  }

  @override
  Future<void> deleteImage(String id) async {
    try {
      await _dio.delete('/api/images/$id');
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  @override
  Future<UploadedImage> updateImageMetadata({
    required String id,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (description != null) data['description'] = description;
      if (tags != null) data['tags'] = tags;

      final response = await _dio.put('/api/images/$id', data: data);

      final imageData = response.data;
      return UploadedImage(
        id: imageData['id'] as String,
        fileName: imageData['fileName'] as String,
        filePath: null,
        url: imageData['url'] as String,
        size: imageData['size'] as int,
        mimeType: imageData['mimeType'] as String,
        uploadedAt: DateTime.parse(imageData['uploadedAt'] as String),
        description: imageData['description'] as String?,
        tags: (imageData['tags'] as List<dynamic>?)?.cast<String>(),
      );
    } catch (e) {
      throw Exception('Failed to update image metadata: $e');
    }
  }

  @override
  Future<List<UploadedImage>> searchImages({
    String? query,
    List<String>? tags,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['query'] = query;
      if (tags != null) queryParams['tags'] = tags.join(',');

      final response = await _dio.get(
        '/api/images/search',
        queryParameters: queryParams,
      );

      return (response.data['images'] as List<dynamic>)
          .map(
            (imageData) => UploadedImage(
              id: imageData['id'] as String,
              fileName: imageData['fileName'] as String,
              filePath: null,
              url: imageData['url'] as String,
              size: imageData['size'] as int,
              mimeType: imageData['mimeType'] as String,
              uploadedAt: DateTime.parse(imageData['uploadedAt'] as String),
              description: imageData['description'] as String?,
              tags: (imageData['tags'] as List<dynamic>?)?.cast<String>(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search images: $e');
    }
  }

  @override
  Stream<double> getUploadProgress(String uploadId) {
    // For simplicity, return a mock stream
    // In a real implementation, you'd track upload progress
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (count) => (count * 10).clamp(0, 100).toDouble(),
    ).take(11);
  }
}
