import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/app_media_picker.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SelectVideoOrPicBottomSheet extends StatelessWidget {
  final bool isCamera;
  late BuildContext _context;
  final ValueChanged<XFile> onImagedPressed;
  final ValueChanged<XFile> onVideoPressed;


  SelectVideoOrPicBottomSheet({
    Key? key,
    this.isCamera = false,
    required this.onImagedPressed,
    required this.onVideoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Column(
      children: [
        _attachItem(
          icon: Variable.imageVar.gallery,
          title: Variable.stringVar.image.tr,
          onTap: () async {
            XFile? media;
            if (isCamera) {
              media = await mediaPicker(
                context,
                imageCamera,
              );
            } else {
              media = await mediaPicker(
                context,
                imageGallery,
              );
            }
            if (media != null) {
              Get.back();
              onImagedPressed.call(media);
            }
          },
        ),
        _attachItem(
          icon: Variable.imageVar.videoCam,
          title: Variable.stringVar.video.tr,
          onTap: () async {
            XFile? media;
            if (isCamera) {
              media = await mediaPicker(
                context,
                videoCamera,
              );
            } else {
              media = await mediaPicker(
                context,
                videoGallery,
              );
            }
            if (media != null) {
              Get.back();
              onVideoPressed.call(media);
            }
          },
        ),
      ],
    );
  }

  Widget _attachItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool hasDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtil.ratio(_context, 14.0),
              horizontal: ResponsiveUtil.ratio(_context, 30.0),
            ),
            child: Row(
              children: [
                Image.asset(
                  icon,
                  width: ResponsiveUtil.ratio(_context, 24.0),
                  height: ResponsiveUtil.ratio(_context, 24.0),
                  color: Colors.black,
                ),
                SizedBox(width: ResponsiveUtil.ratio(_context, 24.0)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.ratio(_context, 14.0),
                  ),
                ),
              ],
            ),
          ),
          hasDivider ? const AppDivider() : const SizedBox(),
        ],
      ),
    );
  }
}
