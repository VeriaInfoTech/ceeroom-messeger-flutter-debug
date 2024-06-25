import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/call/webrtc_single_call.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_call_button.dart';
import 'package:CeeRoom/widgets/app_count_up_timer.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:CeeRoom/widgets/call_button_container.dart';
import 'package:CeeRoom/widgets/call_gradient_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class VoiceCallScreen extends StatefulWidget {
  final ContactModel contact;
  final String? callId;

  const VoiceCallScreen({
    Key? key,
    required this.contact,
    required this.callId,
  }) : super(key: key);

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool isSpeaker = false;
  AudioPlayer? player;

  final UserController _userCtl = Get.put(UserController());
  final WebRTCSingleCall _webrtcCall = WebRTCSingleCall();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  CallStatus callStatus = CallStatus.ringing;
  late BuildContext _context;

  void _init() async {
    debugPrint("Kerloper => start init of voice call");
    _webrtcCall.connectToSocket(
      _userCtl.user.accessToken!,
      () async {
        _webrtcCall.onConnecting = () async {
          setState(() {
            callStatus = CallStatus.connecting;
          });
          // ####
          await Helper.setSpeakerphoneOn(isSpeaker);
        };
        _webrtcCall.onConnected = () {
          setState(() {
           callStatus = CallStatus.connected;
          });
        };
        // ####KERLOPER
        // await Helper.setSpeakerphoneOn(isSpeaker);
        // ####
        await _localRenderer.initialize();
        // ####
        await _remoteRenderer.initialize();
        // ####
        _webrtcCall.onAddRemoteStream = ((stream) {
          _remoteRenderer.srcObject = stream;
          setState(() {});
        });
        await _webrtcCall.openUserMedia(
          localVideo: _localRenderer,
          remoteVideo: _remoteRenderer,
          isVideoCall: false,
        );
        if (widget.callId == null) {
          player = await _webrtcCall.playBeepRing();
          _webrtcCall.startCall(widget.contact, 0);
        } else {
          _webrtcCall.joinCall(widget.callId!);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            _webrtcCall.endCall(endFromCallScreen: true);
            return true;
          },
          child: CallGradientScreen(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      SizedBox(height: ResponsiveUtil.ratio(_context, 130.0)),
                      CacheImage(widget.contact.avatar, size: 160.0),
                      SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
                      AppDynamicFontText(
                        text: widget.contact.name ?? Variable.stringVar.noName.tr,
                        style: TextStyle(
                          color: Variable.colorVar.darkGrayish,
                          fontSize: ResponsiveUtil.ratio(_context, 24.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
                      Text(
                        widget.contact.mobile ?? '',
                        style: TextStyle(
                          color: Variable.colorVar.gray,
                          fontSize: ResponsiveUtil.ratio(_context, 20.0),
                        ),
                      ),
                      if (callStatus == CallStatus.connecting) ...[
                        SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
                        AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              Variable.stringVar.connecting.tr,
                              speed: const Duration(milliseconds: 100),
                              textStyle: TextStyle(
                                fontSize: ResponsiveUtil.ratio(_context, 14.0),
                              ),
                            ),
                          ],
                          repeatForever: true,
                        )
                      ],
                      if (callStatus == CallStatus.connected) ...[
                        SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
                        const AppCountUpTimer(),
                      ],
                      SizedBox(height: ResponsiveUtil.ratio(_context, 300.0)),
                      CallButtonContainer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppCallButton(
                              onTap: () {
                                setState(() {
                                  if (isSpeaker == false) {
                                    isSpeaker = true;
                                    Helper.setSpeakerphoneOn(isSpeaker);
                                    player?.setVolume(1);
                                  } else {
                                    isSpeaker = false;
                                    Helper.setSpeakerphoneOn(isSpeaker);
                                    player?.setVolume(0.3);
                                  }
                                });
                              },
                              icon: Icons.volume_up_outlined,
                              color: isSpeaker
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.1),
                              iconColor: isSpeaker ? Colors.black : Colors.white,
                              iconSize: 24.0,
                            ),
                            SizedBox(width: ResponsiveUtil.ratio(_context, 62.0)),
                            AppCallButton(
                              onTap: () {
                                setState(() {
                                  _webrtcCall.toggleMicrophone();
                                });
                              },
                              image: Variable.imageVar.muteSound,
                              color: !_webrtcCall.isMicrophoneOn
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.1),
                              iconColor: !_webrtcCall.isMicrophoneOn
                                  ? Colors.red : Colors.white,
                              iconSize: 22.0,
                            ),
                            SizedBox(width: ResponsiveUtil.ratio(_context, 62.0)),
                            AppCallButton(
                              onTap: () {
                                _webrtcCall.endCall();
                              },
                              icon: Icons.call_end_rounded,
                              color: Colors.red,
                              iconColor: Colors.white,
                              iconSize: 32.0,
                            ),
                            SizedBox(width: ResponsiveUtil.ratio(_context, 40.0)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    _localRenderer.dispose();
    super.dispose();
  }
}
