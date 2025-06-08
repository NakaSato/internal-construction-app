import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/uploaded_image.dart';
import '../../domain/repositories/image_upload_repository.dart';
import '../models/uploaded_image_model.dart';

/// Firebase implementation of image upload repository
@LazySingleton(as: ImageUploadRepository)
class FirebaseImageUploadRepository implements ImageUploadRepository {
  FirebaseImageUploadRepository(
    this._firebaseAuth,
    this._firebaseStorage,
    this._firestore,
  );

  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firestore;

  static const String _imagesCollection = 'user_images';
  static const int _maxImageSize = 2 * 1024 * 1024; // 2MB

  /// Get current user ID
  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<UploadedImage> uploadImage({
    required File imageFile,
    String? description,
    List<String>? tags,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Compress image if too large
    final compressedFile = await _compressImageIfNeeded(imageFile);

    // Generate unique file name
    final fileName = _generateFileName(imageFile.path);
    final storageRef = _firebaseStorage
        .ref()
        .child('images')
        .child(_currentUserId!)
        .child(fileName);

    // Upload to Firebase Storage
    final uploadTask = storageRef.putFile(compressedFile);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Get file stats
    final fileStats = await compressedFile.stat();

    // Create image document
    final imageData = UploadedImageModel(
      id: _generateId(),
      fileName: path.basename(imageFile.path),
      filePath: imageFile.path,
      url: downloadUrl,
      size: fileStats.size,
      mimeType: _getMimeType(imageFile.path),
      uploadedAt: DateTime.now(),
      description: description,
      tags: tags,
    );

    // Save metadata to Firestore
    await _firestore.collection(_imagesCollection).doc(imageData.id).set({
      ...imageData.toJson(),
      'userId': _currentUserId,
    });

    return imageData.toEntity();
  }

  @override
  Future<List<UploadedImage>> uploadMultipleImages({
    required List<File> imageFiles,
    String? description,
    List<String>? tags,
  }) async {
    final uploadedImages = <UploadedImage>[];

    for (final imageFile in imageFiles) {
      try {
        final uploadedImage = await uploadImage(
          imageFile: imageFile,
          description: description,
          tags: tags,
        );
        uploadedImages.add(uploadedImage);
      } catch (e) {
        // Continue with other images if one fails
        print('Failed to upload ${imageFile.path}: $e');
      }
    }

    return uploadedImages;
  }

  @override
  Future<List<UploadedImage>> getUserImages() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final querySnapshot = await _firestore
        .collection(_imagesCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('uploadedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => UploadedImageModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  @override
  Future<UploadedImage?> getImageById(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final doc = await _firestore.collection(_imagesCollection).doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    if (data['userId'] != _currentUserId) {
      throw Exception('Access denied');
    }

    return UploadedImageModel.fromJson(data).toEntity();
  }

  @override
  Future<void> deleteImage(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Get image metadata first
    final imageDoc = await _firestore
        .collection(_imagesCollection)
        .doc(id)
        .get();

    if (!imageDoc.exists) {
      throw Exception('Image not found');
    }

    final imageData = imageDoc.data()!;
    if (imageData['userId'] != _currentUserId) {
      throw Exception('Access denied');
    }

    // Delete from Firebase Storage
    try {
      final storageRef = _firebaseStorage.refFromURL(imageData['url']);
      await storageRef.delete();
    } catch (e) {
      print('Failed to delete from storage: $e');
    }

    // Delete metadata from Firestore
    await _firestore.collection(_imagesCollection).doc(id).delete();
  }

  @override
  Future<UploadedImage> updateImageMetadata({
    required String id,
    String? description,
    List<String>? tags,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final imageDoc = await _firestore
        .collection(_imagesCollection)
        .doc(id)
        .get();

    if (!imageDoc.exists) {
      throw Exception('Image not found');
    }

    final imageData = imageDoc.data()!;
    if (imageData['userId'] != _currentUserId) {
      throw Exception('Access denied');
    }

    // Update metadata
    final updateData = <String, dynamic>{};
    if (description != null) updateData['description'] = description;
    if (tags != null) updateData['tags'] = tags;

    await _firestore.collection(_imagesCollection).doc(id).update(updateData);

    // Return updated image
    final updatedDoc = await _firestore
        .collection(_imagesCollection)
        .doc(id)
        .get();

    return UploadedImageModel.fromJson(updatedDoc.data()!).toEntity();
  }

  @override
  Future<List<UploadedImage>> searchImages({
    String? query,
    List<String>? tags,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    Query queryRef = _firestore
        .collection(_imagesCollection)
        .where('userId', isEqualTo: _currentUserId);

    // Filter by tags if provided
    if (tags != null && tags.isNotEmpty) {
      queryRef = queryRef.where('tags', arrayContainsAny: tags);
    }

    final querySnapshot = await queryRef.get();
    final results = querySnapshot.docs
        .map(
          (doc) => UploadedImageModel.fromJson(
            doc.data() as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();

    // Filter by query string if provided (client-side filtering)
    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      return results.where((image) {
        return image.fileName.toLowerCase().contains(lowercaseQuery) ||
            (image.description?.toLowerCase().contains(lowercaseQuery) ??
                false);
      }).toList();
    }

    return results;
  }

  @override
  Stream<double> getUploadProgress(String uploadId) {
    // This is a simplified implementation
    // In a real app, you'd store the upload task and track its progress
    return Stream.value(1.0);
  }

  /// Compress image if it exceeds the maximum size
  Future<File> _compressImageIfNeeded(File imageFile) async {
    final fileStats = await imageFile.stat();

    if (fileStats.size <= _maxImageSize) {
      return imageFile;
    }

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      '${imageFile.parent.path}/compressed_${path.basename(imageFile.path)}',
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
    );

    return compressedFile != null ? File(compressedFile.path) : imageFile;
  }

  /// Generate unique file name
  String _generateFileName(String originalPath) {
    final extension = path.extension(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '${timestamp}_$random$extension';
  }

  /// Generate unique ID
  String _generateId() {
    return _firestore.collection('temp').doc().id;
  }

  /// Get MIME type from file extension
  String _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
