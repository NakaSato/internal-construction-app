import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget for handling photo upload functionality in daily reports
class PhotoUploadWidget extends StatefulWidget {
  final List<XFile> images;
  final Function(List<XFile>) onImagesChanged;
  final bool isEnabled;

  const PhotoUploadWidget({super.key, required this.images, required this.onImagesChanged, this.isEnabled = true});

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image thumbnails
        if (widget.images.isNotEmpty) _buildImageThumbnails(),

        // Add photo buttons
        _buildPhotoButtons(),
      ],
    );
  }

  Widget _buildImageThumbnails() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: FileImage(File(widget.images[index].path)), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 4,
                right: 12,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotoButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.isEnabled ? () => _pickImage(ImageSource.camera) : null,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.isEnabled ? () => _pickImage(ImageSource.gallery) : null,
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        final updatedImages = List<XFile>.from(widget.images)..addAll(images);
        widget.onImagesChanged(updatedImages);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  void _removeImage(int index) {
    final updatedImages = List<XFile>.from(widget.images)..removeAt(index);
    widget.onImagesChanged(updatedImages);
  }
}
