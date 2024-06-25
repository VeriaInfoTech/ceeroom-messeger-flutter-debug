import 'dart:convert';

import 'package:CeeRoom/core/models/chat_model.dart';
import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/core/services/local_storage/user.dart';
import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:http/http.dart' as http;

class ChatApi {
  ApiHelper apiHelper = ApiHelper();

  Future? startChat(MessageModel message, int userId) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.startChat),
      body: json.encode(
        {
          "user_id": userId,
          "message": message.toJson(),
        },
      ),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }

  Future? getChats(String slug) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.getChats),
      body: json.encode({"slug": slug}),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }

  Future? replyChat({
    required String slug,
    required String conversationId,
    required MessageModel message,
    required int userId,
  }) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.replyChat),
      body: json.encode(
        {
          "slug": slug,
          "conversation_id": conversationId,
          "user_id": userId,
          "message": message.toJson(),
        },
      ),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }

  Future? updateChat(MessageModel message) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.updateChat),
      body: json.encode(message.toJson()),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }

  Future? createGroup(ChatModel chat) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.createGroup),
      body: json.encode(chat.createGroupToJson()),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }

  Future? downloadMedia(int fileId) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.downloadMedia),
      body: {
        "id": fileId.toString(),
      },
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return res;
  }
}
