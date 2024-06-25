import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/controllers/socket/socket_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/chat_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/media_type.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/app_empty_data.dart';
import 'package:CeeRoom/widgets/app_header.dart';
import 'package:CeeRoom/widgets/app_refresh_indicator.dart';
import 'package:CeeRoom/widgets/avatar_container.dart';
import 'package:CeeRoom/widgets/group_avatar.dart';
import 'package:CeeRoom/widgets/retry_button.dart';
import 'package:CeeRoom/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  final ChatController _chatCtl = Get.put(ChatController());
  final UserController _userCtl = Get.put(UserController());
  final GeneralSocketController _socketCtl = Get.put(GeneralSocketController());
  late BuildContext _context;

  ChatScreen({Key? key}) : super(key: key) {
    _init();
  }

  void _init() async {
    ///
    // _chatCtl.closeSocket();

    _socketCtl.onGroupCreate = () {
      _chatCtl.getChats(clear: false);
    };
    await _chatCtl.getChats();
    _chatCtl.allChats = _chatCtl.chats.value!;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Column(
        children: [
          AppHeader(
            title: Variable.stringVar.chats.tr,
            onSearch: (val) {
              if (!_chatCtl.getChatsServerErr.value &&
                  _chatCtl.chats.value != null) {
                _chatCtl.searchChats(val: val!, userId: _userCtl.user.id!);
              }
            },
          ),
          Obx(
            () => _chatCtl.getChatsServerErr.value
                ? Expanded(
                    child: Center(
                      child: RetryButton(onTap: _chatCtl.getChats),
                    ),
                  )
                : _chatCtl.chats.value != null && _chatCtl.chats.value!.isEmpty
                    ? Expanded(
                        child: AppRefreshIndicator(
                          onRefresh: () async {
                            _init();
                          },
                          child: ListView(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            children: [
                              SizedBox(
                                height: ResponsiveUtil.ratio(_context, 150.0),
                              ),
                              AppEmptyData(
                                title: Variable.stringVar.conversation.tr,
                              )
                            ],
                          ),
                        ),
                      )
                    : _chatList(),
          ),
        ],
      ),
    );
  }

  Widget _chatList() {
    return Expanded(
      child: AppRefreshIndicator(
        onRefresh: () async {
          _init();
        },
        child: ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount:
              _chatCtl.chats.value == null ? 9 : _chatCtl.chats.value!.length,
          itemBuilder: (BuildContext context, int index) {
            return _chatCtl.chats.value == null
                ? const ShimmerLoading()
                : _chatItem(
                    _chatCtl.chats.value![index],
                  );
          },
        ),
      ),
    );
  }

  Widget _chatItem(ChatModel chat) {
    ContactModel contact;

    if (chat.profile != null) {
      contact = ContactModel(
        name: chat.profile!.name,
        avatar: chat.profile!.avatar,
      );
    } else {
      contact = chat.userId == _userCtl.user.id
          ? chat.profiles![1]
          : chat.profiles![0];
    }
    return InkWell(
      onTap: () {
        Get.toNamed(
          Routes.singleChat,
          arguments: {'chat': chat, 'contact': null},
        );
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtil.ratio(_context, 10.0),
              horizontal: ResponsiveUtil.ratio(_context, 16.0),
            ),
            child: Row(
              children: [
                chat.profile != null
                    ? const AvatarContainer(icon: GroupAvatar())
                    : CacheImage(contact.avatar),
                SizedBox(width: ResponsiveUtil.ratio(_context, 10.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppDynamicFontText(
                        text: contact.name!,
                        style: TextStyle(
                          color: Variable.colorVar.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtil.ratio(_context, 14.0),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtil.ratio(_context, 4.0)),
                      _subtitle(chat),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtil.ratio(_context, 14.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${prettyTimeStamp(chat.message![0].timeSend!)['date']}",
                          style: TextStyle(
                            color: Variable.colorVar.gray,
                            fontSize: ResponsiveUtil.ratio(_context, 12.0),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtil.ratio(_context, 6.0)),
                        Text(
                          "${prettyTimeStamp(chat.message![0].timeSend!)['time']}",
                          style: TextStyle(
                            color: Variable.colorVar.gray,
                            fontSize: ResponsiveUtil.ratio(_context, 12.0),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    if (chat.unseenCount != null && chat.unseenCount! > 0)
                      _unSeenValue(chat.unseenCount!)
                    else if (chat.profile != null &&
                        !chat.message![0].seen!.contains(_userCtl.user.id))
                      _unSeenValue(1)
                    else if (chat.profile == null &&
                        !isEqualList(chat.message![0].seen!, chat.users,
                            isOrderImportant: false) &&
                        chat.message![0].userId != _userCtl.user.id)
                      _unSeenValue(1)
                  ],
                ),
              ],
            ),
          ),
          Divider(
            thickness: ResponsiveUtil.ratio(_context, 1.0),
            height: 0.0,
          ),
        ],
      ),
    );
  }

  Widget _unSeenValue(int value) {
    return Column(
      children: [
        SizedBox(height: ResponsiveUtil.ratio(_context, 6.0)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtil.ratio(_context, 10.0),
            vertical: ResponsiveUtil.ratio(_context, 4.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.ratio(_context, 12.0),
            ),
            color: Variable.colorVar.primaryColor,
          ),
          child: Text(
            '+$value',
            style: TextStyle(
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
              fontSize: ResponsiveUtil.ratio(_context, 12.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _subtitle(ChatModel chat) {
    return chat.message![0].type == MediaType.image
        ? _mediaMessage(Icons.image, MediaType.image)
        : chat.message![0].type == MediaType.video
            ? _mediaMessage(Icons.video_file_rounded, MediaType.video)
            : chat.message![0].type == MediaType.voice
                ? _mediaMessage(
                    Icons.keyboard_voice,
                    MediaType.voice,
                  )
                : chat.message![0].type == MediaType.file
                    ? _mediaMessage(
                        Icons.file_present_rounded,
                        MediaType.file,
                      )
                    : AppDynamicFontText(
                        text: chat.message![0].text ?? '',
                        style: TextStyle(
                          color: Variable.colorVar.gray,
                          overflow: TextOverflow.ellipsis,
                          fontSize: ResponsiveUtil.ratio(
                            _context,
                            12.0,
                          ),
                        ),
                      );
  }

  Widget _mediaMessage(IconData icon, String type) {
    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveUtil.ratio(_context, 16.0),
          color: Variable.colorVar.gray,
        ),
        SizedBox(width: ResponsiveUtil.ratio(_context, 8.0)),
        Text(
          type,
          style: TextStyle(
            color: Variable.colorVar.gray,
            fontSize: ResponsiveUtil.ratio(
              _context,
              12.0,
            ),
          ),
        )
      ],
    );
  }
}
