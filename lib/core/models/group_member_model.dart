import 'package:flutter_webrtc/flutter_webrtc.dart';

class GroupMemberModel {
  final int? memberId;
  final String? offer;
  RTCVideoRenderer? stream;
  RTCPeerConnection? pc;

  GroupMemberModel({
    this.offer,
    this.memberId,
    this.stream,
    this.pc,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) => GroupMemberModel(
    offer: json["offer"],
    memberId: json["member_id"],
  );

  Map<String, dynamic> toJson() => {
    "offer": offer,
    "member_id": memberId,
  };
}
