import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class WakelockChannel {
  static const MethodChannel _channel = MethodChannel('wakelock_channel');

  static Future<void> toggle(bool enable) async {
    try {
      await _channel.invokeMethod('toggle', enable);
    } on PlatformException catch (e) {
      debugPrint("Failed to toggle wakelock: '${e.message}'.");
    }
  }
}
