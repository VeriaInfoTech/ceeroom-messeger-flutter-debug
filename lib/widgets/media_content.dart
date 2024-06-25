import 'dart:io';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/utils/media_type.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/audio_player.dart';
import 'package:CeeRoom/widgets/download_media_button.dart';
import 'package:CeeRoom/widgets/message_seen_status.dart';
import 'package:flutter/material.dart';

class MediaContent extends StatelessWidget {
  final MessageModel message;
  final bool fromFriend;
  final bool hasBeenSeen;
  final ChatController chatCtl;
  final int? contactId;
  late BuildContext _context;

  MediaContent({
    super.key,
    required this.message,
    required this.fromFriend,
    required this.hasBeenSeen,
    required this.chatCtl,
    required this.contactId,
  });

  @override
  Widget build(BuildContext context) {
    _context = context;
    return message.type == MediaType.file
        ? _fileMsg()
        : message.type == MediaType.voice
            ? _voiceMsg()
            : message.type == MediaType.image
                ? _imageMsg()
                : message.type == MediaType.video
                    ? _videoMsg()
                    : const SizedBox();
  }

  Widget _fileMsg() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.ratio(_context, 4.0),
        horizontal: ResponsiveUtil.ratio(_context, 8.0),
      ),
      child: SizedBox(
        height: ResponsiveUtil.ratio(_context, 80.0),
        child: Column(
          children: [
            const Spacer(),
            Row(
              children: [
                Container(
                  width: ResponsiveUtil.ratio(_context, 60.0),
                  height: ResponsiveUtil.ratio(_context, 60.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(Variable.imageVar.pdfMedia)
                    )
                  ),
                  alignment: Alignment.center,
                  child: message.mediaInfo!.path == null
                      ? DownloadMediaButton(
                          message: message,
                          chatCtl: chatCtl,
                          contactId: contactId,
                        )
                      : const SizedBox(),
                ),
                SizedBox(width: ResponsiveUtil.ratio(_context, 4.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.mediaInfo!.name ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ResponsiveUtil.ratio(_context, 14.0),
                          color: fromFriend
                              ? Colors.black
                              : Variable.colorVar.blueSky,
                        ),
                      ),
                      Text(
                        message.mediaInfo!.mediaSize ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ResponsiveUtil.ratio(_context, 12.0),
                          color: fromFriend
                              ? Colors.black
                              : Variable.colorVar.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: MessageSeenStatus(
                message: message,
                fromFriend: fromFriend,
                hasBeenSeen: hasBeenSeen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _voiceMsg() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.ratio(_context, 12.0),
        horizontal: ResponsiveUtil.ratio(_context, 16.0),
      ),
      child: SizedBox(
        height: ResponsiveUtil.ratio(_context, 80.0),
        child: Column(
          children: [
            const Spacer(),
            message.mediaInfo!.path == null
                ? Row(
                    children: [
                      DownloadMediaButton(
                        message: message,
                        chatCtl: chatCtl,
                        contactId: contactId,
                        bgColor: fromFriend
                            ? Variable.colorVar.primaryColor
                            : Colors.white,
                        iconColor: fromFriend
                            ? Colors.white
                            : Variable.colorVar.primaryColor,
                      ),
                    ],
                  )
                : AudioPlayer(
                    path: message.mediaInfo!.path!,
                    iconColor: fromFriend
                        ? Colors.white
                        : Variable.colorVar.primaryColor,
                    btnBgColor: fromFriend
                        ? Variable.colorVar.primaryColor
                        : Colors.white,
                    fixedWaveColor: fromFriend
                        ? Variable.colorVar.heavyGray
                        : Variable.colorVar.lightGary,
                    liveWaveColor: fromFriend
                        ? Variable.colorVar.primaryColor
                        : Variable.colorVar.blackPearl,
                  ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: MessageSeenStatus(
                message: message,
                fromFriend: fromFriend,
                hasBeenSeen: hasBeenSeen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageMsg() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtil.ratio(_context, 4.0)),
      child: Container(
        height: ResponsiveUtil.ratio(_context, 320.0),
        decoration: BoxDecoration(
          borderRadius: messageBorderRadius(fromFriend, _context),
          image: DecorationImage(
            fit: BoxFit.fill,
            image: message.mediaInfo!.path == null
                ? AssetImage(Variable.imageVar.blurImage)
                : FileImage(
                    File(message.mediaInfo!.path!),
                  ) as ImageProvider,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            if (message.mediaInfo!.path == null)
              DownloadMediaButton(
                message: message,
                chatCtl: chatCtl,
                contactId: contactId,
              ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: MessageSeenStatus(
                message: message,
                fromFriend: fromFriend,
                hasBeenSeen: hasBeenSeen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoMsg() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtil.ratio(_context, 4.0)),
      child: SizedBox(
        height: ResponsiveUtil.ratio(_context, 180.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: messageBorderRadius(fromFriend, _context),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(Variable.imageVar.blurImage),
            ),
          ),
          child: Column(
            children: [
              const Spacer(),
              message.mediaInfo!.path == null
                  ? DownloadMediaButton(
                      message: message,
                      chatCtl: chatCtl,
                      contactId: contactId,
                      showDownloadSize: true,
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtil.ratio(_context, 12.0),
                        vertical: ResponsiveUtil.ratio(_context, 12.0),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50.0),
                        // shape: BoxShape.circle,
                      ),
                      // alignment: Alignment.center,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Variable.colorVar.primaryColor,
                        size: ResponsiveUtil.ratio(_context, 28.0),
                      ),
                    ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: MessageSeenStatus(
                  message: message,
                  fromFriend: fromFriend,
                  hasBeenSeen: hasBeenSeen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
