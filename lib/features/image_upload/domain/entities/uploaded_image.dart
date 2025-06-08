import 'package:equatable/equatable.dart';

/// Entity representing an uploaded image
class UploadedImage extends Equatable {
  const UploadedImage({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.url,
    required this.size,
    required this.mimeType,
    required this.uploadedAt,
    this.description,
    this.tags,
  });

  /// Unique identifier for the image
  final String id;

  /// Original file name
  final String fileName;

  /// Local file path (if available)
  final String? filePath;

  /// Remote URL of the uploaded image
  final String url;

  /// File size in bytes
  final int size;

  /// MIME type of the image
  final String mimeType;

  /// Timestamp when the image was uploaded
  final DateTime uploadedAt;

  /// Optional description for the image
  final String? description;

  /// Optional tags for categorization
  final List<String>? tags;

  /// Human-readable file size
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Copy with method for immutable updates
  UploadedImage copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? url,
    int? size,
    String? mimeType,
    DateTime? uploadedAt,
    String? description,
    List<String>? tags,
  }) {
    return UploadedImage(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      url: url ?? this.url,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fileName,
    filePath,
    url,
    size,
    mimeType,
    uploadedAt,
    description,
    tags,
  ];

  @override
  String toString() => 'UploadedImage(id: $id, fileName: $fileName, url: $url)';
}
