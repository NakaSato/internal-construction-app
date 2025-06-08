import 'dart:io';

import 'package:equatable/equatable.dart';

/// Base class for image upload events
abstract class ImageUploadEvent extends Equatable {
  const ImageUploadEvent();

  @override
  List<Object?> get props => [];
}

/// Event to upload a single image
class UploadImageEvent extends ImageUploadEvent {
  const UploadImageEvent({
    required this.imageFile,
    this.description,
    this.tags,
  });

  final File imageFile;
  final String? description;
  final List<String>? tags;

  @override
  List<Object?> get props => [imageFile, description, tags];
}

/// Event to upload multiple images
class UploadMultipleImagesEvent extends ImageUploadEvent {
  const UploadMultipleImagesEvent({
    required this.imageFiles,
    this.description,
    this.tags,
  });

  final List<File> imageFiles;
  final String? description;
  final List<String>? tags;

  @override
  List<Object?> get props => [imageFiles, description, tags];
}

/// Event to load user's uploaded images
class LoadUserImagesEvent extends ImageUploadEvent {
  const LoadUserImagesEvent();
}

/// Event to delete an image
class DeleteImageEvent extends ImageUploadEvent {
  const DeleteImageEvent(this.imageId);

  final String imageId;

  @override
  List<Object?> get props => [imageId];
}

/// Event to update image metadata
class UpdateImageMetadataEvent extends ImageUploadEvent {
  const UpdateImageMetadataEvent({
    required this.imageId,
    this.description,
    this.tags,
  });

  final String imageId;
  final String? description;
  final List<String>? tags;

  @override
  List<Object?> get props => [imageId, description, tags];
}

/// Event to search images
class SearchImagesEvent extends ImageUploadEvent {
  const SearchImagesEvent({this.query, this.tags});

  final String? query;
  final List<String>? tags;

  @override
  List<Object?> get props => [query, tags];
}

/// Event to reset the state
class ResetImageUploadEvent extends ImageUploadEvent {
  const ResetImageUploadEvent();
}
