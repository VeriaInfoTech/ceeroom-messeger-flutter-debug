import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const imageGallery = "image-gallery";
const imageCamera = "image-camera";
const videoCamera = "video-camera";
const videoGallery = "video-galley";
const file = "file";

Future mediaPicker(
  BuildContext context,
  String pickerType, {
  bool multiSelect = false,
  FileType type = FileType.any,
}) async {
  XFile? imageFile;
  XFile? cameraImageFile;
  XFile? videoFile;
  FilePickerResult? filePickerResult;

  switch (pickerType) {
    case imageGallery:
      imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      return imageFile;

    case imageCamera:
      cameraImageFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      return cameraImageFile;

    case videoCamera:
      videoFile = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      return videoFile;

    case videoGallery:
      videoFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      return videoFile;

    case file:
      filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: multiSelect,
        type: type,
      );
      return filePickerResult;
  }
}
