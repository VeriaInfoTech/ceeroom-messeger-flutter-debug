import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/call/webrtc_single_call.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/screen/call/api.dart';
import 'package:CeeRoom/screen/call/one_to_one_meeting_container.dart';
import 'package:CeeRoom/screen/call/toast.dart';
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
import 'package:videosdk/videosdk.dart';

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

  RTCVideoRenderer? cameraRenderer;
  CustomTrack? cameraTrack;
  String _token = "";
  Room? meeting;
  bool _joined = false;
  bool _moreThan2Participants = false;
  String recordingState = "RECORDING_STOPPED";
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;
  bool fullScreen = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initCameraPreview() async {
    await _localRenderer.initialize();
    await _webrtcCall.openUserMedia(
      localVideo: _localRenderer,
      remoteVideo: _remoteRenderer,
      isVideoCall: true,
    );
    setState(() {});
    // CustomTrack track = await VideoSDK.createCameraVideoTrack();
    // RTCVideoRenderer render = RTCVideoRenderer();
    // await render.initialize();
    // render.setSrcObject(
    //     stream: track.mediaStream,
    //     trackId: track.mediaStream.getVideoTracks().first.id);
    // setState(() {
    //   cameraTrack = track;
    //   cameraRenderer = render;
    // });
  }

  void disposeCameraPreview() {
    cameraTrack?.dispose();
    setState(() {
      cameraRenderer = null;
      cameraTrack = null;
    });
  }

  Future<void> createAndJoinMeeting() async {
    try {
      _webrtcCall.whoAreYou = 'caller';
      var _meetingID = await createMeeting(_token);
      if (mounted) {
        await _webrtcCall.startCallNew(
          callType: 1,
          callId: _meetingID,
          contact: widget.contact,
          meeting: meeting,
        );
        Room room = VideoSDK.createRoom(
          roomId: _meetingID,
          token: _token,
          displayName: _userCtl.user.name!,
          micEnabled: true,
          camEnabled: true,
          maxResolution: 'hd',
          multiStream: false,
          defaultCameraIndex: 1,
          notification: const NotificationInfo(
            title: "Video SDK",
            message: "Video SDK is sharing screen in the meeting",
            icon: "notification_share", // drawable icon name
          ),
        );
        registerMeetingEvents(room);
        room.join();
        return;

        // // disposeCameraPreview();
        // if (callType == "GROUP") {
        //   // Navigator.push(
        //   //   context,
        //   //   MaterialPageRoute(
        //   //     builder: (context) => ConfereneceMeetingScreen(
        //   //       token: _token,
        //   //       meetingId: _meetingID,
        //   //       displayName: displayName,
        //   //       micEnabled: isMicOn,
        //   //       camEnabled: isCameraOn,
        //   //     ),
        //   //   ),
        //   // );
        // } else {
        //   await _webrtcCall.startCallNew(
        //     callType: 1,
        //     callId: _meetingID,
        //     contact: widget.contact,
        //   );
        //   Room room = VideoSDK.createRoom(
        //     roomId: _meetingID,
        //     token: _token,
        //     displayName: _userCtl.user.name!,
        //     micEnabled: true,
        //     camEnabled: true,
        //     maxResolution: 'hd',
        //     multiStream: false,
        //     defaultCameraIndex: 1,
        //     notification: const NotificationInfo(
        //       title: "Video SDK",
        //       message: "Video SDK is sharing screen in the meeting",
        //       icon: "notification_share", // drawable icon name
        //     ),
        //   );
        //   registerMeetingEvents(room);
        //   room.join();
        //
        //   // Navigator.push(
        //   //   context,
        //   //   MaterialPageRoute(
        //   //     builder: (context) => OneToOneMeetingScreen(
        //   //       token: _token,
        //   //       meetingId: _meetingID,
        //   //       displayName: displayName,
        //   //       micEnabled: isMicOn,
        //   //       camEnabled: isCameraOn,
        //   //     ),
        //   //   ),
        //   // );
        // }
      }
    } catch (error) {
      showSnackBarMessage(message: error.toString(), context: context);
    }
  }

  Future<void> joinMeeting() async {
    _webrtcCall.whoAreYou = 'calle';
    var validMeeting = await validateMeeting(_token, widget.callId!);
    if (validMeeting) {
      if (mounted) {
        Room room = VideoSDK.createRoom(
          roomId: widget.callId!,
          token: _token,
          displayName: _userCtl.user.name!,
          micEnabled: true,
          camEnabled: true,
          maxResolution: 'hd',
          multiStream: false,
          defaultCameraIndex: 1,
          notification: const NotificationInfo(
            title: "Video SDK",
            message: "Video SDK is sharing screen in the meeting",
            icon: "notification_share", // drawable icon name
          ),
        );
        registerMeetingEvents(room);
        room.join();

        // disposeCameraPreview();
        // if (callType == "GROUP") {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ConfereneceMeetingScreen(
        //       token: _token,
        //       meetingId: meetingId,
        //       displayName: displayName,
        //       micEnabled: isMicOn,
        //       camEnabled: isCameraOn,
        //     ),
        //   ),
        // );
        // } else {
        // Room room = VideoSDK.createRoom(
        //   roomId: widget.callId!,
        //   token: _token,
        //   displayName: _userCtl.user.name!,
        //   micEnabled: true,
        //   camEnabled: true,
        //   maxResolution: 'hd',
        //   multiStream: false,
        //   defaultCameraIndex: 1,
        //   notification: const NotificationInfo(
        //     title: "Video SDK",
        //     message: "Video SDK is sharing screen in the meeting",
        //     icon: "notification_share", // drawable icon name
        //   ),
        // );
        // registerMeetingEvents(room);
        // room.join();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => OneToOneMeetingScreen(
        //       token: _token,
        //       meetingId: meetingId,
        //       displayName: displayName,
        //       micEnabled: isMicOn,
        //       camEnabled: isCameraOn,
        //     ),
        //   ),
        // );
        // }
      }
    } else {
      if (mounted) {
        showSnackBarMessage(message: "Invalid Meeting ID", context: context);
      }
    }
  }

  void registerMeetingEvents(Room _meeting) {
    // Called when joined in meeting
    _meeting.on(
      Events.participantJoined,
          (Participant participant) {
        _webrtcCall.stopBeepRing();
      },
    );
    _meeting.on(
      Events.roomJoined,
      () {
        if (_meeting.participants.length > 1) {
          setState(() {
            meeting = _meeting;
            _moreThan2Participants = true;
          });
        } else {
          setState(() {
            meeting = _meeting;
            _joined = true;
          });

          // subscribeToChatMessages(_meeting);
        }
      },
    );

    // Called when meeting is ended
    _meeting.on(Events.roomLeft, (String? errorMsg) {
      if (errorMsg != null) {
        showSnackBarMessage(
            message: "Meeting left due to $errorMsg !!", context: context);
      }
      Get.back();
    });

    // Called when recording is started
    _meeting.on(Events.recordingStateChanged, (String status) {
      showSnackBarMessage(
          message:
              "Meeting recording ${status == "RECORDING_STARTING" ? "is starting" : status == "RECORDING_STARTED" ? "started" : status == "RECORDING_STOPPING" ? "is stopping" : "stopped"}",
          context: context);

      setState(() {
        recordingState = status;
      });
    });

    // Called when stream is enabled
    _meeting.localParticipant.on(Events.streamEnabled, (Stream _stream) {
      if (_stream.kind == 'video') {
        setState(() {
          videoStream = _stream;
        });
      } else if (_stream.kind == 'audio') {
        setState(() {
          audioStream = _stream;
        });
      } else if (_stream.kind == 'share') {
        setState(() {
          shareStream = _stream;
        });
      }
    });

    // Called when stream is disabled
    _meeting.localParticipant.on(Events.streamDisabled, (Stream _stream) {
      if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    _meeting.on(Events.presenterChanged, (_activePresenterId) {
      Participant? activePresenterParticipant =
          _meeting.participants[_activePresenterId];

      // Get Share Stream
      Stream? _stream = activePresenterParticipant?.streams.values
          .singleWhere((e) => e.kind == "share");

      setState(() => remoteParticipantShareStream = _stream);
    });

    _meeting.on(
        Events.participantLeft,
        (participant) => {
              if (_moreThan2Participants)
                {
                  if (_meeting.participants.length < 2)
                    {
                      setState(() {
                        _joined = true;
                        _moreThan2Participants = false;
                      }),
                      // subscribeToChatMessages(_meeting),
                    }
                }
            });

    _meeting.on(
        Events.error,
        (error) => {
              showSnackBarMessage(
                  message: "${error['name']} :: ${error['message']}",
                  context: context)
            });
  }

  void _init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() => _token = token);
    });
    initCameraPreview();
    // return;
    if (widget.callId == null) {
      _webrtcCall.playBeepRing();
      createAndJoinMeeting();
    } else {
      joinMeeting();
    }
    return;
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
          return true;
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: !_joined
              ? Stack(
                  children: [
                    RTCVideoView(
                      _localRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CallButtonContainer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppCallButton(
                              onTap: () async {
                                Get.back();
                                _webrtcCall.newEndCall();
                                meeting?.end();
                                // await WakelockChannel.toggle(false);
                              },
                              icon: Icons.call_end_rounded,
                              color: Colors.red,
                              iconSize: 32.0,
                            ),
                            SizedBox(
                                width: ResponsiveUtil.ratio(_context, 36.0)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    const AppCountUpTimer(isVoiceCall: false),
                    const Divider(),
                    OneToOneMeetingContainer(
                      meeting: meeting!,
                      contact: widget.contact,
                    ),
                    // Column(
                    //   children: [
                    //     const Divider(),
                    //     AnimatedCrossFade(
                    //       duration: const Duration(milliseconds: 300),
                    //       crossFadeState: !fullScreen
                    //           ? CrossFadeState.showFirst
                    //           : CrossFadeState.showSecond,
                    //       secondChild: const SizedBox.shrink(),
                    //       firstChild: MeetingActionBar(
                    //         isMicEnabled: audioStream != null,
                    //         isCamEnabled: videoStream != null,
                    //         isScreenShareEnabled: shareStream != null,
                    //         recordingState: recordingState,
                    //         // Called when Call End button is pressed
                    //         onCallEndButtonPressed: () {
                    //           meeting.end();
                    //         },
                    //
                    //         onCallLeaveButtonPressed: () {
                    //           meeting.leave();
                    //         },
                    //         // Called when mic button is pressed
                    //         onMicButtonPressed: () {
                    //           if (audioStream != null) {
                    //             meeting.muteMic();
                    //           } else {
                    //             meeting.unmuteMic();
                    //           }
                    //         },
                    //         // Called when camera button is pressed
                    //         onCameraButtonPressed: () {
                    //           if (videoStream != null) {
                    //             meeting.disableCam();
                    //           } else {
                    //             meeting.enableCam();
                    //           }
                    //         },
                    //
                    //         onSwitchMicButtonPressed: (details) async {
                    //           List<MediaDeviceInfo> outptuDevice =
                    //               meeting.getAudioOutputDevices();
                    //           double bottomMargin =
                    //               (70.0 * outptuDevice.length);
                    //           final screenSize = MediaQuery.of(context).size;
                    //           await showMenu(
                    //             context: context,
                    //             color: black700,
                    //             shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(12)),
                    //             position: RelativeRect.fromLTRB(
                    //               screenSize.width - details.globalPosition.dx,
                    //               details.globalPosition.dy - bottomMargin,
                    //               details.globalPosition.dx,
                    //               (bottomMargin),
                    //             ),
                    //             items: outptuDevice.map((e) {
                    //               return PopupMenuItem(
                    //                   value: e, child: Text(e.label));
                    //             }).toList(),
                    //             elevation: 8.0,
                    //           ).then((value) {
                    //             if (value != null) {
                    //               meeting.switchAudioDevice(value);
                    //             }
                    //           });
                    //         },
                    //
                    //         onChatButtonPressed: () {
                    //           // setState(() {
                    //           //   showChatSnackbar = false;
                    //           // });
                    //           // showModalBottomSheet(
                    //           //   context: context,
                    //           //   constraints: BoxConstraints(
                    //           //       maxHeight: MediaQuery.of(context)
                    //           //               .size
                    //           //               .height -
                    //           //           statusbarHeight),
                    //           //   isScrollControlled: true,
                    //           //   builder: (context) => ChatView(
                    //           //       key: const Key("ChatScreen"),
                    //           //       meeting: meeting),
                    //           // ).whenComplete(() {
                    //           //   setState(() {
                    //           //     showChatSnackbar = true;
                    //           //   });
                    //           // });
                    //         },
                    //
                    //         // Called when more options button is pressed
                    //         onMoreOptionSelected: (option) {
                    //           // Showing more options dialog box
                    //           if (option == "screenshare") {
                    //             if (remoteParticipantShareStream == null) {
                    //               if (shareStream == null) {
                    //                 meeting.enableScreenShare();
                    //               } else {
                    //                 meeting.disableScreenShare();
                    //               }
                    //             } else {
                    //               showSnackBarMessage(
                    //                   message: "Someone is already presenting",
                    //                   context: context);
                    //             }
                    //           } else if (option == "recording") {
                    //             if (recordingState == "RECORDING_STOPPING") {
                    //               showSnackBarMessage(
                    //                   message: "Recording is in stopping state",
                    //                   context: context);
                    //             } else if (recordingState ==
                    //                 "RECORDING_STARTED") {
                    //               meeting.stopRecording();
                    //             } else if (recordingState ==
                    //                 "RECORDING_STARTING") {
                    //               showSnackBarMessage(
                    //                   message: "Recording is in starting state",
                    //                   context: context);
                    //             } else {
                    //               meeting.startRecording();
                    //             }
                    //           } else if (option == "participants") {
                    //             // showModalBottomSheet(
                    //             //   context: context,
                    //             //   // constraints: BoxConstraints(
                    //             //   //     maxHeight: MediaQuery.of(context).size.height -
                    //             //   //         statusbarHeight),
                    //             //   isScrollControlled: false,
                    //             //   builder: (context) =>
                    //             //       ParticipantList(meeting: meeting),
                    //             // );
                    //           }
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CallButtonContainer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppCallButton(
                              onTap: () {
                                if (videoStream != null) {
                                  meeting?.disableCam();
                                } else {
                                  meeting?.enableCam();
                                }
                                // List<MediaDeviceInfo> cameras = [];
                                // cameras = meeting.getCameras();
                                // MediaDeviceInfo newCam = cameras.firstWhere(
                                //     (camera) =>
                                //         camera.deviceId !=
                                //         meeting.selectedCamId);
                                // meeting.changeCam(newCam.deviceId);
                              },
                              icon: Icons.videocam_off_outlined,
                              color: videoStream == null
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.1),
                              iconColor: videoStream == null
                                  ? Colors.black
                                  : Colors.white,
                              // IC
                            ),
                            SizedBox(
                                width: ResponsiveUtil.ratio(_context, 36.0)),
                            AppCallButton(
                              onTap: () {
                                List<MediaDeviceInfo> outptuDevice =
                                    meeting!.getAudioOutputDevices();
                                if (!isSpeaker) {
                                  meeting?.switchAudioDevice(outptuDevice[0]);
                                  setState(() {
                                    isSpeaker = true;
                                  });
                                } else {
                                  meeting?.switchAudioDevice(outptuDevice[1]);
                                  setState(() {
                                    isSpeaker = false;
                                  });
                                }

                                /// Earpiece
                                // setState(() {
                                //   if (isSpeaker == false) {
                                //     isSpeaker = true;
                                //     Helper.setSpeakerphoneOn(isSpeaker);
                                //     player!.setVolume(1);
                                //   } else {
                                //     isSpeaker = false;
                                //     Helper.setSpeakerphoneOn(isSpeaker);
                                //     player!.setVolume(0.3);
                                //   }
                                // });
                              },
                              icon: Icons.volume_up_outlined,
                              color: isSpeaker
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.1),
                              iconColor:
                                  isSpeaker ? Colors.black : Colors.white,
                              iconSize: 24.0,
                            ),
                            SizedBox(
                                width: ResponsiveUtil.ratio(_context, 36.0)),
                            AppCallButton(
                              onTap: () {
                                if (audioStream != null) {
                                  meeting?.muteMic();
                                } else {
                                  meeting?.unmuteMic();
                                }
                              },
                              image: Variable.imageVar.muteSound,
                              color: audioStream == null
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.1),
                              iconColor: audioStream == null
                                  ? Colors.red
                                  : Colors.white,
                              iconSize: 22.0,
                            ),
                            SizedBox(
                                width: ResponsiveUtil.ratio(_context, 36.0)),
                            AppCallButton(
                              onTap: () async {
                                _webrtcCall.stopBeepRing();
                                meeting?.end();
                              },
                              icon: Icons.call_end_rounded,
                              color: Colors.red,
                              iconSize: 32.0,
                            ),
                            SizedBox(
                              width: ResponsiveUtil.ratio(_context, 20.0),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
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
                  mirror: true,
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
                        iconColor: !_webrtcCall.isCameraOn
                            ? Colors.black
                            : Colors.white,
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
                            ? Colors.red
                            : Colors.white,
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

class VideoSDKController {}
