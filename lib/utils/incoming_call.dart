import 'dart:io';

import 'package:CeeRoom/core/controllers/call/webrtc_single_call.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/services/fcm/firebase.dart';
import 'package:CeeRoom/main.dart';
import 'package:CeeRoom/utils/call_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// index-call-2
// show call dialog on ringing
Future<void> showIncomingCall(
  String callId,
  ContactModel caller,
  int callType,
  bool isGroupCall,
) async {

  /// TODO => Kerloper what is this? why? => for stop show duplicate call dialog
  if(callShowed){
    return;
  }
  final WebRTCSingleCall webrtc = WebRTCSingleCall();
  var id = const Uuid().v4();

  final params = CallKitParams(
    id: id,
    nameCaller: caller.name,
    avatar: caller.avatar,
    handle: caller.mobile,
    appName: "CeeRoom",
    type: callType,
    duration: 60000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    extra: {
      "is_group_call": isGroupCall,
      "call_id": callId,
    },
    missedCallNotification: const NotificationParams(
      showNotification: true,
      subtitle: 'Missed call',
      isShowCallback: false,
    ),
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#E1E1E1',
      actionColor: '#4CAF50',
      isShowFullLockedScreen: true,
    ),
    ios: const IOSParams(
      handleType: 'generic',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
  if(Platform.isAndroid){
    final call = await webrtc.getCall(callId);
    if (call == null || call.extra!.callRingStatus == 'hangup') {
      return;
    }
  }
  callShowed = true;

  // for show ringing screen in incoming call
  await FlutterCallkitIncoming.showCallkitIncoming(params);

  // for check hangup call from caller when this device is in ringing status
  /// TODO => Kerloper => this need so check in ios platform
  //if(Platform.isAndroid){
    WebRTCSingleCall().listenToRingStatus(callId);
  //}

  FlutterCallkitIncoming.onEvent.listen(
    (CallEvent? event) async {
      switch(event!.event){

        case Event.actionCallAccept:
          debugPrint("incoming_call : actionCallAccept");
          callShowed = false;
          await Future.delayed(
            const Duration(seconds: 1),
            () {
              if(Platform.isAndroid){
                FlutterCallkitIncoming.endAllCalls();
              }
            },
          );
          break;

        case Event.actionCallDecline :
          debugPrint("incoming_call : actionCallDecline");
          callShowed = false;
          if(Platform.isAndroid){
            FlutterCallkitIncoming.endAllCalls();
          }
          webrtc.clearDB(
            callId: callId,
            isDeclined: true,
          );
          break;

        case Event.actionDidUpdateDevicePushTokenVoip:
          debugPrint("incoming_call : actionDidUpdateDevicePushTokenVoip");
          // TODO: Handle this case.
          break;
        case Event.actionCallIncoming:
          debugPrint("incoming_call : actionCallIncoming");
          // TODO: Handle this case.
          break;
        case Event.actionCallStart:
          debugPrint("incoming_call : actionCallStart");
          // TODO: Handle this case.
          break;
        case Event.actionCallEnded:
          debugPrint("incoming_call : actionCallEnded ");
          break;
        case Event.actionCallTimeout:
          debugPrint("incoming_call : actionCallTimeout");
          // TODO: Handle this case.
          callShowed = false;
          break;
        case Event.actionCallCallback:
          debugPrint("incoming_call : actionCallCallback");
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleHold:
          debugPrint("incoming_call : actionCallToggleHold");
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleMute:
          debugPrint("incoming_call : actionCallToggleMute");
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleDmtf:
          debugPrint("incoming_call : actionCallToggleDmtf");
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleGroup:
          debugPrint("incoming_call : actionCallToggleGroup");
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleAudioSession:
          debugPrint("incoming_call : actionCallToggleAudioSession");
          // Kerloper => this condition in android is handled in life cycle check in main
          if(Platform.isIOS){
            checkActiveCalls();
          }
          break;
        case Event.actionCallCustom:
          debugPrint("incoming_call : actionCallCustom");
          // TODO: Handle this case.
          break;
      }

    }
  );
}

Future<dynamic> getCurrentCall() async {
  var calls = await FlutterCallkitIncoming.activeCalls();
  if (calls is List) {
    if (calls.isNotEmpty) {
      currentCall = calls[0];
      return calls[0];
    } else {
      return null;
    }
  }
}

Future<void> checkActiveCalls({bool isFromStartApp = false}) async {
  var currentCall = await getCurrentCall();
  Future.delayed(
    const Duration(seconds: 1),
    () {
      if (currentCall != null) {
        appWasClosed = isFromStartApp;
        if (!appWasClosed) {
          if(Platform.isAndroid) {
            FlutterCallkitIncoming.endAllCalls();
          }

          debugPrint("State is  ");

          debugPrint("Kerloper log => go to call screen page.");
          navigateToCallScreen();
        }
      }
    },
  );
}
