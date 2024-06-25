
import 'dart:io';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/call/webrtc_single_call.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/main.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import 'app_shared_preferences.dart';

Future<void> navigateToCallScreen() async {
  String page;
  Map<String, dynamic> arguments;


  bool isSpeaker = false;
  AudioPlayer? player;

  final AppSharedPreferences pref = AppSharedPreferences();

  String? appLifeCycleState = await pref.getLifeCycleState();

  debugPrint("${await pref.getLifeCycleState()}");



  if (currentCall['type'] == 0) {
    if (currentCall['extra']['is_group_call']) {
      page = Routes.groupVoiceCall;
      arguments = {
        'call_id': currentCall['extra']['call_id'],
        'contacts': null,
        'gp_name': null,
      };
    } else {

      ///TODO => Kerloper => improve this
      // Kerloper => for any time that device is ios and app state is paused (for default call kit of ios)
      if(Platform.isIOS && appLifeCycleState! == 'paused'){
        final UserController userCtl = Get.put(UserController());
        final WebRTCSingleCall webrtcCall = WebRTCSingleCall();
        final RTCVideoRenderer localRenderer = RTCVideoRenderer();
        final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
        CallStatus callStatus = CallStatus.ringing;
        webrtcCall.connectToSocket(
          userCtl.user.accessToken!,
              () async {
            webrtcCall.onConnecting = () async {
              callStatus = CallStatus.connecting;
              await Helper.setSpeakerphoneOn(isSpeaker);
            };
            webrtcCall.onConnected = () {
              callStatus = CallStatus.connected;
            };
            //await Helper.setSpeakerphoneOn(isSpeaker);
            await localRenderer.initialize();
            await remoteRenderer.initialize();
            webrtcCall.onAddRemoteStream = ((stream) {
              remoteRenderer.srcObject = stream;
            });
            await webrtcCall.openUserMedia(
              localVideo: localRenderer,
              remoteVideo: remoteRenderer,
              isVideoCall: false,
            );
            if (currentCall['extra']['call_id']== null) {
              player = (await webrtcCall.playBeepRing()) as AudioPlayer?;
              webrtcCall.startCall(ContactModel(
                name: currentCall['nameCaller'],
                mobile: currentCall['handle'],
                avatar: currentCall['avatar'],
              ), 0);
            } else {
              webrtcCall.joinCall(currentCall['extra']['call_id']);
            }
          },
        );
      }

      page = Routes.voiceCall;
      arguments = {
        'contact': ContactModel(
          name: currentCall['nameCaller'],
          mobile: currentCall['handle'],
          avatar: currentCall['avatar'],
        ),
        'call_id': currentCall['extra']['call_id'],
      };
    }
  } else {
    if (currentCall['extra']['is_group_call']) {
      page = Routes.groupVideoCall;
      arguments = {
        'call_id': currentCall['extra']['call_id'],
        'contacts': null,
        'gp_name': null,
      };
    } else {
      page = Routes.videoCall;
      arguments = {
        'contact': ContactModel(
          name: currentCall['nameCaller'],
          mobile: currentCall['handle'],
          avatar: currentCall['avatar'],
        ),
        'call_id': currentCall['extra']['call_id'],
      };
    }
  }
  ///TODO => Kerloper => improve this
  // Kerloper => for any time that device is ios and app state is paused (for default call kit of ios)
  if(Platform.isIOS && currentCall['type'] == 0 && appLifeCycleState == 'paused' && !currentCall['extra']['is_group_call']){
    return;
  }else{
    Get.toNamed(
      page,
      arguments: arguments,
    );
  }
  // if(!Platform.isIOS || appLifeCycleState! != 'paused' || currentCall['type'] != 0) {
  //
  // }
}
