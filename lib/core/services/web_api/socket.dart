import 'dart:convert';

class SocketService {
  static const String replyChat = 'chat-reply';
  static const String startChat = 'chat-start';
  static const String updateChat = 'chat-update';
  static const String createGroup = 'group-create';
  static const String requestCall = 'call-request';
  static const String updateCall = 'call-update';

  static String jsonFormat({
    required String action,
    required Map<String, dynamic> data,
  }) {
    return jsonEncode(
      {
        "data": data,
        "action": action,
      },
    );
  }
}
