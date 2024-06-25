import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/controllers/group/group_controller.dart';
import 'package:CeeRoom/core/controllers/socket/socket_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/chat_model.dart';
import 'package:CeeRoom/core/models/group_profile_model.dart';
import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_back_button.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/app_text_form_field.dart';
import 'package:CeeRoom/widgets/avatar_container.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:CeeRoom/widgets/floating_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateGroupScreen extends StatelessWidget {
  final GroupController _groupCtl = Get.put(GroupController());
  final ChatController _chatCtl = Get.put(ChatController());
  final UserController _useCtl = Get.put(UserController());
  final GeneralSocketController _socketCtl = Get.put(GeneralSocketController());
  late AppTextField _groupName;
  late BuildContext _context;

  CreateGroupScreen({Key? key}) : super(key: key) {
    _groupCtl.socketCtl = _socketCtl;
    _groupName = AppTextField(
      hint: Variable.stringVar.groupName.tr,
      keyboardType: TextInputType.text,
      dispose: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Obx(
          () {
            return FloatingButton(
              icon: Variable.imageVar.check,
              child: _groupCtl.createGroupLoading.value
                  ? const AppLoading(color: Colors.white)
                  : null,
              onTap: () {
                if (_groupName.controller!.text == '') {
                  BaseWidget.snackBar(Variable.stringVar.enterGroupName.tr);
                  return;
                }
                _groupCtl.createGroup(
                  ChatModel(
                    users: List.generate(
                      _groupCtl.selectedMembers.length,
                      (index) => _groupCtl.selectedMembers[index].id!,
                    ),
                    profile: GroupProfileModel(
                      name: _groupName.controller!.text,
                      bio: "",
                      identity: _groupName.controller!.text
                          .replaceAll(' ', '-')
                          .toLowerCase(),
                    ),
                    createGroupMessage: MessageModel(
                        type: 'text',
                        text: 'Group created by ${_useCtl.user.name}',
                        seen: [
                          _useCtl.user.id!,
                        ]),
                  ),
                  () {
                    _chatCtl.getChats(clear: false);
                  },
                );
              },
            );
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            SizedBox(height: ResponsiveUtil.ratio(_context, 16.0)),
            _groupDetails(),
            SizedBox(height: ResponsiveUtil.ratio(_context, 16.0)),
            const AppDivider(),
            _membersList(),
          ],
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
              const AppBackButton(),
              SizedBox(width: ResponsiveUtil.ratio(_context, 4.0)),
              Text(
                Variable.stringVar.newGroup.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtil.ratio(_context, 17.0),
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
        const AppDivider()
      ],
    );
  }

  Widget _groupDetails() {
    return AppPadding(
      child: Row(
        children: [
          AvatarContainer(
            avatar: DecorationImage(
              image: AssetImage(Variable.imageVar.camera),
            ),
          ),
          SizedBox(width: ResponsiveUtil.ratio(_context, 6.0)),
          Expanded(child: _groupName)
        ],
      ),
    );
  }

  Widget _membersList() {
    return AppPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "${Variable.stringVar.members.tr} ${_groupCtl.selectedMembers.length}",
            style: TextStyle(
              fontSize: ResponsiveUtil.ratio(_context, 12.0),
            ),
          ),
          SizedBox(height: ResponsiveUtil.ratio(_context, 16.0)),
          Wrap(
            children: _groupCtl.selectedMembers.map((item) {
              return Padding(
                padding: EdgeInsets.all(ResponsiveUtil.ratio(_context, 14.0)),
                child: Column(
                  children: [
                    CacheImage(item.avatar),
                    AppDynamicFontText(
                      text: item.name!,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.ratio(_context, 10.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
