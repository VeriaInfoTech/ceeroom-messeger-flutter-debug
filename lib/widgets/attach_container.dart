import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/utils/app_media_picker.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttachContainer extends StatelessWidget {
  late BuildContext _context;
  final UserController _userCtl = Get.put(UserController());
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final ValueChanged<FilePickerResult>? onFilePicked;

  AttachContainer({
    Key? key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    this.onFilePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Column(
      children: [
        _attachItem(
          icon: Variable.imageVar.attachCamera,
          title: Variable.stringVar.camera.tr,
          onTap: () async {
            Get.back();
            onCameraPressed.call();
          },
        ),
        _attachItem(
          icon: Variable.imageVar.gallery,
          title: Variable.stringVar.galley.tr,
          onTap: () async {
            Get.back();
            onGalleryPressed.call();
          },
        ),
        if (onFilePicked != null)
          _attachItem(
            icon: Variable.imageVar.document,
            title: Variable.stringVar.document.tr,
            hasDivider: false,
            onTap: () async {
              FilePickerResult? media = await mediaPicker(
                context,
                file,
              );
              if (media != null) {
                Get.back();
                onFilePicked!.call(media);
              }
            },
          ),
        // _attachItem(
        //   icon: Variable.imageVar.voice,
        //   title: Variable.stringVar.voice.tr,
        //   hasDivider: false,
        //   onTap: () {},
        // ),
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
