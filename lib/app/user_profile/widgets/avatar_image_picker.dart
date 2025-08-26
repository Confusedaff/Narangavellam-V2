import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AvatarImagePicker extends StatefulWidget {
  const AvatarImagePicker({
    this.compress = true,
    this.radius = 64,
    this.addButtonRadius = 18,
    this.placeholderSize = 54,
    this.withPlaceholder = true,
    this.onUpload,
    super.key,
    this.imageBytes,
  });

  final Uint8List? imageBytes;
  final void Function(Uint8List, File)? onUpload;
  final bool compress;
  final double radius;
  final double addButtonRadius;
  final double placeholderSize;
  final bool withPlaceholder;

  @override
  State<AvatarImagePicker> createState() => _AvatarImagePickerState();
}

class _AvatarImagePickerState extends State<AvatarImagePicker> {
  Uint8List? _localImageBytes;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: widget.compress ? 85 : null,
    );
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Avatar',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Avatar',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null) return;

    final file = File(cropped.path);
    final bytes = await file.readAsBytes();

    // Update state to reflect the new image
    setState(() {
      _localImageBytes = bytes;
    });

    widget.onUpload?.call(bytes, file);
  }

  @override
  Widget build(BuildContext context) {
    final image = _localImageBytes ?? widget.imageBytes;

    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey.shade500,
            backgroundImage: image == null ? null : MemoryImage(image),
            child: image != null
                ? null
                : widget.withPlaceholder
                    ? Icon(
                        Icons.person,
                        size: widget.placeholderSize,
                      )
                    : null,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: Colors.white,
                ),
              ),
              child: const Icon(
                Icons.add,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
