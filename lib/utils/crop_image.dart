import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

Future<CroppedFile?> cropImage(String path) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: path,
    // compressFormat: ImageCompressFormat.png,
    compressQuality: 100,
    aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: Variable.stringVar.editPhoto.tr,
        toolbarColor: Variable.colorVar.lightBgGradient,
        statusBarColor: Variable.colorVar.lightBgGradient,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
        showCropGrid: false,
      ),
      IOSUiSettings(
        title: Variable.stringVar.editPhoto.tr,
        showCancelConfirmationDialog: true,
        resetAspectRatioEnabled: false,
        aspectRatioLockEnabled: true,
        aspectRatioLockDimensionSwapEnabled: true,
        doneButtonTitle: Variable.stringVar.done.tr,
        cancelButtonTitle: Variable.stringVar.cancel.tr,
        aspectRatioPickerButtonHidden: true,

      ),
    ],
  );
  return croppedFile;
}
