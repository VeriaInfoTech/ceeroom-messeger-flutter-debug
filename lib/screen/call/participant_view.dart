import 'package:CeeRoom/screen/call/spacer.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videosdk/videosdk.dart';

import 'colors.dart';

class ParticipantView extends StatelessWidget {
  final Stream? stream;
  final bool isMicOn;
  final Color? avatarBackground;
  final Participant participant;
  final bool isLocalScreenShare;
  final bool isScreenShare;
  final double avatarTextSize;
  final Function() onStopScreeenSharePressed;
  final String? avatar;

  const ParticipantView({
    super.key,
    required this.stream,
    required this.isMicOn,
    required this.avatarBackground,
    required this.participant,
    this.isLocalScreenShare = false,
    this.avatarTextSize = 50,
    required this.isScreenShare,
    required this.onStopScreeenSharePressed,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        stream != null
            ? RTCVideoView(
                stream?.renderer as RTCVideoRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            : Center(
                child: !isLocalScreenShare
                    ? Container(
                        padding: EdgeInsets.all(avatarTextSize / 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: avatarBackground,
                        ),
                        child: avatar != null
                            ? CacheImage(avatar)
                            : Text(
                                participant.displayName.characters.first
                                    .toUpperCase(),
                                style: TextStyle(fontSize: avatarTextSize),
                              ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            SvgPicture.asset(
                              "assets/ic_screen_share.svg",
                              height: 40,
                            ),
                            const VerticalSpacer(20),
                            const Text(
                              "You are presenting to everyone",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const VerticalSpacer(20),
                            MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 30),
                                color: purple,
                                onPressed: onStopScreeenSharePressed,
                                child: const Text("Stop Presenting",
                                    style: TextStyle(fontSize: 16)))
                          ])),
        if (!isMicOn)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.mic_off,
                size: avatarTextSize / 2,
              ),
            ),
          ),
        if (isScreenShare)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: black700,
              ),
              child: Text(isScreenShare
                  ? "${isLocalScreenShare ? "You" : participant.displayName} is presenting"
                  : participant.displayName),
            ),
          ),
        // Positioned(top: 4, left: 4, child: CallStats(participant: participant)),
      ],
    );
  }
}
