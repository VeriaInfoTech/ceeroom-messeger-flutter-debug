import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/profile/profile_controller.dart';
import 'package:CeeRoom/utils/app_media_picker.dart';
import 'package:CeeRoom/utils/crop_image.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_back_button.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/attach_container.dart';
import 'package:CeeRoom/widgets/avatar_container.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:CeeRoom/widgets/edit_profile_avatar.dart';
import 'package:CeeRoom/widgets/group_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String? avatar;
  final bool? isGroup;
  final bool? isEditProfile;
  final ProfileController _profileCtl = Get.put(ProfileController());

  ProfileHeader({
    Key? key,
    required this.name,
    required this.phoneNumber,
    this.avatar,
    this.isGroup = false,
    this.isEditProfile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppPadding(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              SizedBox(width: ResponsiveUtil.ratio(context, 80.0)),
              Column(
                children: [
                  isGroup!
                      ? const AvatarContainer(
                          icon: GroupAvatar(size: 80.0),
                          size: 100.0,
                        )
                      : isEditProfile!
                          ? Obx(
                              () => _profileCtl.updateAvatarLoading.value
                                  ? SizedBox(
                                      width: ResponsiveUtil.ratio(context, 100.0),
                                      height:
                                          ResponsiveUtil.ratio(context, 100.0),
                                      child: const Center(
                                        child: AppLoading(),
                                      ),
                                    )
                                  : EditProfileAvatar(avatar: avatar ?? ''),
                            )
                          : CacheImage(
                              avatar,
                              size: 100.0,
                            ),
                  SizedBox(height: ResponsiveUtil.ratio(context, 8.0)),
                  AppDynamicFontText(
                    text: name,
                    style: TextStyle(
                      color: Variable.colorVar.darkGray,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.ratio(context, 16.0),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtil.ratio(context, 8.0)),
                  Text(
                    phoneNumber,
                    style: TextStyle(
                      color: Variable.colorVar.gray,
                      fontSize: ResponsiveUtil.ratio(context, 14.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const AppDivider(),
      ],
    );
  }
}
