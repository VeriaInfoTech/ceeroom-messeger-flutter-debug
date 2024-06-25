import 'dart:io';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/controllers/media/media_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/core/services/local_storage/media.dart';
import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadMediaButton extends StatefulWidget {
  final MessageModel message;
  final ChatController chatCtl;
  final int? contactId;
  final bool showDownloadSize;
  final Color bgColor;
  final Color iconColor;

  const DownloadMediaButton({
    super.key,
    required this.message,
    required this.chatCtl,
    required this.contactId,
    this.showDownloadSize = false,
    this.iconColor = const Color(0xff0045F5),
    this.bgColor = Colors.white,
  });

  @override
  State<DownloadMediaButton> createState() => _DownloadMediaButtonState();
}

class _DownloadMediaButtonState extends State<DownloadMediaButton> {
  double progress = 0;
  final MediaController _mediaCtl = MediaController();
  final UserController _userCtl = Get.put(UserController());
  ApiHelper apiHelper = ApiHelper();


  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    if (widget.message.isUploadMsg) {
      _mediaCtl.uploadMedia(
          file: File(widget.message.mediaInfo!.mediaSource!),
          url: apiHelper.uploadMedia,
          onSuccess: (media) {
            widget.message.mediaInfo!.mediaSize = media.sizeView;
            widget.message.mediaInfo!.id = media.id;
            widget.message.mediaInfo!.name = media.originalName;
            widget.message.mediaInfo!.path =
                widget.message.mediaInfo!.mediaSource;
            final localMedias = MediaLocalStorage.getMedias();
            localMedias.add(widget.message.mediaInfo!);
            MediaLocalStorage.storeMedia(localMedias);
            widget.chatCtl.sendMessage(
              userId: _userCtl.user.id!,
              contactId: widget.contactId,
              msg: widget.message,
              addMessage: false,
            );
          },
          onProgress: (p) {
            setState(() {
              progress = p;
            });
          },
          onCancel: () {
            widget.chatCtl.removeMessage(widget.message.id!);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return progress == 1
        ? const SizedBox()
        : widget.message.isUploadMsg
            ? _uploadBtn()
            : _downloadBtn();
  }

  Widget _whiteCircle(Widget child, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtil.ratio(context, 12.0),
          vertical: ResponsiveUtil.ratio(context, 12.0),
        ),
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: child,
      ),
    );
  }

  Widget _downloadBtn() {
    return _whiteCircle(
      progress > 0
          ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: ResponsiveUtil.ratio(context, 32.0),
                  height: ResponsiveUtil.ratio(context, 32.0),
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Variable.colorVar.primaryColor,
                    ),
                    value: progress,
                  ),
                ),
                Icon(
                  Icons.close,
                  size: ResponsiveUtil.ratio(context, 28.0),
                  color: widget.iconColor,
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  size: ResponsiveUtil.ratio(context, 28.0),
                  color: widget.iconColor,
                ),
                if (widget.showDownloadSize) ...[
                  SizedBox(
                    width: ResponsiveUtil.ratio(context, 4.0),
                  ),
                  Text(
                    widget.message.mediaInfo!.mediaSize ?? '',
                    style: TextStyle(
                      fontSize: ResponsiveUtil.ratio(context, 12.0),
                      color: Variable.colorVar.darkGrey,
                    ),
                  )
                ],
              ],
            ),
      () {
        if (progress > 0) {
          setState(() {
            progress = 0;
          });
          _mediaCtl.cancel();
        } else {
          _mediaCtl.downloadMedia(
            mediaId: widget.message.mediaInfo!.id!,
            onSuccess: (path) {
              final medias = MediaLocalStorage.getMedias();
              widget.message.mediaInfo!.path = path;
              medias.add(widget.message.mediaInfo!);
              MediaLocalStorage.storeMedia(medias);
              widget.chatCtl.update(['message_${widget.message.id}']);
            },
            onProgress: (p) {
              setState(() {
                progress = p;
              });
            },
          );
        }
      },
    );
  }

  Widget _uploadBtn() {
    return _whiteCircle(
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: ResponsiveUtil.ratio(context, 32.0),
            height: ResponsiveUtil.ratio(context, 32.0),
            child: CircularProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.1),
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(
                Variable.colorVar.primaryColor,
              ),
              value: progress,
            ),
          ),
          Icon(
            Icons.close,
            size: ResponsiveUtil.ratio(context, 28.0),
            color: widget.iconColor,
          ),
        ],
      ),
      () {
        _mediaCtl.cancelToken.cancel();
      },
    );
  }

  @override
  void dispose() {
    _mediaCtl.cancel();
    super.dispose();
  }
}
