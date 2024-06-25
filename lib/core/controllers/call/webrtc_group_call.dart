import 'dart:convert';
import 'dart:io';

import 'package:CeeRoom/core/controllers/call/webrtc_single_call.dart';
import 'package:CeeRoom/core/controllers/socket/socket_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/call_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/models/group_member_model.dart';
import 'package:CeeRoom/core/services/web_api/call_api.dart';
import 'package:CeeRoom/core/services/web_api/socket.dart';
import 'package:CeeRoom/main.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;

class WebRTCGroupCall {
  final UserController _userCtl = getx.Get.put(UserController());
  CallModel? call;
  bool isMicrophoneOn = true;
  final SocketController _socketCtl = SocketController();
  int onlineGpMembers = 1;
  List<GpPeerConnectionModel> gpPeerConnection = [];
  late VoidCallback onAddNewUser;
  final CallApi _callApi = CallApi();
  StreamStateCallback? onAddRemoteStream;
  MediaStream? localStream;
  late StreamStateCallback onConnectionClosed;
  bool isCameraOn = true;

  Future<CallModel?> getCall(String callId) async {
    try {
      final resp = await _callApi.requestCall(CallModel(callId: callId));
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        return CallModel.fromJson(api.data);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> startCall({
    required int callType,
    required List<ContactModel> gpMembers,
    required String gpName,
  }) async {
    List<String> memberPhones = List.generate(
      gpMembers.length,
      (index) => gpMembers[index].mobile!,
    );
    memberPhones.remove(_userCtl.user.mobile);
    List<int> memberIds = List.generate(
      gpMembers.length,
      (index) => gpMembers[index].id!,
    );
    final roomId = generateRandomString(16);
    call = CallModel(
      callId: "call-id-$roomId",
      type: callType == 0 ? 'voice' : 'video',
      callInformation: CallInformationModel(
        callId: "call-id-$roomId",
        caller: ContactModel(
          name: gpName,
          mobile: _userCtl.user.mobile,
        ),
        callType: callType,
        callStatus: 'Missed',
        isGroupCall: true,
        isOnlyData: true,
      ),
      receiverMobiles: memberPhones.join(','),
      extra: ExtraModel(
        users: memberIds,
        callRingStatus: 'ringing',
        membersInfo: [
          GroupMemberModel(
            memberId: _userCtl.user.id,
          ),
        ],
      ),
    );

    _socketCtl.channel.sink.add(
      SocketService.jsonFormat(
        action: SocketService.requestCall,
        data: call!.toJson(),
      ),
    );

    _socketCtl.channel.stream.listen((event) async {
      Map<String, dynamic> resp = jsonDecode(event);
      switch (resp['action']) {
        case SocketService.updateCall:
          call = CallModel.fromJson(resp['data']);
          if (onlineGpMembers != call!.extra!.membersInfo!.length) {
            if (onlineGpMembers > call!.extra!.membersInfo!.length) {
              onlineGpMembers = call!.extra!.membersInfo!.length;
              final p = gpPeerConnection.firstWhereOrNull(
                (element) => element.userId == call!.extra!.updateBy,
              );
              if (p != null) {
                _closeConnection(p);
              }
            } else {
              onlineGpMembers = call!.extra!.membersInfo!.length;
              await _createNewConnectionOnStart(
                call!.extra!.membersInfo![call!.extra!.membersInfo!.length - 1]
                    .memberId!,
              );
            }
            return;
          }
          if (call!.extra!.updateBy != null) {
            final l = [_userCtl.user.id, call!.extra!.updateBy];
            l.sort();
            if (call!.extra!.gpPeerConnections != null) {
              for (final pc in call!.extra!.gpPeerConnections!) {
                if (pc.between == l.join(',')) {
                  final con = gpPeerConnection.firstWhere(
                    (element) => element.userId == call!.extra!.updateBy,
                  );
                  if (pc.to != null) {
                    con.to = pc.to;
                  }
                  if (pc.info!.answerSdp != null) {
                    if (!con.answerSet) {
                      con.answerSet = true;
                      await con.pc!.setRemoteDescription(
                        RTCSessionDescription(pc.info!.answerSdp!, 'answer'),
                      );
                    }
                  }

                  if (pc.info!.calleCandidates!.length !=
                      con.remoteCandidateLength) {
                    con.remoteCandidateLength =
                        pc.info!.calleCandidates!.length;

                    pc.info = pc.info!.copyWith(
                      callerCandidates: con.candidates,
                    );
                    con.pc!.addCandidate(
                      RTCIceCandidate(
                        pc.info!.calleCandidates![con.remoteCandidateLength - 1]
                            .candidate,
                        pc.info!.calleCandidates![con.remoteCandidateLength - 1]
                            .sdpMid,
                        pc.info!.calleCandidates![con.remoteCandidateLength - 1]
                            .sdpMlineIndex,
                      ),
                    );

                    call = call!.copyWith(
                      extra: call!.extra!.copyWith(
                        updateBy: _userCtl.user.id,
                        gpPeerConnections: call!.extra!.gpPeerConnections!,
                      ),
                    );

                    _socketCtl.channel.sink.add(
                      SocketService.jsonFormat(
                        action: SocketService.updateCall,
                        data: call!.toJson(),
                      ),
                    );
                  }
                }
              }
            }
          }
          break;
      }
    });
  }

  Future<void> joinCall({required String callId}) async {
    call = await getCall(callId);
    if (call != null) {
      call = call!.copyWith(
        extra: call!.extra!.copyWith(
          updateBy: _userCtl.user.id,
          membersInfo: [
            ...call!.extra!.membersInfo!,
            GroupMemberModel(
              memberId: _userCtl.user.id,
            ),
          ],
        ),
      );
      onlineGpMembers = call!.extra!.membersInfo!.length;
      _socketCtl.channel.sink.add(
        SocketService.jsonFormat(
          action: SocketService.updateCall,
          data: call!.toJson(),
        ),
      );
    } else {
      if (appWasClosed) {
        exit(0);
      } else {
        getx.Get.back();
      }
      return;
    }

    _socketCtl.channel.stream.listen((event) async {
      Map<String, dynamic> resp = jsonDecode(event);
      switch (resp['action']) {
        case SocketService.updateCall:
          call = CallModel.fromJson(resp['data']);
          if (onlineGpMembers != call!.extra!.membersInfo!.length) {
            if (onlineGpMembers > call!.extra!.membersInfo!.length) {
              final p = gpPeerConnection.firstWhereOrNull(
                (element) => element.userId == call!.extra!.updateBy,
              );
              if (p != null) {
                await _closeConnection(p);
              }
            } else {
              onlineGpMembers = call!.extra!.membersInfo!.length;
              await _createNewConnectionOnStart(
                call!.extra!.membersInfo![call!.extra!.membersInfo!.length - 1]
                    .memberId!,
              );
            }
            return;
          }
          if (call!.extra!.updateBy != null) {
            final l = [_userCtl.user.id, call!.extra!.updateBy];
            l.sort();
            if (call!.extra!.gpPeerConnections != null) {
              for (final pc in call!.extra!.gpPeerConnections!) {
                if (pc.between == l.join(',')) {
                  int updateBy = call!.extra!.updateBy!;
                  if (!gpPeerConnection.any(
                    (element) => element.userId == call!.extra!.updateBy,
                  )) {
                    await _createNewConnectionOnJoin(
                      call!.extra!.updateBy!,
                      pc,
                      call!.extra!.gpPeerConnections!.indexOf(pc),
                    );
                    return;
                  }
                  final con = gpPeerConnection.firstWhere(
                    (element) => element.userId == updateBy,
                  );

                  if (pc.info!.callerCandidates!.isNotEmpty &&
                      pc.info!.callerCandidates!.length !=
                          con.remoteCandidateLength) {
                    con.remoteCandidateLength =
                        pc.info!.callerCandidates!.length;
                    con.pc!.addCandidate(
                      RTCIceCandidate(
                        pc
                            .info!
                            .callerCandidates![con.remoteCandidateLength - 1]
                            .candidate,
                        pc
                            .info!
                            .callerCandidates![con.remoteCandidateLength - 1]
                            .sdpMid,
                        pc
                            .info!
                            .callerCandidates![con.remoteCandidateLength - 1]
                            .sdpMlineIndex,
                      ),
                    );
                    return;
                  }
                  if (pc.to != null) {
                    con.to = pc.to;
                  }
                  if (pc.info!.answerSdp != null) {
                    if (!con.answerSet) {
                      con.answerSet = true;
                      await con.pc!.setRemoteDescription(
                        RTCSessionDescription(pc.info!.answerSdp!, 'answer'),
                      );
                    }
                  }
                  if (pc.info!.calleCandidates!.length !=
                      con.remoteCandidateLength) {
                    con.remoteCandidateLength =
                        pc.info!.calleCandidates!.length;

                    pc.info = pc.info!.copyWith(
                      callerCandidates: con.candidates,
                    );
                    con.pc!.addCandidate(
                      RTCIceCandidate(
                        pc.info!.calleCandidates![con.remoteCandidateLength - 1]
                            .candidate,
                        pc.info!.calleCandidates![con.remoteCandidateLength - 1]
                            .sdpMid,
                        pc.info!.calleCandidates![con.remoteCandidateLength - 1]
                            .sdpMlineIndex,
                      ),
                    );

                    call = call!.copyWith(
                      extra: call!.extra!.copyWith(
                        updateBy: _userCtl.user.id,
                        gpPeerConnections: call!.extra!.gpPeerConnections!,
                      ),
                    );

                    _socketCtl.channel.sink.add(
                      SocketService.jsonFormat(
                        action: SocketService.updateCall,
                        data: call!.toJson(),
                      ),
                    );
                  }
                }
              }
            }
          }
          break;
      }
    });
  }

  Future<void> _createNewConnectionOnJoin(
    int userId,
    GpPeerConnectionModel gpPConnection,
    int index,
  ) async {
    RTCPeerConnection pc = await createPeerConnection(callConfiguration);
    MediaStream? remoteStream;
    List<Candidate> candidates = [];
    GpPeerConnectionModel? newGpConnection;

    pc.onAddStream = (MediaStream stream) {
      debugPrint("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
      newGpConnection?.stream = remoteStream;
    };

    localStream?.getTracks().forEach((track) {
      pc.addTrack(track, localStream!);
    });

    pc.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('Got candidate: ${candidate.toMap()}');
      candidates.add(
        Candidate(
          candidate: candidate.candidate,
          sdpMid: candidate.sdpMid,
          sdpMlineIndex: candidate.sdpMLineIndex,
        ),
      );
      if (call!.extra!.gpPeerConnections![index].info!.calleCandidates!.length <
          candidates.length) {
        call!.extra!.gpPeerConnections![index].info!.calleCandidates =
            candidates;
        call!.extra!.updateBy = _userCtl.user.id;
        _socketCtl.channel.sink.add(
          SocketService.jsonFormat(
            action: SocketService.updateCall,
            data: call!.toJson(),
          ),
        );
      }
    };

    await pc.setRemoteDescription(
      RTCSessionDescription(
        gpPConnection.info!.offerSdp,
        'offer',
      ),
    );

    var answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    newGpConnection = gpPConnection.copyWith(
      userId: userId,
      pc: pc,
      stream: remoteStream,
      to: ContactModel(
        id: _userCtl.user.id,
        name: _userCtl.user.name,
        mobile: _userCtl.user.mobile,
        avatar: _userCtl.user.avatar,
      ),
      info: gpPConnection.info!.copyWith(
        answerSdp: answer.sdp,
      ),
    );
    call!.extra!.gpPeerConnections!.remove(gpPConnection);

    call = call!.copyWith(
      extra: call!.extra!.copyWith(
        updateBy: _userCtl.user.id,
        gpPeerConnections: [
          ...call!.extra!.gpPeerConnections!,
          newGpConnection,
        ],
      ),
    );
    gpPeerConnection.add(newGpConnection);

    onAddNewUser.call();

    _socketCtl.channel.sink.add(
      SocketService.jsonFormat(
        action: SocketService.updateCall,
        data: call!.toJson(),
      ),
    );
  }

  Future<void> _createNewConnectionOnStart(int userId) async {
    RTCPeerConnection pc = await createPeerConnection(callConfiguration);
    MediaStream? remoteStream;
    List<Candidate> candidates = [];
    GpPeerConnectionModel? newPC;

    pc.onAddStream = (MediaStream stream) {
      debugPrint("Add remote stream");
      remoteStream = stream;
      newPC?.stream = remoteStream;
      onAddRemoteStream?.call(stream);
    };

    localStream?.getTracks().forEach((track) {
      pc.addTrack(track, localStream!);
    });

    pc.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('Got candidate: ${candidate.toMap()}');
      candidates.add(
        Candidate(
          candidate: candidate.candidate,
          sdpMid: candidate.sdpMid,
          sdpMlineIndex: candidate.sdpMLineIndex,
        ),
      );
    };

    RTCSessionDescription offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    pc.onTrack = (RTCTrackEvent event) {
      debugPrint('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        debugPrint('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
    final between = [_userCtl.user.id!, userId];
    between.sort();
    newPC = GpPeerConnectionModel(
      userId: userId,
      pc: pc,
      stream: remoteStream,
      candidates: candidates,
      between: between.join(','),
      from: ContactModel(
        id: _userCtl.user.id,
        name: _userCtl.user.name,
        mobile: _userCtl.user.mobile,
        avatar: _userCtl.user.avatar,
      ),
      info: ExtraModel(
        offerSdp: offer.sdp,
      ),
    );
    call = call!.copyWith(
      extra: call!.extra!.copyWith(
        updateBy: _userCtl.user.id,
        gpPeerConnections: [
          ...call!.extra!.gpPeerConnections ?? [],
          newPC,
        ],
      ),
    );
    gpPeerConnection.add(newPC);
    _socketCtl.channel.sink.add(
      SocketService.jsonFormat(
        action: SocketService.updateCall,
        data: call!.toJson(),
      ),
    );
  }

  Future<void> _closeConnection(GpPeerConnectionModel p) async {
    p.stream?.getTracks().forEach((track) => track.stop());
    p.pc?.close();
    p.stream?.dispose();
    final l = [_userCtl.user.id, p.userId];
    l.sort();
    final gpBetween = call!.extra!.gpPeerConnections!;
    gpBetween.removeWhere((element) => element.between == l.join(','));
    call = call!.copyWith(
      extra: call!.extra!.copyWith(
        updateBy: _userCtl.user.id,
        gpPeerConnections: gpBetween,
      ),
    );
    _socketCtl.channel.sink.add(
      SocketService.jsonFormat(
        action: SocketService.updateCall,
        data: call!.toJson(),
      ),
    );

    gpPeerConnection.remove(p);

    onConnectionClosed(p.stream!);
  }

  Future<void> _unRegisterUser() async {
    final callMembers = call!.extra!.membersInfo!;
    callMembers.removeWhere((element) => element.memberId == _userCtl.user.id);
    call = call!.copyWith(
      extra: call!.extra!.copyWith(
        updateBy: _userCtl.user.id,
        membersInfo: callMembers,
      ),
    );
    _socketCtl.channel.sink.add(
      SocketService.jsonFormat(
        action: SocketService.updateCall,
        data: call!.toJson(),
      ),
    );
  }

  Future<void> endCall({bool endFromCallScreen = false}) async {
    localStream?.getTracks().forEach((track) => track.stop());
    localStream?.dispose();
    for (final pc in gpPeerConnection) {
      pc.stream?.getTracks().forEach((track) => track.stop());
      pc.pc?.close();
      pc.stream?.dispose();
    }
    await _unRegisterUser();
    _socketCtl.channel.sink.close();
    if (appWasClosed) {
      exit(0);
    } else if (!endFromCallScreen) {
      getx.Get.back();
    }
  }

  bool toggleMicrophone() {
    localStream?.getAudioTracks().forEach((track) {
      isMicrophoneOn ? track.enabled = false : track.enabled = true;
    });
    isMicrophoneOn = !isMicrophoneOn;

    return isMicrophoneOn;
  }

  void connectToSocket(String token, VoidCallback onSuccess) {
    _socketCtl.connect(token).then((value) {
      onSuccess.call();
    });
  }

  Future<void> openUserMedia({
    required RTCVideoRenderer localVideo,
    RTCVideoRenderer? remoteVideo,
    required bool isVideoCall,
  }) async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': isVideoCall
          ? {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };
    var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localVideo.srcObject = stream;
    localStream = stream;
  }

  bool toggleCamera() {
    localStream?.getVideoTracks().forEach((track) {
      isCameraOn ? track.enabled = false : track.enabled = true;
    });
    isCameraOn = !isCameraOn;

    return isCameraOn;
  }
}
