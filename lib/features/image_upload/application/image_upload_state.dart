import 'package:equatable/equatable.dart';

import '../domain/entities/uploaded_image.dart';

/// Base class for image upload states
abstract class ImageUploadState extends Equatable {
  const ImageUploadState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ImageUploadInitial extends ImageUploadState {
  const ImageUploadInitial();
}

/// Loading state
class ImageUploadLoading extends ImageUploadState {
  const ImageUploadLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Upload progress state
class ImageUploadProgress extends ImageUploadState {
  const ImageUploadProgress({required this.progress, this.fileName});

  final double progress;
  final String? fileName;

  @override
  List<Object?> get props => [progress, fileName];
}

/// Single image upload success state
class ImageUploadSuccess extends ImageUploadState {
  const ImageUploadSuccess(this.uploadedImage);

  final UploadedImage uploadedImage;

  @override
  List<Object?> get props => [uploadedImage];
}

/// Multiple images upload success state
class MultipleImagesUploadSuccess extends ImageUploadState {
  const MultipleImagesUploadSuccess(this.uploadedImages);

  final List<UploadedImage> uploadedImages;

  @override
  List<Object?> get props => [uploadedImages];
}

/// Images loaded state
class ImagesLoaded extends ImageUploadState {
  const ImagesLoaded(this.images);

  final List<UploadedImage> images;

  @override
  List<Object?> get props => [images];
}

/// Image deleted state
class ImageDeleted extends ImageUploadState {
  const ImageDeleted(this.deletedImageId);

  final String deletedImageId;

  @override
  List<Object?> get props => [deletedImageId];
}

/// Image metadata updated state
class ImageMetadataUpdated extends ImageUploadState {
  const ImageMetadataUpdated(this.updatedImage);

  final UploadedImage updatedImage;

  @override
  List<Object?> get props => [updatedImage];
}

/// Search results state
class ImageSearchResults extends ImageUploadState {
  const ImageSearchResults({required this.results, this.query, this.tags});

  final List<UploadedImage> results;
  final String? query;
  final List<String>? tags;

  @override
  List<Object?> get props => [results, query, tags];
}

/// Error state
class ImageUploadError extends ImageUploadState {
  const ImageUploadError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
