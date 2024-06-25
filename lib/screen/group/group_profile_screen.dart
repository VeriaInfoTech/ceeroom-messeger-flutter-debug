import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/conatct_item_padding.dart';
import 'package:CeeRoom/widgets/retry_button.dart';
import 'package:CeeRoom/widgets/shimmer_loading.dart';
import 'package:CeeRoom/widgets/sliver_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupProfileScreen extends StatelessWidget {
  final String tag;
  final String groupName;
  final String slug;
  late ChatController _chatCtl;
  late BuildContext _context;
  final UserController _userCtl = Get.put(UserController());

  GroupProfileScreen({
    Key? key,
    required this.tag,
    required this.groupName,
    required this.slug,
  }) : super(key: key) {
    _chatCtl = Get.put(ChatController(), tag: tag);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        body: Obx(
          () {
            String members = _chatCtl.getChatLoading.value != null
                ? !_chatCtl.getChatLoading.value!
                    ? '${_chatCtl.chat!.profiles!.length} ${Variable.stringVar.members.tr}'
                    : ''
                : '';
            return CustomScrollView(
              physics: const PageScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  delegate: SliverHeader(
                    MediaQuery.of(context).size.width,
                    groupName,
                    members,
                  ),
                  pinned: true,
                  floating: true,
                ),
                SliverToBoxAdapter(child: _headerDescription(members)),
                _membersList()
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _membersList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _chatCtl.getChatLoading.value == null
              ? RetryButton(
                  onTap: () {
                    _chatCtl.getChatMessages(slug, clear: false);
                  },
                )
              : _chatCtl.getChatLoading.value!
                  ? const ShimmerLoading()
                  : Column(
                      children: [
                        if (!_chatCtl.getChatLoading.value!)
                          if (index == 0)
                            for (ContactModel contact in _chatCtl.chat!.profiles!)
                              if (contact.id == _userCtl.user.id)
                                _groupMemberItem(
                                  contact: contact,
                                  hasDivider: true,
                                  isAdmin: contact.id ==
                                      _chatCtl.chat!.message![_chatCtl.chat!.message!.length - 1].userId,
                                  isUser: true,
                                ),
                        _chatCtl.chat!.profiles![index].id != _userCtl.user.id
                            ? _groupMemberItem(
                                contact: _chatCtl.chat!.profiles![index],
                                hasDivider: true,
                                isAdmin: _chatCtl.chat!.profiles![index].id ==
                                    _chatCtl
                                        .chat!
                                        .message![
                                            _chatCtl.chat!.message!.length - 1]
                                        .userId,
                              )
                            : const SizedBox()
                      ],
                    );
        },
        childCount: _chatCtl.getChatLoading.value == null
            ? 1
            : _chatCtl.getChatLoading.value!
                ? 8
                : _chatCtl.chat!.profiles!.length,
      ),
    );
  }

  Widget _headerDescription(String members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
        AppDynamicFontText(
          text: groupName,
          style: TextStyle(
            color: Variable.colorVar.darkGray,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtil.ratio(_context, 16.0),
          ),
        ),
        SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
        Text(
          members,
          style: TextStyle(
            color: Variable.colorVar.gray,
            fontSize: ResponsiveUtil.ratio(_context, 14.0),
          ),
        ),
        SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
        const AppDivider()
      ],
    );
  }

  Widget _groupMemberItem({
    required ContactModel contact,
    required bool hasDivider,
    bool? isAdmin = false,
    bool? isUser = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (!isUser!) {
              Get.toNamed(
                Routes.singleChat,
                arguments: {'chat': null, 'contact': contact},
              );
            }
          },
          child: ContactItemPadding(
            child: Column(
              children: [
                Row(
                  children: [
                    CacheImage(
                      contact.avatar,
                      // size: 40.0,
                    ),
                    SizedBox(width: ResponsiveUtil.ratio(_context, 8.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppDynamicFontText(
                            text: contact.name!,
                            style: TextStyle(
                              fontSize: ResponsiveUtil.ratio(_context, 14.0),
                              fontWeight: FontWeight.bold,
                              color: Variable.colorVar.darkGray,
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: ResponsiveUtil.ratio(_context, 4.0),
                              ),
                              AppDynamicFontText(
                                text: contact.mobile!,
                                style: TextStyle(
                                  fontSize: ResponsiveUtil.ratio(
                                    _context,
                                    12.0,
                                  ),
                                  color: Variable.colorVar.gray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isAdmin!
                        ? Container(
                            padding: EdgeInsets.all(
                              ResponsiveUtil.ratio(_context, 4.0),
                            ),
                            decoration: BoxDecoration(
                              color: Variable.colorVar.lightBlue,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              Variable.stringVar.groupAdmin.tr,
                              style: TextStyle(
                                fontSize: ResponsiveUtil.ratio(_context, 10.0),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                SizedBox(height: ResponsiveUtil.ratio(_context, 10.0)),
              ],
            ),
          ),
        ),
        hasDivider
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtil.ratio(_context, 16.0),
                ),
                child: const AppDivider(),
              )
            : const SizedBox(),
      ],
    );
  }
}
