import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/profile/profile_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditAvatar extends StatelessWidget {
  final double avatarSize;
  final bool inProfile;
  final ProfileController _profileCtl = Get.put(ProfileController());

  EditAvatar({Key? key,  this.avatarSize = 72.0, this.inProfile = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CacheImage(
          _profileCtl.profile.value?.avatar,
          size: avatarSize,
        ),
        Positioned(
          bottom: ResponsiveUtil.ratio(context, 2.0),
          right: ResponsiveUtil.ratio(context, -10.0),
          child: Container(
            padding: EdgeInsets.all(
              ResponsiveUtil.ratio(context, 4.0),
            ),
            decoration: BoxDecoration(
              color: inProfile ? Variable.colorVar.primaryColor :Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              Variable.imageVar.userEdit,
              width: ResponsiveUtil.ratio(context, 22.0),
              height: ResponsiveUtil.ratio(context, 22.0),
              color: inProfile ? Colors.white : Variable.colorVar.primaryColor,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }
}
