import 'package:CeeRoom/core/models/message_media_model.dart';

List<MessageModel> getAllMessages(data) =>
    data.map<MessageModel>((x) => MessageModel.fromJson(x)).toList();

class MessageModel {
  final String? type;
  final String? caption;
  List<int>? seen;
  final bool? isReply;
  final bool? isForward;
  final Map<String, dynamic>? source;
  final List<dynamic>? media;
  final String? text;
  final int? userId;
  final String? id;
  final int? timeSend;
  final bool notificationFlag;
  MessageMediaModel? mediaInfo;
  final bool isUploadMsg;

  String? fcStatus;

  /// used for firestore cloud message doc id
  String? docId;

  /// 0 pending
  /// 1 save successfully in db
  /// 2 error happened and not save in db
  int? status;

  MessageModel({
    this.type,
    this.caption,
    this.seen,
    this.isReply,
    this.isForward,
    this.source,
    this.media,
    this.text,
    this.userId,
    this.id,
    this.timeSend,
    this.status = 1,
    this.notificationFlag = true,
    this.docId,
    this.fcStatus,
    this.mediaInfo,
    this.isUploadMsg = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        type: json["type"],
        caption: json["caption"],
        seen: json["seen"] == null
            ? []
            : List<int>.from(json["seen"]!.map((x) => x)),
        isReply: json["is_reply"],
        isForward: json["is_forward"],
        // source: json["source"],
        media: json["media"] == null
            ? []
            : List<dynamic>.from(json["media"]!.map((x) => x)),
        text: json["text"],
        userId: json["user_id"],
        id: json["id"],
        timeSend: json['time_send'],
        docId: json['doc_id'],
        mediaInfo: json.containsKey('media_info') && json['media_info'] != null
            ? MessageMediaModel.fromJson(json['media_info'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "caption": caption,
        "seen": seen == null
            ? []
            : List<int>.from(
                seen!.map((x) => x),
              ),
        "is_reply": isReply ?? false,
        "is_forward": isForward ?? false,
        "source": {
          "data": true,
        },
        "media": media == null
            ? []
            : List<dynamic>.from(
                media!.map((x) => x),
              ),
        "text": text,
        "notification_flag": notificationFlag,
        "time_send": timeSend,
        "id": id,
        "user_id": userId,
        "doc_id": docId,
        "media_info": mediaInfo?.toJson(),
      };
}
