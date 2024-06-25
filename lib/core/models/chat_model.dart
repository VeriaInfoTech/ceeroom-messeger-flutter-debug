import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/models/group_profile_model.dart';
import 'package:CeeRoom/core/models/message_model.dart';

List<ChatModel> getAllChats(data) =>
    data.map<ChatModel>((x) => ChatModel.fromJson(x)).toList();

class ChatModel {
  final String? conversationId;
  final int? page;
  final int? size;
  final String? slug;
  final int? status;
  final int? timeCreate;
  final int? timeUpdate;
  final int? userId;
  final List<int>? users;
  final List<ContactModel>? profiles;
  final List<MessageModel>? message;
  final GroupProfileModel? profile;
  final MessageModel? createGroupMessage;
  final String? type;
  final int? unseenCount;

  ChatModel({
    this.conversationId,
    this.page,
    this.size,
    this.slug,
    this.status,
    this.timeCreate,
    this.timeUpdate,
    this.userId,
    this.users,
    this.profiles,
    this.message,
    this.profile,
    this.createGroupMessage,
    this.type,
    this.unseenCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        conversationId: json["conversation_id"],
        page: json["page"],
        size: json["size"],
        slug: json["slug"],
        status: json["status"],
        timeCreate: json["time_create"],
        timeUpdate: json["time_update"],
        userId: json["user_id"],
        type: json['type'],
        users: json["users"] == null
            ? []
            : List<int>.from(json["users"]!.map((x) => x)),
        profiles: json["profiles"] == null
            ? []
            : List<ContactModel>.from(
                json["profiles"]!.map(
                  (x) => ContactModel.fromJson(x),
                ),
              ),
        message: json["message"] == null
            ? []
            : List<MessageModel>.from(
                json["message"]!.map(
                  (x) => MessageModel.fromJson(x),
                ),
              ),
        profile: json['profile'] == null
            ? null
            : GroupProfileModel.fromJson(json['profile']),
        unseenCount:
            json.containsKey('unseen_count') ? json['unseen_count'] : null,
      );

  Map<String, dynamic> toJson() => {
        "conversation_id": conversationId,
        "page": page,
        "size": size,
        "slug": slug,
        "status": status,
        "time_create": timeCreate,
        "time_update": timeUpdate,
        "user_id": userId,
        "users": users == null
            ? []
            : List<dynamic>.from(
                users!.map((x) => x),
              ),
        "profiles": profiles == null
            ? []
            : List<dynamic>.from(profiles!.map((x) => x.toJson())),
        "message": message == null
            ? []
            : List<dynamic>.from(message!.map((x) => x.toJson())),
      };

  Map<String, dynamic> createGroupToJson() => {
        "user_id": users!.join(','),
        "profile": profile!.toJson(),
        "message": createGroupMessage!.toJson(),
      };
}
