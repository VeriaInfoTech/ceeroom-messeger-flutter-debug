import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/call/webrtc_single_call.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_call_button.dart';
import 'package:CeeRoom/widgets/app_count_up_timer.dart';
import 'package:CeeRoom/widgets/call_button_container.dart';
import 'package:CeeRoom/widgets/wake_lock.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class VideoCallScreen extends StatefulWidget {
  final ContactModel contact;
  final String? callId;

  const VideoCallScreen({
    Key? key,
    required this.contact,
    required this.callId,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isSpeaker = false;
  AudioPlayer? player;
  final UserController _userCtl = Get.put(UserController());
  final WebRTCSingleCall _webrtcCall = WebRTCSingleCall();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Offset _offset = const Offset(0.0, 0.0);
  late Size _screenSize;
  CallStatus callStatus = CallStatus.ringing;
  bool cameraEnabled = false;
  late BuildContext _context;

  void _init() async {
    debugPrint("Kerloper => start init of video call");
    await WakelockChannel.toggle(true);

    await _localRenderer.initialize();
    _webrtcCall.connectToSocket(
      _userCtl.user.accessToken!,
      () async {
        _webrtcCall.onConnecting = () {
          setState(() {
            callStatus = CallStatus.connecting;
          });
        };
        _webrtcCall.onConnected = () {
          setState(() {
            callStatus = CallStatus.connected;
          });
        };
        await Helper.setSpeakerphoneOn(isSpeaker);

        await _remoteRenderer.initialize();
        _webrtcCall.onAddRemoteStream = ((stream) {
          _remoteRenderer.srcObject = stream;
          setState(() {});
        });
        _webrtcCall.onSwitchCamera = () {
          setState(() {});
        };
        await _webrtcCall.openUserMedia(
          localVideo: _localRenderer,
          remoteVideo: _remoteRenderer,
          isVideoCall: true,
        );
        await Helper.setSpeakerphoneOn(true);
        setState(() {});
        if (widget.callId == null) {
          player = await _webrtcCall.playBeepRing();
          _webrtcCall.startCall(widget.contact, 1);
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
  void didChangeDependencies() {
    _screenSize = MediaQuery.of(context).size;
    _offset = Offset(_screenSize.width - 200, _screenSize.height - 400);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          _webrtcCall.endCall(endFromCallScreen: true);
          await WakelockChannel.toggle(false);
          return true;
        },
        child: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: RTCVideoView(
                  mirror:true,
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
              if (callStatus == CallStatus.connecting) ...[
                SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
                Positioned(
                  top: ResponsiveUtil.ratio(_context, 55.0),
                  left: ResponsiveUtil.ratio(_context, 145.0),
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          Variable.stringVar.connecting.tr,
                          textStyle: TextStyle(
                            fontSize: ResponsiveUtil.ratio(_context, 16.0),
                            color: Colors.white,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      repeatForever: true,
                    ),
                  ),
                )
              ],
              callStatus == CallStatus.connected
                  ? Column(
                      children: [
                        SizedBox(height: ResponsiveUtil.ratio(_context, 40.0)),
                        const Center(
                          child: AppCountUpTimer(isVoiceCall: false),
                        ),
                      ],
                    )
                  : const SizedBox(),
              Positioned(
                top: ResponsiveUtil.ratio(_context, _offset.dy),
                left: ResponsiveUtil.ratio(_context, _offset.dx),
                child: Container(
                  width: ResponsiveUtil.ratio(_context, 150.0),
                  height: ResponsiveUtil.ratio(_context, 180.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtil.ratio(_context, 20.0),
                    ),
                  ),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _offset += details.delta;
                        if (_offset.dx < 0) _offset = Offset(0, _offset.dy);
                        if (_offset.dy < 0) _offset = Offset(_offset.dx, 0);
                        if (_offset.dx > _screenSize.width - 150) {
                          _offset = Offset(_screenSize.width - 150, _offset.dy);
                        }
                        if (_offset.dy > _screenSize.height - 200) {
                          _offset =
                              Offset(_offset.dx, _screenSize.height - 200);
                        }
                      });
                    },
                    child: RTCVideoView(
                      _localRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CallButtonContainer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppCallButton(
                        onTap: () {
                          setState(() {
                            _webrtcCall.toggleCamera();
                          });
                        },
                        icon: Icons.videocam_off_outlined,
                        color: !_webrtcCall.isCameraOn
                            ? Colors.white
                            : Colors.black.withOpacity(0.1),
                        iconColor:
                            !_webrtcCall.isCameraOn ? Colors.black : Colors.white,
                        // IC
                      ),
                      SizedBox(width: ResponsiveUtil.ratio(_context, 36.0)),
                      AppCallButton(
                        onTap: () {
                          setState(() {
                            if (isSpeaker == false) {
                              isSpeaker = true;
                              Helper.setSpeakerphoneOn(isSpeaker);
                              player!.setVolume(1);
                            } else {
                              isSpeaker = false;
                              Helper.setSpeakerphoneOn(isSpeaker);
                              player!.setVolume(0.3);
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
                      SizedBox(width: ResponsiveUtil.ratio(_context, 36.0)),
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
                      SizedBox(width: ResponsiveUtil.ratio(_context, 36.0)),
                      AppCallButton(
                        onTap: () async {
                          _webrtcCall.endCall();
                          await WakelockChannel.toggle(false);
                        },
                        icon: Icons.call_end_rounded,
                        color: Colors.red,
                        iconSize: 32.0,
                      ),
                      SizedBox(width: ResponsiveUtil.ratio(_context, 20.0)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
