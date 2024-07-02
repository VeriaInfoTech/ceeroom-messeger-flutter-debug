import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/socket/socket_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/call_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/services/web_api/call_api.dart';
import 'package:CeeRoom/core/services/web_api/socket.dart';
import 'package:CeeRoom/main.dart';
import 'package:CeeRoom/utils/app_shared_preferences.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:videosdk/videosdk.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class WebRTCSingleCall {
  final UserController _userCtl = getx.Get.put(UserController());
  AudioPlayer? player;
  final CallApi _callApi = CallApi();
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;
  int remoteCandidateLength = 0;
  CallModel? call;
  List<Candidate> candidates = [];
  bool answerSet = false;
  String? roomId;
  late VoidCallback onConnected;
  late VoidCallback onConnecting;
  late StreamStateCallback onConnectionClosed;
  String? whoAreYou;
  bool isMicrophoneOn = true;
  bool isCameraOn = true;
  bool isFrontCamera = true;
  late VoidCallback onSwitchCamera;
  final SocketController _socketCtl = SocketController();
  final AppSharedPreferences _pref = AppSharedPreferences();
  late ContactModel _contact;

  /// call type => 0: voice
  /// call type => 1: video
  Future<void> startCall(ContactModel contact, int callType) async {
    _contact = contact;
    whoAreYou = "caller";
    debugPrint('Create PeerConnection with configuration: $callConfiguration');
    peerConnection = await createPeerConnection(callConfiguration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('Got candidate: ${candidate.toMap()}');
      candidates.add(
        Candidate(
          candidate: candidate.candidate,
          sdpMid: candidate.sdpMid,
          sdpMlineIndex: candidate.sdpMLineIndex,
        ),
      );
    };

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection?.setLocalDescription(offer);

    roomId = generateRandomString(16);
    call = CallModel(
      callId: "call-id-$roomId",
      type: callType == 0 ? 'voice' : 'video',
      callInformation: CallInformationModel(
        callId: "call-id-$roomId",
        caller: ContactModel(
          name: _userCtl.user.name,
          mobile: _userCtl.user.mobile,
          avatar: _userCtl.user.avatar,
        ),
        callType: callType,
        callStatus: 'Missed',
        isOnlyData: true,
      ),
      receiverMobiles: contact.mobile,
      extra: ExtraModel(
        offerSdp: offer.sdp,
        users: [
          _userCtl.user.id!,
          contact.id!,
        ],
        callRingStatus: 'ringing',
      ),
    );

    ///TODO:check reason of use socket in call update in before
    // _socketCtl.channel.sink.add(
    //   SocketService.jsonFormat(
    //     action: SocketService.requestCall,
    //     data: call!.toJson(),
    //   ),
    // );
    _callApi.requestCall(call!);
    peerConnection?.onTrack = (RTCTrackEvent event) {
      debugPrint('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        debugPrint('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    Future.delayed(
      const Duration(seconds: 61),
      () {
        if (peerConnection?.connectionState !=
            RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          endCall();
        }
      },
    );

    _socketCtl.channel.stream.listen((event) async {
      Map<String, dynamic> resp = jsonDecode(event);
      switch (resp['action']) {
        case SocketService.updateCall:
          call = CallModel.fromJson(resp['data']);
          if (call!.callInformation!.callStatus == "Reject" ||
              call!.extra!.callRingStatus == "hangup") {
            endCall();
          }
          if (call!.extra!.answerSdp != null) {
            if (!answerSet) {
              answerSet = true;
              await peerConnection?.setRemoteDescription(
                RTCSessionDescription(call!.extra!.answerSdp!, 'answer'),
              );
            }
          }
          if (call!.extra!.calleCandidates!.length != remoteCandidateLength) {
            remoteCandidateLength = call!.extra!.calleCandidates!.length;
            call = call!.copyWith(
              extra: call!.extra!.copyWith(
                callerCandidates: candidates,
              ),
            );

            ///TODO:check reason of use socket in call update in before
            _socketCtl.channel.sink.add(
              SocketService.jsonFormat(
                action: SocketService.updateCall,
                data: call!.toJson(),
              ),
            );
            // _callApi.updateCall(call!);
            peerConnection?.addCandidate(
              RTCIceCandidate(
                call!.extra!.calleCandidates![remoteCandidateLength - 1]
                    .candidate,
                call!.extra!.calleCandidates![remoteCandidateLength - 1].sdpMid,
                call!.extra!.calleCandidates![remoteCandidateLength - 1]
                    .sdpMlineIndex,
              ),
            );
          }
          break;
      }
    });
  }

  /// call type => 0: voice
  /// call type => 1: video
  Future<void> startCallNew({
    required String callId,
    required ContactModel contact,
    required int callType,
    required Room? meeting,
  }) async {
    _contact = contact;
    call = CallModel(
      callId: callId,
      type: callType == 0 ? 'voice' : 'video',
      callInformation: CallInformationModel(
        callId: callId,
        caller: ContactModel(
          name: _userCtl.user.name,
          mobile: _userCtl.user.mobile,
          avatar: _userCtl.user.avatar,
        ),
        callType: callType,
        callStatus: 'Missed',
        isOnlyData: true,
      ),
      receiverMobiles: contact.mobile,
      extra: ExtraModel(
        // offerSdp: offer.sdp,
        users: [
          _userCtl.user.id!,
          contact.id!,
        ],
        callRingStatus: 'ringing',
      ),
    );
    await _callApi.requestCall(call!);
    _socketCtl.connect((await _pref.getToken())!);

    _socketCtl.channel.stream.listen((event) async {
      Map<String, dynamic> resp = jsonDecode(event);
      switch (resp['action']) {
        case SocketService.updateCall:
          call = CallModel.fromJson(resp['data']);
          if (call!.callInformation!.callStatus == "Reject" ||
              call!.extra!.callRingStatus == "hangup") {
            meeting?.end();
            newEndCall();
          }
      }
    });
  }

  Future<void> rejectCall({String? callId, bool isDeclined = false}) async {
    _socketCtl.connect((await _pref.getToken())!);
    try {
      call = await getCall(callId!);
    } catch (e) {
      debugPrint("Get Call For Clear DB");
      debugPrint("============================");
      debugPrint("Something went wrong: $e");
      debugPrint("============================");
    }
    call = call!.copyWith(
      callInformation: call!.callInformation!.copyWith(
        callStatus: 'Reject',
      ),
      extra: ExtraModel(
        users: call!.extra!.users,
      ),
    );

    ///TODO:check reason of use socket in call update in before
    _socketCtl.channel.sink.add(
      SocketService.jsonFormat(
        action: SocketService.updateCall,
        data: call!.toJson(),
      ),
    );
  }

  Future<void> joinCall(String callId) async {
    whoAreYou = "calle";
    call = await getCall(callId);
    if (call != null) {
      call = call!.copyWith(
        callInformation: call!.callInformation!.copyWith(
          callStatus: 'Accept',
        ),
      );

      ///TODO:check reason of use socket in call update in before
      _socketCtl.channel.sink.add(
        SocketService.jsonFormat(
          action: SocketService.updateCall,
          data: call!.toJson(),
        ),
      );
      // _callApi.updateCall(call!);
    } else {
      if (appWasClosed) {
        exit(0);
      } else {
        getx.Get.back();
      }
      return;
    }
    roomId = callId.split('-')[2];
    debugPrint('Create PeerConnection with configuration: $callConfiguration');
    peerConnection = await createPeerConnection(callConfiguration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    peerConnection?.onTrack = (RTCTrackEvent event) {
      debugPrint('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        debugPrint('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('Got candidate: ${candidate.toMap()}');
      candidates.add(
        Candidate(
          candidate: candidate.candidate,
          sdpMid: candidate.sdpMid,
          sdpMlineIndex: candidate.sdpMLineIndex,
        ),
      );
      call = call!.copyWith(
        extra: call!.extra!.copyWith(
          calleCandidates: candidates,
        ),
      );

      ///TODO:check reason of use socket in call update in before
      _socketCtl.channel.sink.add(
        SocketService.jsonFormat(
          action: SocketService.updateCall,
          data: call!.toJson(),
        ),
      );
      // _callApi.updateCall(call!);
    };
    String offer = call!.extra!.offerSdp!;
    await peerConnection?.setRemoteDescription(
      RTCSessionDescription(
        offer,
        'offer',
      ),
    );
    var answer = await peerConnection!.createAnswer();
    await peerConnection?.setLocalDescription(answer);

    call = call!.copyWith(
      extra: call!.extra!.copyWith(answerSdp: answer.sdp),
    );

    ///TODO:check reason of use socket in call update in before
    _socketCtl.channel.sink.add(
      SocketService.jsonFormat(
        action: SocketService.updateCall,
        data: call!.toJson(),
      ),
    );
    // _callApi.updateCall(call!);
    _socketCtl.channel.stream.listen((event) {
      Map<String, dynamic> resp = jsonDecode(event);
      switch (resp['action']) {
        case SocketService.updateCall:
          call = CallModel.fromJson(resp['data']);
          if (call!.extra!.callRingStatus == "hangup") {
            endCall();
          }
          if (call!.extra!.callerCandidates != null &&
              call!.extra!.callerCandidates!.isNotEmpty) {
            if (call!.extra!.callerCandidates!.length !=
                remoteCandidateLength) {
              remoteCandidateLength = call!.extra!.callerCandidates!.length;
              for (int i = 0; i < remoteCandidateLength; i++) {
                peerConnection?.addCandidate(
                  RTCIceCandidate(
                    call!.extra!.callerCandidates![i].candidate,
                    call!.extra!.callerCandidates![i].sdpMid,
                    call!.extra!.callerCandidates![i].sdpMlineIndex,
                  ),
                );
              }
            }
          }
      }
    });
  }

  Future<void> newEndCall({bool endFromCallScreen = false}) async {
    if (whoAreYou == 'caller') {
      stopBeepRing();
      disposePlayer();
    }
    changeRingStatusToHangUp();
    if (whoAreYou == 'calle' && appWasClosed) {
      exit(0);
    } else if (!endFromCallScreen) {
      getx.Get.back();
    } else {
      getx.Get.back();
    }

    ///TODO: kerloper => only for ios . add this logic for other calls
    if (Platform.isIOS) {
      FlutterCallkitIncoming.endAllCalls();
    }
  }

  Future<void> endCall({bool endFromCallScreen = false}) async {
    if (whoAreYou == 'caller') {
      stopBeepRing();
      disposePlayer();
    }
    if (peerConnection != null) {
      changeRingStatusToHangUp();
      localStream?.getTracks().forEach((track) => track.stop());
      remoteStream?.getTracks().forEach((track) => track.stop());
      peerConnection?.close();
      peerConnection = null;
      clearDB();
      localStream?.dispose();
      remoteStream?.dispose();
      if (whoAreYou == 'calle' && appWasClosed) {
        exit(0);
      } else if (!endFromCallScreen) {
        getx.Get.back();
      }
    } else {
      getx.Get.back();
    }

    ///TODO: kerloper => only for ios . add this logic for other calls
    if (Platform.isIOS) {
      FlutterCallkitIncoming.endAllCalls();
    }
  }

  Future<void> clearDB({String? callId, bool isDeclined = false}) async {
    whoAreYou ??= 'calle';
    if (callId != null) {
      _socketCtl.connect((await _pref.getToken())!);
      roomId = callId.split('-')[2];
      try {
        call = await getCall(callId);
      } catch (e) {
        debugPrint("Get Call For Clear DB");
        debugPrint("============================");
        debugPrint("Something went wrong: $e");
        debugPrint("============================");
      }
    }
    if (call != null && whoAreYou == 'calle') {
      if (isDeclined) {
        call = call!.copyWith(
          callInformation: call!.callInformation!.copyWith(
            callStatus: 'Reject',
          ),
          extra: ExtraModel(
            users: call!.extra!.users,
          ),
        );

        ///TODO:check reason of use socket in call update in before
        _socketCtl.channel.sink.add(
          SocketService.jsonFormat(
            action: SocketService.updateCall,
            data: call!.toJson(),
          ),
        );
        // _callApi.updateCall(call!);
      } else {
        call = call!.copyWith(
          extra: ExtraModel(),
        );

        ///TODO:check reason of use socket in call update in before
        _socketCtl.channel.sink.add(
          SocketService.jsonFormat(
            action: SocketService.updateCall,
            data: call!.toJson(),
          ),
        );
        // _callApi.updateCall(call!);
      }
    }
  }

  bool toggleMicrophone() {
    localStream?.getAudioTracks().forEach((track) {
      isMicrophoneOn ? track.enabled = false : track.enabled = true;
    });
    isMicrophoneOn = !isMicrophoneOn;

    return isMicrophoneOn;
  }

  bool toggleCamera() {
    localStream?.getVideoTracks().forEach((track) {
      isCameraOn ? track.enabled = false : track.enabled = true;
    });
    isCameraOn = !isCameraOn;

    return isCameraOn;
  }

  Future<void> switchCamera() async {
    await localStream?.dispose();

    final newStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': isFrontCamera ? 'user' : 'environment',
      },
    });

    isFrontCamera = !isFrontCamera;
    localStream = newStream;
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

  Future<AudioPlayer> playBeepRing({double volume = 0.1}) async {
    player = AudioPlayer();
    await player!.play(AssetSource(Variable.audioVar.ring));
    player!.setVolume(volume);
    player!.setReleaseMode(ReleaseMode.loop);
    return player!;
  }

  Future<void> stopBeepRing() async {
    player?.stop();
  }

  void disposePlayer() {
    if (player != null) {
      player?.dispose();
      player = null;
    }
  }

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

  // kerloper => for check hangup call from caller when this device is in ringing status
  void listenToRingStatus(String id) async {
    _socketCtl.connect((await _pref.getToken())!);
    _socketCtl.channel.stream.listen(
      (event) {
        Map<String, dynamic> resp = jsonDecode(event);
        switch (resp['action']) {
          case SocketService.updateCall:
            call = CallModel.fromJson(resp['data']);
            if (call!.extra!.callRingStatus == "hangup") {
              FlutterCallkitIncoming.endAllCalls();
            }
        }
      },
    );
  }

  void changeRingStatusToHangUp() async {
    if (whoAreYou == 'caller' && call!.sender == null) {
      call = call!.copyWith(
        callType: call!.type,
        sender: ContactModel(
          id: _userCtl.user.id,
          name: call!.callInformation!.caller!.name,
          mobile: call!.callInformation!.caller!.mobile,
        ),
        timeCreate: DateTime.now().millisecondsSinceEpoch,
        receiver: [
          _contact,
        ],
      );
      call!.receiverMobiles = null;
    }
    call = call!.copyWith(
      extra: call!.extra!.copyWith(
        callRingStatus: 'hangup',
      ),
    );
    print("fdfdfdfd");
    _socketCtl.connect((await _pref.getToken())!);

    ///TODO:check reason of use socket in call update in before
    _socketCtl.channel.sink.add(
      SocketService.jsonFormat(
        action: SocketService.updateCall,
        data: call!.toJson(),
      ),
    );
    // _callApi.updateCall(call!);
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection state change: $state');
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          endCall();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateNew:
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          if (whoAreYou == 'caller') {
            stopBeepRing();
          }
          onConnecting.call();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          onConnected.call();
          break;
      }
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      debugPrint("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      debugPrint('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE connection state change: $state');
    };
  }

  void connectToSocket(String token, VoidCallback onSuccess) {
    _socketCtl.connect(token).then((value) {
      onSuccess.call();
    });
  }
}
