import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermission() async {
  await Permission.microphone.request();
  await Permission.notification.request();
  await Permission.camera.request();
  await Permission.storage.request();
  // await Permission.accessMediaLocation.request();
  // await Permission.mediaLibrary.request();
  await Permission.manageExternalStorage.request();

  // Kerloper => for show call kit in lock mode android 14
  await FlutterCallkitIncoming.requestNotificationPermission({
    "rationaleMessagePermission":
    "Notification permission is required, to show notification.",
    "postNotificationMessageRequired":
    "Notification permission is required, Please allow notification permission from setting."
  });

}
