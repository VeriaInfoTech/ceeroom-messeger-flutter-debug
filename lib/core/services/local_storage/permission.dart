

import 'package:get_storage/get_storage.dart';

class PermissionLocalStorage{

  static final permissionBox = GetStorage();

  static bool hasMicrophonePermission() {
    return permissionBox.read('microphone') != null;
  }

  static bool hasCameraPermission() {
    return permissionBox.read('camera') != null;
  }


  static storeMicrophonePermission(bool hasPermission) {
    permissionBox.write('microphone', hasPermission);
  }

  static storeCameraPermission(bool hasPermission) {
    permissionBox.write('camera', hasPermission);
  }

  static bool? getMicrophonePermission() {
    try {
      return hasMicrophonePermission()
          ? permissionBox.read('microphone')
          : false;
    } catch (_) {
      return false;
    }
  }

  static bool? getCameraPermission() {
    try {
      return hasCameraPermission()
          ? permissionBox.read('camera')
          : false;
    } catch (_) {
      return false;
    }
  }


}