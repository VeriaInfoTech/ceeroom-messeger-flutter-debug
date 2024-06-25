import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/message_media_model.dart';
import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/utils/media_type.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/app_text_form_field.dart';
import 'package:CeeRoom/widgets/attach_container.dart';
import 'package:CeeRoom/widgets/audio_player.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:CeeRoom/widgets/pick_media_from_camera.dart';
import 'package:CeeRoom/widgets/wake_lock.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class SendMessageBox extends StatefulWidget {
  final ChatController chatCtl;
  final int? contactId;

  const SendMessageBox({
    super.key,
    required this.chatCtl,
    required this.contactId,
  });

  @override
  State<SendMessageBox> createState() => _SendMessageBoxState();
}

class _SendMessageBoxState extends State<SendMessageBox> {
  final UserController _userCtl = Get.put(UserController());
  late RecorderController _recordAudioCtl;
  late AppTextField _message;
  bool _recording = false;
  bool _stopRecording = false;
  String _audioPath = '';

  @override
  void initState() {
    _initController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initMessageInput();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: ResponsiveUtil.ratio(context, 16.0),
          right: ResponsiveUtil.ratio(context, 16.0),
          top: ResponsiveUtil.ratio(context, 18.0),
          bottom: ResponsiveUtil.ratio(context, 20.0),
        ),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Variable.colorVar.lightGray,
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0.0, 1.0),
              blurRadius: 1.0,
            ),
          ],
        ),
        child: _recording
            ? _recordAudio()
            : _stopRecording
                ? _listenAudio()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: ResponsiveUtil.ratio(context, 4.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            BaseWidget.attachBottomSheet(
                              child: AttachContainer(
                                onCameraPressed: () {
                                  BaseWidget.attachBottomSheet(
                                    child: SelectVideoOrPicBottomSheet(
                                      isCamera: true,
                                      onImagedPressed: onImageSelect,
                                      onVideoPressed: onVideoSelect,
                                    ),
                                    context: context,
                                  );
                                },
                                onGalleryPressed: () {
                                  BaseWidget.attachBottomSheet(
                                    child: SelectVideoOrPicBottomSheet(
                                      onImagedPressed: onImageSelect,
                                      onVideoPressed: onVideoSelect,
                                    ),
                                    context: context,
                                  );
                                },
                                onFilePicked: onFileSelect,
                              ),
                              context: context,
                            );
                          },
                          child: Icon(
                            Icons.attach_file,
                            size: ResponsiveUtil.ratio(context, 24.0),
                            color: Variable.colorVar.gray,
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtil.ratio(context, 8.0)),
                      Expanded(child: _message),
                      SizedBox(width: ResponsiveUtil.ratio(context, 8.0)),
                      Obx(
                        () {
                          return widget.chatCtl.canSendMsg.value
                              ? InkWell(
                                  onTap: () async {
                                    widget.chatCtl.sendMessage(
                                      msg: MessageModel(
                                        id: generateRandomString(10),
                                        type: 'text',
                                        seen: [
                                          _userCtl.user.id!,
                                        ],
                                        text: _message.controller!.text,
                                        userId: _userCtl.user.id!,
                                        timeSend: DateTime.now()
                                            .toUtc()
                                            .millisecondsSinceEpoch,
                                      ),
                                      userId: _userCtl.user.id!,
                                      contactId: widget.contactId,
                                    );
                                    _message.controller!.clear();
                                    _message.focusNode.unfocus();
                                    widget.chatCtl.canSendMsg.value = false;
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      ResponsiveUtil.ratio(context, 10.0),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Variable.colorVar.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      Variable.imageVar.send,
                                      width:
                                          ResponsiveUtil.ratio(context, 28.0),
                                      height:
                                          ResponsiveUtil.ratio(context, 28.0),
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    final p =
                                        await getApplicationDocumentsDirectory();
                                    await _recordAudioCtl.record(
                                      path:
                                          "${p.path}/${DateTime.now().millisecondsSinceEpoch}.m4a",
                                    );
                                    setState(() {
                                      _recording = true;
                                    });
                                    await WakelockChannel.toggle(true);
                                  },
                                  child: Image.asset(
                                    Variable.imageVar.mic,
                                    color: Variable.colorVar.gray,
                                    width: ResponsiveUtil.ratio(context, 24.0),
                                    height: ResponsiveUtil.ratio(context, 24.0),
                                    fit: BoxFit.fill,
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _recordAudio() {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            _initMessageInput();
            _recordAudioCtl.reset();
            _audioPath = await _recordAudioCtl.stop(false) ?? '';
            setState(() {
              _recording = false;
              _stopRecording = true;
            });
            await WakelockChannel.toggle(false);
          },
          child: Icon(
            Icons.stop_rounded,
            color: Colors.grey,
            size: ResponsiveUtil.ratio(context, 24.0),
          ),
        ),
        SizedBox(width: ResponsiveUtil.ratio(context, 12.0)),
        AudioWaveforms(
          size: Size(
            MediaQuery.of(context).size.width - 70.0,
            ResponsiveUtil.ratio(context, 60.0),
          ),
          recorderController: _recordAudioCtl,
          waveStyle: const WaveStyle(
            spacing: 8.0,
            extendWaveform: true,
            showMiddleLine: false,
          ),
        ),
      ],
    );
  }

  Widget _listenAudio() {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            _initMessageInput();
            _disposePlayer();
            _initController();
            setState(() {
              _stopRecording = false;
            });
          },
          child: Icon(
            Icons.close,
            color: Colors.grey,
            size: ResponsiveUtil.ratio(context, 24.0),
          ),
        ),
        SizedBox(width: ResponsiveUtil.ratio(context, 12.0)),
        InkWell(
          onTap: () async {
            _initMessageInput();
            _disposePlayer();
            _initController();
            setState(() {
              _stopRecording = false;
            });
            widget.chatCtl.addMessage(
              MessageModel(
                status: 0,
                id: generateRandomString(10),
                type: MediaType.voice,
                seen: [
                  _userCtl.user.id!,
                ],
                userId: _userCtl.user.id!,
                timeSend: DateTime.now().toUtc().millisecondsSinceEpoch,
                mediaInfo: MessageMediaModel(
                  mediaSource: _audioPath,
                  name: _audioPath.split('/').last,
                ),
                isUploadMsg: true,
              ),
            );
          },
          child: Icon(
            Icons.check,
            color: Colors.grey,
            size: ResponsiveUtil.ratio(context, 24.0),
          ),
        ),
        SizedBox(width: ResponsiveUtil.ratio(context, 12.0)),
        AudioPlayer(
          path: _audioPath,
          fixedWaveColor: Colors.black,
          liveWaveColor: Variable.colorVar.primaryColor,
          width: MediaQuery.of(context).size.width - 165.0,
        ),
      ],
    );
  }

  void _disposePlayer() {
    _recordAudioCtl.dispose();
  }

  void _initController() {
    _recordAudioCtl = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  void _initMessageInput() {
    _message = AppTextField(
      hint: Variable.stringVar.enterText.tr,
      fillColor: Colors.white,
      borderWidth: 0.0,
      borderColor: Colors.white,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
      // suffixIcon: AppIcon(
      //   icon: Variable.imageVar.gift,
      //   iconColor: Colors.grey,
      //   iconSize: 24.0,
      // ),
      onChange: (val) {
        if (val!.isNotEmpty) {
          widget.chatCtl.canSendMsg.value = true;
        } else {
          widget.chatCtl.canSendMsg.value = false;
        }
      },
    );
  }

  void onImageSelect(XFile media) {
    widget.chatCtl.addMessage(
      MessageModel(
        status: 0,
        id: generateRandomString(10),
        type: MediaType.image,
        seen: [
          _userCtl.user.id!,
        ],
        userId: _userCtl.user.id!,
        timeSend: DateTime.now().toUtc().millisecondsSinceEpoch,
        mediaInfo: MessageMediaModel(
          mediaSource: media.path,
          name: media.name,
        ),
        isUploadMsg: true,
      ),
    );
  }

  void onVideoSelect(XFile media) {
    widget.chatCtl.addMessage(
      MessageModel(
        status: 0,
        id: generateRandomString(10),
        type: MediaType.video,
        seen: [
          _userCtl.user.id!,
        ],
        userId: _userCtl.user.id!,
        timeSend: DateTime.now().toUtc().millisecondsSinceEpoch,
        mediaInfo: MessageMediaModel(
          mediaSource: media.path,
          name: media.name,
        ),
        isUploadMsg: true,
      ),
    );
  }

  void onFileSelect(FilePickerResult file) {
    widget.chatCtl.addMessage(
      MessageModel(
        status: 0,
        id: generateRandomString(10),
        type: MediaType.file,
        seen: [
          _userCtl.user.id!,
        ],
        userId: _userCtl.user.id!,
        timeSend: DateTime.now().toUtc().millisecondsSinceEpoch,
        mediaInfo: MessageMediaModel(
          mediaSource: file.files[0].path,
          name: file.files[0].name,
        ),
        isUploadMsg: true,
      ),
    );
  }
}
