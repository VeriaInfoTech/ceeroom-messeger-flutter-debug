import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/controllers/massenger_profile/massenger_profile_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/chat_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/utils/media_type.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/app_back_button.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/app_icon.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/avatar_container.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:CeeRoom/widgets/chat_shimmer_loading.dart';
import 'package:CeeRoom/widgets/group_avatar.dart';
import 'package:CeeRoom/widgets/media_content.dart';
import 'package:CeeRoom/widgets/retry_button.dart';
import 'package:CeeRoom/widgets/send_message_box.dart';
import 'package:CeeRoom/widgets/text_content.dart';
import 'package:CeeRoom/widgets/wake_lock.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

class SingleChatScreen extends StatelessWidget {
  late ChatController _chatCtl;
  final UserController _userCtl = Get.put(UserController());
  final ChatController _globalChatCtl = Get.put(ChatController());
  final MessengerProfileController _profCtl =
      Get.put(MessengerProfileController());
  ChatModel? chat;
  ContactModel? contact;
  late BuildContext _context;
  late String tag;

  SingleChatScreen({
    Key? key,
    this.chat,
    this.contact,
  }) : super(key: key) {
    if (chat != null) {
      tag = chat!.conversationId!;
    } else {
      tag = contact!.id.toString();
    }
    _chatCtl = Get.put(ChatController(), tag: tag);
    _init();
  }

  Future<void> _init() async {
    _chatCtl.canSendMsg.value = false;
    if (chat != null && chat!.profile == null) {
      if (chat!.userId == _userCtl.user.id) {
        contact = chat!.profiles![1];
      } else {
        contact = chat!.profiles![0];
      }
    }
    // await _chatCtl.getChatMessages(chat!.slug!);
    _chatCtl.connectToSocket(
      _userCtl.user.accessToken!,
      () async {
        if (contact != null) {
          _chatCtl.messages.value = null;
          final slug = await _profCtl.isNewChat(
            contact!.id!,
            _userCtl.user.id!,
          );
          if (slug == null && _profCtl.checkIsNewChatServerErr) {
            _chatCtl.getChatMessagesServerErr.value = true;
            _chatCtl.getChatLoading.value = null;
            return;
          } else if (slug == null) {
            _chatCtl.messages.value = [];
          } else {
            await _chatCtl.getChatMessages(slug);
          }
        } else {
          await _chatCtl.getChatMessages(chat!.slug!);
        }
        _chatCtl.updateSeenUsers(_userCtl.user.id!);
      },
      _userCtl.user.id!,
      contact?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            _back();
            await WakelockChannel.toggle(false);
            return true;
          },
          child: Column(
            children: [
              _header(),
              Expanded(
                child: Obx(
                  () => Stack(
                    children: [
                      _chatCtl.getChatMessagesServerErr.value
                          ? SizedBox(
                              width: Get.width,
                              child: RetryButton(
                                onTap: () {
                                  _chatCtl.messages.value == null;
                                  _chatCtl.getChatMessagesServerErr.value =
                                      false;
                                  _init();
                                },
                              ),
                            )
                          : _messages(),
                      _chatCtl.messages.value == null
                          ? const SizedBox()
                          : SendMessageBox(
                              chatCtl: _chatCtl,
                              contactId: contact?.id!,
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        AppPadding(
          child: Row(
            children: [
              AppBackButton(
                moreBackAction: _back,
              ),
              SizedBox(width: ResponsiveUtil.ratio(_context, 30.0)),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_chatCtl.isGroupChat(chat: chat)) {
                      Get.toNamed(
                        Routes.groupProfile,
                        arguments: {
                          'tag': tag,
                          'groupName': chat!.profile!.name,
                          'slug': chat!.slug,
                        },
                      );
                    } else {
                      Get.toNamed(
                        Routes.userProfile,
                        arguments: contact,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          _chatCtl.isGroupChat(chat: chat)
                              ? const AvatarContainer(icon: GroupAvatar())
                              : CacheImage(
                                  contact!.avatar,
                                  size: ResponsiveUtil.ratio(_context, 40.0),
                                ),
                          // Positioned(
                          //   bottom: MainController.ratio * 2.0,
                          //   right: MainController.ratio * 2.0,
                          //   child: Container(
                          //     width: MainController.ratio * 10.0,
                          //     height: MainController.ratio * 10.0,
                          //     decoration: BoxDecoration(
                          //       color: Variable.colorVar.green,
                          //       shape: BoxShape.circle,
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                      SizedBox(width: ResponsiveUtil.ratio(_context, 10.0)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppDynamicFontText(
                            text: _chatCtl.isGroupChat(chat: chat)
                                ? chat!.profile!.name!
                                : contact!.name!,
                            style: TextStyle(
                              color: Variable.colorVar.darkGray,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtil.ratio(_context, 14.0),
                            ),
                          ),
                          _chatCtl.isGroupChat(chat: chat)
                              ? const SizedBox()
                              : Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          ResponsiveUtil.ratio(_context, 4.0),
                                    ),
                                    Text(
                                      'last seen recently',
                                      style: TextStyle(
                                        color: Variable.colorVar.darkGray,
                                        fontWeight: FontWeight.w300,
                                        fontSize: ResponsiveUtil.ratio(
                                          _context,
                                          12.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AppIcon(
                icon: Variable.imageVar.videoCam,
                onTap: () {
                  if (chat != null && chat!.profile != null) {
                    Get.toNamed(
                      Routes.groupVideoCall,
                      arguments: {
                        'contacts': chat!.profiles,
                        'call_id': null,
                        'gp_name': chat!.profile!.name,
                      },
                    );
                  } else {
                    Get.toNamed(
                      Routes.videoCall,
                      arguments: {
                        'contact': contact,
                        'call_id': null,
                      },
                    );
                  }
                },
              ),
              SizedBox(width: ResponsiveUtil.ratio(_context, 20.0)),
              AppIcon(
                icon: Variable.imageVar.call,
                onTap: () {
                  if (chat != null && chat!.profile != null) {
                    Get.toNamed(
                      Routes.groupVoiceCall,
                      arguments: {
                        'contacts': chat!.profiles,
                        'call_id': null,
                        'gp_name': chat!.profile!.name,
                      },
                    );
                  } else {
                    Get.toNamed(
                      Routes.voiceCall,
                      arguments: {
                        'contact': contact,
                        'call_id': null,
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const AppDivider()
      ],
    );
  }

  void _back() async {
    if (_chatCtl.chat != null) {
      _chatCtl.closeSocket();
    }
    Get.delete<ChatController>(tag: tag);
    await _globalChatCtl.getChats(clear: false);
  }

  Widget _messages() {
    return Obx(() => SizedBox(
        width: MediaQuery.of(_context).size.width,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveUtil.ratio(_context, 16.0),
            left: ResponsiveUtil.ratio(_context, 8.0),
            right: ResponsiveUtil.ratio(_context, 8.0),
            top: ResponsiveUtil.ratio(_context, 8.0),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  reverse: _chatCtl.messages.value == null ?false : true,
                  padding: EdgeInsets.only(
                    bottom: ResponsiveUtil.ratio(
                      _context,
                      80.0,
                    ),
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    verticalDirection: VerticalDirection.up,
                    children: List.generate(
                      _chatCtl.messages.value == null
                          ? 8
                          : _chatCtl.messages.value!.length,
                      (index) => _chatCtl.messages.value == null
                          ? ChatShimmerLoading(index: index)
                          : _anyMsg(
                              _chatCtl.messages.value![index],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _anyMsg(MessageModel message) {
    bool fromFriend = message.userId != _userCtl.user.id;
    bool hasBeenSeen = isEqualList(
      message.seen,
      _chatCtl.chat?.users,
      isOrderImportant: false,
    );
    ContactModel? senderProfile;
    if (fromFriend && _chatCtl.isGroupChat()) {
      senderProfile = _chatCtl.chat?.profiles
          ?.firstWhere((element) => element.id == message.userId);
    }

    return GetBuilder<ChatController>(
      id: 'message_${message.id}',
      tag: tag,
      key: Key(message.id!),
      builder: (ctl) {
        return _chatCtl.isGroupChat() &&
                _chatCtl.messages.value!.indexOf(message) ==
                    _chatCtl.messages.value!.length - 1
            ? Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtil.ratio(_context, 52.0),
                  vertical: ResponsiveUtil.ratio(_context, 8.0),
                ),
                padding: EdgeInsets.all(ResponsiveUtil.ratio(_context, 8.0)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Variable.colorVar.lightBlue,
                ),
                child: Center(
                  child: AppDynamicFontText(
                    text: message.text!,
                    style: TextStyle(
                      fontSize: ResponsiveUtil.ratio(_context, 14.0),
                      color: Variable.colorVar.heavyGray,
                    ),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  bottom: ResponsiveUtil.ratio(_context, 20.0),
                ),
                child: Row(
                  mainAxisAlignment: fromFriend
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveUtil.ratio(_context, 230.0),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: messageBorderRadius(fromFriend, _context),
                        color: fromFriend
                            ? Variable.colorVar.whiteSmoke
                            : Variable.colorVar.primaryColor,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: fromFriend
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          if (senderProfile != null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: ResponsiveUtil.ratio(_context, 12.0),
                                left: ResponsiveUtil.ratio(_context, 16.0),
                                right: ResponsiveUtil.ratio(_context, 16.0),
                              ),
                              child: AppDynamicFontText(
                                text: senderProfile.name!,
                                style: TextStyle(
                                  fontSize: ResponsiveUtil.ratio(
                                    _context,
                                    14.0,
                                  ),
                                ),
                              ),
                            ),
                          message.type == 'text'
                              ? TextMessage(
                                  message: message,
                                  fromFriend: fromFriend,
                                  hasBeenSeen: hasBeenSeen,
                                )
                              : InkWell(
                                  onTap: () async {
                                    if (message.mediaInfo!.path != null &&
                                        message.type != MediaType.voice) {
                                      final result = await OpenFile.open(
                                        message.mediaInfo!.path,
                                      );
                                      if (result.type ==
                                          ResultType.permissionDenied) {
                                        BaseWidget.snackBar(
                                          Variable
                                              .stringVar.permissionDenied.tr,
                                        );
                                      }
                                    }
                                  },
                                  child: MediaContent(
                                    message: message,
                                    fromFriend: fromFriend,
                                    hasBeenSeen: hasBeenSeen,
                                    chatCtl: _chatCtl,
                                    contactId: contact?.id,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
