
import 'dart:io';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/media/media_controller.dart';
import 'package:CeeRoom/core/controllers/profile/profile_controller.dart';
import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:CeeRoom/utils/app_media_picker.dart';
import 'package:CeeRoom/utils/crop_image.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/attach_container.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class EditProfileAvatar extends StatefulWidget {
  final String avatar;
  final bool isRegister;

  const EditProfileAvatar({
    super.key,
    required this.avatar,
    this.isRegister = false,
  });

  @override
  State<EditProfileAvatar> createState() => _EditProfileAvatarState();
}

class _EditProfileAvatarState extends State<EditProfileAvatar> {
  double progress = 1;
  bool isProgressing = false;
  final MediaController _mediaCtl = MediaController();
  ApiHelper apiHelper = ApiHelper();
  final ProfileController _profileCtl = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        BaseWidget.attachBottomSheet(
          child: AttachContainer(
            onCameraPressed: () async {
              XFile? image = await mediaPicker(
                context,
                imageCamera,
              );
              if (image != null) {
                final cImage = await cropImage(image.path);
                _mediaCtl.uploadMedia(
                    file: File(cImage!.path),
                    url: apiHelper.uploadAvatar,
                    onSuccess: (media) {
                      setState(() {
                        isProgressing = false;
                      });
                      _profileCtl.getUserProfile(isUpdateAvatar: true);
                    },
                    onProgress: (p) {
                      setState(() {
                        isProgressing = true;
                        progress = p;
                      });
                    },
                    onError: () {
                      BaseWidget.snackBar(
                          Variable.stringVar.errorHappened.tr,
                          context: context);
                      setState(() {
                        isProgressing = false;
                      });
                    });
              }
              // _profileCtl.uploadAvtar();
            },
            onGalleryPressed: () async {
              XFile? image = await mediaPicker(
                context,
                imageGallery,
              );
              if (image != null) {
                final cImage = await cropImage(image.path);
                _mediaCtl.uploadMedia(
                    file: File(cImage!.path),
                    url: apiHelper.uploadAvatar,
                    onSuccess: (media) {
                      setState(() {
                        isProgressing = false;
                      });
                      _profileCtl.getUserProfile(isUpdateAvatar: true);
                    },
                    onProgress: (p) {
                      setState(() {
                        isProgressing = true;
                        progress = p;
                      });
                    },
                    onError: () {
                      BaseWidget.snackBar(
                          Variable.stringVar.errorHappened.tr,
                          context: context);
                      setState(() {
                        isProgressing = false;
                      });
                    });
              }
            },
          ),
          context: context,
        );
        // Get.toNamed(Routes.uploadAvtar);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          progress < 1
              ? Container(
                  width: ResponsiveUtil.ratio(context, 100.0),
                  height: ResponsiveUtil.ratio(context, 100.0),
                  padding: EdgeInsets.all(
                    ResponsiveUtil.ratio(context, 24.0),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: CircularProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Variable.colorVar.primaryColor,
                    ),
                  ),
                )
              : progress == 1 && isProgressing == true
                  ? SizedBox(
                      width: ResponsiveUtil.ratio(context, 100.0),
                      height: ResponsiveUtil.ratio(context, 100.0),
                      child: const Center(
                        child: AppLoading(),
                      ),
                    )
                  : CacheImage(
                      widget.avatar,
                      size: 100.0,
                    ),
          Positioned(
            bottom: 2,
            right: ResponsiveUtil.ratio(context, -10.0),
            child: Container(
              padding: EdgeInsets.all(ResponsiveUtil.ratio(context, 4.0)),
              decoration: BoxDecoration(
                color: Variable.colorVar.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                Variable.imageVar.userEdit,
                width: ResponsiveUtil.ratio(context, 22.0),
                height: ResponsiveUtil.ratio(context, 22.0),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mediaCtl.cancel();
    super.dispose();
  }
}
