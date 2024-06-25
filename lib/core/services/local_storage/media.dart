import 'dart:convert';

import 'package:CeeRoom/core/models/message_media_model.dart';
import 'package:get_storage/get_storage.dart';

class MediaLocalStorage {
  static final mediaBox = GetStorage();

  static bool hasData() {
    return mediaBox.read('media') != null;
  }

  static storeMedia(List<MessageMediaModel> medias) async{
    var mediasAsMap = medias.map((m) => m.storeLocalToJson()).toList();
    String jsonString = jsonEncode(mediasAsMap);
    await mediaBox.write('media', jsonString);
  }

  static List<MessageMediaModel> getMedias() {
    try {
      if (hasData()) {
        var result = mediaBox.read('media');
        dynamic jsonData = jsonDecode(result);
        final l = jsonData.map((m) => MessageMediaModel.fromJson(m)).toList();
        return l.cast<MessageMediaModel>();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }
}
