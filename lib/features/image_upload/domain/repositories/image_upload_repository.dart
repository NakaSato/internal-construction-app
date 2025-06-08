import 'dart:io';

import '../entities/uploaded_image.dart';

/// Repository interface for image upload operations
abstract class ImageUploadRepository {
  /// Upload an image from file path
  Future<UploadedImage> uploadImage({
    required File imageFile,
    String? description,
    List<String>? tags,
  });

  /// Upload multiple images
  Future<List<UploadedImage>> uploadMultipleImages({
    required List<File> imageFiles,
    String? description,
    List<String>? tags,
  });

  /// Get all uploaded images for the current user
  Future<List<UploadedImage>> getUserImages();

  /// Get a specific image by ID
  Future<UploadedImage?> getImageById(String id);

  /// Delete an uploaded image
  Future<void> deleteImage(String id);

  /// Update image metadata
  Future<UploadedImage> updateImageMetadata({
    required String id,
    String? description,
    List<String>? tags,
  });

  /// Search images by tags or description
  Future<List<UploadedImage>> searchImages({String? query, List<String>? tags});

  /// Get upload progress stream
  Stream<double> getUploadProgress(String uploadId);
}
