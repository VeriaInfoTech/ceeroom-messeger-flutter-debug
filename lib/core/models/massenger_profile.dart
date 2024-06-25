import 'package:CeeRoom/core/models/call_model.dart';
import 'package:CeeRoom/core/models/chat_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';

class MessengerProfile {
  final ContactModel? profile;
  final List<ChatModel>? chat;
  final List<CallModel>? call;
  final List<ContactModel>? contact;

  final List<int>? userChat;
  // final Map<String, dynamic>? userChat;

  MessengerProfile({
    this.profile,
    this.chat,
    this.call,
    this.contact,
    this.userChat,
  });

  factory MessengerProfile.fromJson(Map<String, dynamic> json) =>
      MessengerProfile(
        profile: json["profile"] == null
            ? null
            : ContactModel.fromJson(json["profile"]),
        chat: json["chat"] == null
            ? []
            : List<ChatModel>.from(
                json["chat"]!.map((x) => ChatModel.fromJson(x)),
              ),
        call: json["call"] == null
            ? []
            : List<CallModel>.from(
                json["call"]!.map((x) => CallModel.fromJson(x)),
              ),
        contact: json["contact"] == null
            ? []
            : List<ContactModel>.from(
                json["contact"]!.map((x) => ContactModel.fromJson(x)),
              ),
        // userChat: json['user_chat'],
        userChat: json['user_chat'] == null
            ? null
            : List<int>.from(
                json["user_chat"]!.map((x) => x),
              ),
      );
}
