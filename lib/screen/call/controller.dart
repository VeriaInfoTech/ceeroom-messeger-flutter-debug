import 'dart:convert';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/socket/socket_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/call_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/services/web_api/call_api.dart';
import 'package:CeeRoom/core/services/web_api/socket.dart';
import 'package:CeeRoom/utils/app_shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;

class VideoSDKController {
  CallModel? call;
  final UserController _userCtl = getx.Get.put(UserController());
  final CallApi _callApi = CallApi();
  AudioPlayer? player;
  late String roomId;
  final SocketController _socketCtl = SocketController();
  final AppSharedPreferences _pref = AppSharedPreferences();

  /// call type => 0: voice
  /// call type => 1: video
  Future<void> startCall({
    required int callType,
    required String mobile,
    required VoidCallback onSuccess,
  }) async {
    try {
      roomId = 'await createMeeting()';
      call = CallModel(
        callId: roomId,
        type: callType == 0 ? 'voice' : 'video',
        callInformation: CallInformationModel(
          callId: roomId,
          caller: ContactModel(
            name: _userCtl.user.name,
            mobile: _userCtl.user.mobile,
            avatar: _userCtl.user.avatar,
          ),
          callType: callType,
          callStatus: 'Missed',
          isOnlyData: true,
        ),
        receiverMobiles: mobile,
        extra: ExtraModel(
          // offerSdp: offer.sdp,
          // users: [
          //   _userCtl.user.id!,
          //   contact.id!,
          // ],
          callRingStatus: 'ringing',
        ),
      );
      await _callApi.requestCall(call!);
      onSuccess.call();
    } catch (error) {
      // showSnackBarMessage(message: error.toString(), context: context);
    }
  }

  Future<void> playBeepRing({double volume = 0.1}) async {
    player = AudioPlayer();
    await player!.play(AssetSource(Variable.audioVar.ring));
    player!.setVolume(volume);
    player!.setReleaseMode(ReleaseMode.loop);
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

  Future<void> stopBeepRing() async {
    player?.stop();
  }


  Future<void> openUserMedia({
    required RTCVideoRenderer localVideo,
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
  }

  void listenToRingStatus(String id) async {
    _socketCtl.connect((await _pref.getToken())!);
    _socketCtl.channel.stream.listen(
          (event) {
        Map<String, dynamic> resp = jsonDecode(event);
        print(resp);
        print("dssddsssd");
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
}
