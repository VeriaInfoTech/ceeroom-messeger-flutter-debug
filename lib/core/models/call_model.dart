import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/models/group_member_model.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

List<CallModel> getAllCalls(data) =>
    data.map<CallModel>((x) => CallModel.fromJson(x)).toList();

class CallModel {
  final String? callId;
  final ContactModel? sender;
  final List<ContactModel>? receiver;
  final String? callType;
  final CallInformationModel? callInformation;
  final int? requestTime;
  final dynamic startTime;
  final dynamic endTime;
  final int? userId;
  final String? slug;
  final String? type;
  String? receiverMobiles;
  final int? timeCreate;
  final int? status;
  final ExtraModel? extra;
  final CallModel? lastObject;

  CallModel({
    this.callId,
    this.sender,
    this.receiver,
    this.callType,
    this.callInformation,
    this.requestTime,
    this.startTime,
    this.endTime,
    this.userId,
    this.slug,
    this.type,
    this.timeCreate,
    this.status,
    this.receiverMobiles,
    this.extra,
    this.lastObject,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      callId: json["call_id"],
      sender:
          json["sender"] == null ? null : ContactModel.fromJson(json["sender"]),
      receiver: json["receiver"] == null
          ? []
          : json["receiver"].runtimeType == String
              ? [
                  ContactModel(
                      mobile: json["receiver"],
                      name: "test",
                      timeCreated: 179097332)
                ]
              : List<ContactModel>.from(
                  json["receiver"]!.map((x) => ContactModel.fromJson(x)),
                ),
      callType: json["call_type"],
      callInformation: json["call_information"] == null
          ? null
          : CallInformationModel.fromJson(json["call_information"]),
      requestTime: json["request_time"],
      startTime: json["start_time"],
      endTime: json["end_time"],
      userId: json["user_id"],
      slug: json["slug"],
      type: json["type"],
      timeCreate: json["time_create"] ?? DateTime.now().millisecondsSinceEpoch,
      status: json["status"],
      extra: json["extra"] == null ? null : ExtraModel.fromJson(json["extra"]),
      lastObject: json['last_object'] == null
          ? null
          : CallModel.fromJson(json['last_object']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "call_id": callId,
      "type": type,
      "call_information": callInformation?.toJson(),
      "sender": sender?.toJson(),
      "call_type": callType,
      "extra": extra?.toJson(),
      "request_time": requestTime,
      "start_time": startTime,
      "end_time": endTime,
      "user_id": userId,
      "slug": slug,
      "time_create": timeCreate,
      "status": status,
      "receiver": receiverMobiles ??
          (receiver != null
              ? List<Map<String, dynamic>>.generate(
                  receiver!.length,
                  (index) => receiver![index].toJson(),
                )
              : null),
    };
  }

  CallModel copyWith({
    final String? callId,
    final ContactModel? sender,
    final List<ContactModel>? receiver,
    final String? callType,
    final CallInformationModel? callInformation,
    final int? requestTime,
    final dynamic startTime,
    final dynamic endTime,
    final int? userId,
    final String? slug,
    final String? type,
    final String? receiverMobiles,
    final int? timeCreate,
    final int? status,
    final ExtraModel? extra,
  }) {
    return CallModel(
      callId: callId ?? this.callId,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      callType: callType ?? this.callType,
      callInformation: callInformation ?? this.callInformation,
      requestTime: requestTime ?? this.requestTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userId: userId ?? this.userId,
      slug: slug ?? this.slug,
      type: type ?? this.type,
      receiverMobiles: receiverMobiles ?? this.receiverMobiles,
      timeCreate: timeCreate ?? this.timeCreate,
      status: status ?? this.status,
      extra: extra ?? this.extra,
    );
  }
}

class CallInformationModel {
  final String? callId;
  final ContactModel? caller;
  final int? callType;
  final String? callStatus;
  final bool isGroupCall;
  final bool? isOnlyData;

  CallInformationModel({
    this.callId,
    this.caller,
    this.callType,
    this.callStatus,
    this.isGroupCall = false,
    this.isOnlyData = false,
  });

  factory CallInformationModel.fromJson(Map<String, dynamic> json) =>
      CallInformationModel(
        callId: json["call_id"],
        caller: json["caller"] == null
            ? null
            : ContactModel.fromJson(json["caller"]),
        callType: json["call_type"],
        callStatus: json["call_status"],
        isGroupCall:
            json.containsKey('is_group_call') ? json["is_group_call"] : false,
        isOnlyData:
            json.containsKey('is_only_data') ? json['is_only_data'] : null,
      );

  Map<String, dynamic> toJson() => {
        "call_id": callId,
        "caller": caller?.toJson(),
        "call_type": callType,
        "call_status": callStatus,
        "is_group_call": isGroupCall,
        "is_only_data": isOnlyData,
      };

  CallInformationModel copyWith({
    final String? callId,
    final ContactModel? caller,
    final int? callType,
    final String? callStatus,
    final bool? isGroupCall,
  }) {
    return CallInformationModel(
      callId: callId ?? this.callId,
      caller: caller ?? this.caller,
      callType: callType ?? this.callType,
      callStatus: callStatus ?? this.callStatus,
      isGroupCall: isGroupCall ?? this.isGroupCall,
    );
  }
}

class ExtraModel {
  final String? offerSdp;
  final String? answerSdp;
  final List<Candidate>? callerCandidates;
  List<Candidate>? calleCandidates;
  final List<int>? users;
  final String? callRingStatus;
  final List<GroupMemberModel>? membersInfo;
  int? updateBy;
  final List<GpPeerConnectionModel>? gpPeerConnections;

  ExtraModel({
    this.offerSdp,
    this.answerSdp,
    this.callerCandidates,
    this.calleCandidates,
    this.users,
    this.callRingStatus,
    this.membersInfo,
    this.updateBy,
    this.gpPeerConnections,
  });

  factory ExtraModel.fromJson(Map<String, dynamic> json) => ExtraModel(
        offerSdp: json["offer_sdp"],
        answerSdp: json["answer_sdp"],
        callerCandidates: json["caller_candidates"] == null
            ? []
            : List<Candidate>.from(
                json["caller_candidates"]!.map(
                  (x) => Candidate.fromJson(x),
                ),
              ),
        calleCandidates: json["calle_candidates"] == null
            ? []
            : List<Candidate>.from(
                json["calle_candidates"]!.map(
                  (x) => Candidate.fromJson(x),
                ),
              ),
        users: List<int>.from(
          json["users"]!.map(
            (x) => x,
          ),
        ),
        callRingStatus: json.containsKey('call_ring_status')
            ? json["call_ring_status"]
            : null,
        membersInfo: json.containsKey('members_info')
            ? json["members_info"] != null
                ? List<GroupMemberModel>.from(
                    json["members_info"]!.map(
                      (x) => GroupMemberModel.fromJson(x),
                    ),
                  )
                : []
            : [],
        updateBy: json.containsKey('update_by') ? json["update_by"] : null,
        gpPeerConnections: json.containsKey('gp_peer_connection')
            ? List<GpPeerConnectionModel>.from(
                json["gp_peer_connection"]!.map(
                  (x) => GpPeerConnectionModel.fromJson(x),
                ),
              )
            : [],
      );

  Map<String, dynamic> toJson() {
    return {
      "call_ring_status": callRingStatus,
      "caller_candidates": callerCandidates == null
          ? []
          : List<dynamic>.from(callerCandidates!.map((x) => x.toJson())),
      "members_info": membersInfo == null
          ? []
          : List<dynamic>.from(membersInfo!.map((x) => x.toJson())),
      "offer_sdp": offerSdp,
      "answer_sdp": answerSdp,
      "users": users != null ? List<int>.from(users!.map((x) => x)) : [],
      "calle_candidates": calleCandidates == null
          ? []
          : List<dynamic>.from(calleCandidates!.map((x) => x.toJson())),
      "update_by": updateBy,
      "gp_peer_connection": gpPeerConnections == null
          ? []
          : List<dynamic>.from(gpPeerConnections!.map((x) => x.toJson())),
    };
  }

  ExtraModel copyWith({
    final String? offerSdp,
    final String? answerSdp,
    final List<Candidate>? callerCandidates,
    final List<Candidate>? calleCandidates,
    final List<int>? users,
    final String? callRingStatus,
    final List<GroupMemberModel>? membersInfo,
    final int? updateBy,
    final List<GpPeerConnectionModel>? gpPeerConnections,
  }) {
    return ExtraModel(
      offerSdp: offerSdp ?? this.offerSdp,
      answerSdp: answerSdp ?? this.answerSdp,
      callerCandidates: callerCandidates ?? this.callerCandidates,
      calleCandidates: calleCandidates ?? this.calleCandidates,
      users: users ?? this.users,
      callRingStatus: callRingStatus ?? this.callRingStatus,
      membersInfo: membersInfo ?? this.membersInfo,
      updateBy: updateBy ?? this.updateBy,
      gpPeerConnections: gpPeerConnections ?? this.gpPeerConnections,
    );
  }
}

class Candidate {
  final String? candidate;
  final String? sdpMid;
  final int? sdpMlineIndex;

  Candidate({
    this.candidate,
    this.sdpMid,
    this.sdpMlineIndex,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
        candidate: json["candidate"],
        sdpMid: json["sdp_mid"],
        sdpMlineIndex: json["sdp_mline_index"],
      );

  Map<String, dynamic> toJson() => {
        "candidate": candidate,
        "sdp_mid": sdpMid,
        "sdp_mline_index": sdpMlineIndex,
      };
}

class GpPeerConnectionModel {
  final int? userId;
  final RTCPeerConnection? pc;
  MediaStream? stream;
  final List<Candidate>? candidates;
  bool answerSet = false;
  int remoteCandidateLength = 0;
  String? between;
  ExtraModel? info;
  ContactModel? from;
  ContactModel? to;

  GpPeerConnectionModel({
    this.between,
    this.info,
    this.userId,
    this.pc,
    this.stream,
    this.candidates,
    this.from,
    this.to,
  });

  factory GpPeerConnectionModel.fromJson(Map<String, dynamic> json) =>
      GpPeerConnectionModel(
        from: json.containsKey('from') && json['from'] != null
            ? ContactModel.fromJson(json['from'])
            : null,
        to: json.containsKey('to') && json['to'] != null
            ? ContactModel.fromJson(json['to'])
            : null,
        between: json["between"],
        info: ExtraModel.fromJson(json["info"]),
      );

  Map<String, dynamic> toJson() => {
        "from": from?.toJson(),
        "to": to?.toJson(),
        "between": between,
        "info": info?.toJson(),
      };

  GpPeerConnectionModel copyWith({
    final String? between,
    final ExtraModel? info,
    final int? userId,
    final RTCPeerConnection? pc,
    final MediaStream? stream,
    final List<Candidate>? candidates,
    final ContactModel? from,
    final ContactModel? to,
  }) {
    return GpPeerConnectionModel(
      between: between ?? this.between,
      info: info ?? this.info,
      userId: userId ?? this.userId,
      pc: pc ?? this.pc,
      stream: stream ?? this.stream,
      candidates: candidates ?? this.candidates,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}
