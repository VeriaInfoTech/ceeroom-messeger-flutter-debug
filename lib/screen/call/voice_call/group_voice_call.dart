import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/call/webrtc_group_call.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/call_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_call_button.dart';
import 'package:CeeRoom/widgets/app_count_up_timer.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/call_button_container.dart';
import 'package:CeeRoom/widgets/call_gradient_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class GroupVoiceCall extends StatefulWidget {
  final List<ContactModel>? members;
  final String? callId;
  final String? gpName;

  const GroupVoiceCall({
    super.key,
    this.members,
    this.callId,
    this.gpName,
  });

  @override
  State<GroupVoiceCall> createState() => _GroupVoiceCallState();
}

class _GroupVoiceCallState extends State<GroupVoiceCall> {
  bool isSpeaker = false;
  late BuildContext _context;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final UserController _userCtl = Get.put(UserController());
  final WebRTCGroupCall _webrtcCall = WebRTCGroupCall();
  final List<RTCVideoRenderer> _remoteRenderer = [];

  void _init() {
    _webrtcCall.connectToSocket(
      _userCtl.user.accessToken!,
      () async {
        await _localRenderer.initialize();
        _webrtcCall.onAddRemoteStream = ((stream) async {
          RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
          await remoteRenderer.initialize();
          remoteRenderer.srcObject = stream;
          _remoteRenderer.add(remoteRenderer);
          setState(() {});
        });
        await Helper.setSpeakerphoneOn(isSpeaker);

        await _webrtcCall.openUserMedia(
          localVideo: _localRenderer,
          isVideoCall: false,
        );
        if (widget.callId == null) {
          _webrtcCall.startCall(
            callType: 0,
            gpMembers: widget.members!,
            gpName: widget.gpName!,
          );
        } else {
          _webrtcCall.joinCall(callId: widget.callId!);
        }
      },
    );
    _webrtcCall.onAddNewUser = () {
      setState(() {});
    };
    _webrtcCall.onConnectionClosed = (stream) {
      final r = _remoteRenderer.firstWhere(
        (element) => element.srcObject == stream,
      );
      r.dispose();
      _remoteRenderer.remove(r);
      setState(() {});
    };
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
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.all(ResponsiveUtil.ratio(context, 8.0)),
                    child: Column(
                      children: [
                        const AppCountUpTimer(isVoiceCall: true),
                        SizedBox(height: ResponsiveUtil.ratio(context, 8.0)),
                        Expanded(
                          child: GridView.count(
                            physics: const BouncingScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.8 / 2.3,
                            crossAxisSpacing:
                                ResponsiveUtil.ratio(context, 8.0),
                            mainAxisSpacing:
                                ResponsiveUtil.ratio(context, 8.0),
                            children: [
                              GpPeerConnectionModel(
                                to: ContactModel(
                                  id: _userCtl.user.id,
                                  name: _userCtl.user.name,
                                  avatar: _userCtl.user.avatar,
                                  mobile: _userCtl.user.avatar,
                                ),
                                from: ContactModel(
                                  id: _userCtl.user.id,
                                  name: _userCtl.user.name,
                                  avatar: _userCtl.user.avatar,
                                  mobile: _userCtl.user.avatar,
                                ),
                              ),
                              ..._webrtcCall.gpPeerConnection
                            ]
                                .map(
                                  (e) => _anyCall(
                                    _userCtl.user.id == e.from!.id
                                        ? e.to!
                                        : e.from!,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(height: ResponsiveUtil.ratio(context, 8.0)),
                      ],
                    ),
                  ),
                ),
                // const AppCountUpTimer(isVoiceCall: true),
                // SizedBox(height: ResponsiveUtil.ratio(context, 8.0)),
                // Expanded(
                //   child: GridView.count(
                //     physics: const BouncingScrollPhysics(),
                //     crossAxisCount: 2,
                //     childAspectRatio: 1.8 / 2.3,
                //     crossAxisSpacing: ResponsiveUtil.ratio(context, 8.0),
                //     mainAxisSpacing: ResponsiveUtil.ratio(context, 8.0),
                //     children: [
                //       GpPeerConnectionModel(
                //         to: ContactModel(
                //           id: _userCtl.user.id,
                //           name: _userCtl.user.name,
                //           avatar: _userCtl.user.avatar,
                //           mobile: _userCtl.user.avatar,
                //         ),
                //         from: ContactModel(
                //           id: _userCtl.user.id,
                //           name: _userCtl.user.name,
                //           avatar: _userCtl.user.avatar,
                //           mobile: _userCtl.user.avatar,
                //         ),
                //       ),
                //       ..._webrtcCall.gpPeerConnection
                //     ]
                //         .map(
                //           (e) => _anyCall(
                //             _userCtl.user.id == e.from!.id ? e.to! : e.from!,
                //           ),
                //         )
                //         .toList(),
                //   ),
                // ),
                // SizedBox(height: ResponsiveUtil.ratio(context, 8.0)),
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
                            } else {
                              isSpeaker = false;
                              Helper.setSpeakerphoneOn(isSpeaker);
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _anyCall(ContactModel user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Variable.colorVar.mediumGray,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CacheImage(user.avatar, size: 52.0),
          SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
          AppDynamicFontText(
            text: user.name ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtil.ratio(_context, 16.0),
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    for (var element in _remoteRenderer) {
      element.dispose();
    }
    super.dispose();
  }
}
