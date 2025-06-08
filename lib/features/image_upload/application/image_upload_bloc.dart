import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/repositories/image_upload_repository.dart';
import 'image_upload_event.dart';
import 'image_upload_state.dart';

/// BLoC for managing image upload operations
@injectable
class ImageUploadBloc extends Bloc<ImageUploadEvent, ImageUploadState> {
  ImageUploadBloc(this._imageUploadRepository)
    : super(const ImageUploadInitial()) {
    on<UploadImageEvent>(_onUploadImage);
    on<UploadMultipleImagesEvent>(_onUploadMultipleImages);
    on<LoadUserImagesEvent>(_onLoadUserImages);
    on<DeleteImageEvent>(_onDeleteImage);
    on<UpdateImageMetadataEvent>(_onUpdateImageMetadata);
    on<SearchImagesEvent>(_onSearchImages);
    on<ResetImageUploadEvent>(_onResetImageUpload);
  }

  final ImageUploadRepository _imageUploadRepository;

  /// Handle single image upload
  Future<void> _onUploadImage(
    UploadImageEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    try {
      emit(const ImageUploadLoading(message: 'Uploading image...'));

      final uploadedImage = await _imageUploadRepository.uploadImage(
        imageFile: event.imageFile,
        description: event.description,
        tags: event.tags,
      );

      emit(ImageUploadSuccess(uploadedImage));
    } catch (e) {
      emit(ImageUploadError('Failed to upload image: ${e.toString()}'));
    }
  }

  /// Handle multiple images upload
  Future<void> _onUploadMultipleImages(
    UploadMultipleImagesEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    try {
      emit(const ImageUploadLoading(message: 'Uploading images...'));

      final uploadedImages = await _imageUploadRepository.uploadMultipleImages(
        imageFiles: event.imageFiles,
        description: event.description,
        tags: event.tags,
      );

      emit(MultipleImagesUploadSuccess(uploadedImages));
    } catch (e) {
      emit(ImageUploadError('Failed to upload images: ${e.toString()}'));
    }
  }

  /// Handle loading user images
  Future<void> _onLoadUserImages(
    LoadUserImagesEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    try {
      emit(const ImageUploadLoading(message: 'Loading images...'));

      final images = await _imageUploadRepository.getUserImages();

      emit(ImagesLoaded(images));
    } catch (e) {
      emit(ImageUploadError('Failed to load images: ${e.toString()}'));
    }
  }

  /// Handle image deletion
  Future<void> _onDeleteImage(
    DeleteImageEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    try {
      emit(const ImageUploadLoading(message: 'Deleting image...'));

      await _imageUploadRepository.deleteImage(event.imageId);

      emit(ImageDeleted(event.imageId));

      // Reload images after deletion
      add(const LoadUserImagesEvent());
    } catch (e) {
      emit(ImageUploadError('Failed to delete image: ${e.toString()}'));
    }
  }

  /// Handle image metadata update
  Future<void> _onUpdateImageMetadata(
    UpdateImageMetadataEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    try {
      emit(const ImageUploadLoading(message: 'Updating image...'));

      final updatedImage = await _imageUploadRepository.updateImageMetadata(
        id: event.imageId,
        description: event.description,
        tags: event.tags,
      );

      emit(ImageMetadataUpdated(updatedImage));
    } catch (e) {
      emit(ImageUploadError('Failed to update image: ${e.toString()}'));
    }
  }

  /// Handle image search
  Future<void> _onSearchImages(
    SearchImagesEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    try {
      emit(const ImageUploadLoading(message: 'Searching images...'));

      final results = await _imageUploadRepository.searchImages(
        query: event.query,
        tags: event.tags,
      );

      emit(
        ImageSearchResults(
          results: results,
          query: event.query,
          tags: event.tags,
        ),
      );
    } catch (e) {
      emit(ImageUploadError('Failed to search images: ${e.toString()}'));
    }
  }

  /// Handle state reset
  Future<void> _onResetImageUpload(
    ResetImageUploadEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    emit(const ImageUploadInitial());
  }
}
