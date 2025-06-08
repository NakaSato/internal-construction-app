import '../../domain/entities/uploaded_image.dart';

/// Data model for uploaded image (JSON serialization)
class UploadedImageModel extends UploadedImage {
  const UploadedImageModel({
    required super.id,
    required super.fileName,
    required super.url,
    required super.size,
    required super.mimeType,
    required super.uploadedAt,
    super.filePath,
    super.description,
    super.tags,
  });

  /// Create model from JSON
  factory UploadedImageModel.fromJson(Map<String, dynamic> json) {
    return UploadedImageModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String?,
      url: json['url'] as String,
      size: json['size'] as int,
      mimeType: json['mimeType'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'url': url,
      'size': size,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
      'description': description,
      'tags': tags,
    };
  }

  /// Convert domain entity to model
  factory UploadedImageModel.fromEntity(UploadedImage entity) {
    return UploadedImageModel(
      id: entity.id,
      fileName: entity.fileName,
      filePath: entity.filePath,
      url: entity.url,
      size: entity.size,
      mimeType: entity.mimeType,
      uploadedAt: entity.uploadedAt,
      description: entity.description,
      tags: entity.tags,
    );
  }

  /// Convert model to domain entity
  UploadedImage toEntity() {
    return UploadedImage(
      id: id,
      fileName: fileName,
      filePath: filePath,
      url: url,
      size: size,
      mimeType: mimeType,
      uploadedAt: uploadedAt,
      description: description,
      tags: tags,
    );
  }
}
