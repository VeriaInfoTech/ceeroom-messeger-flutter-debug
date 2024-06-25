import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBackButton extends StatelessWidget {
  final double size;
  final VoidCallback? moreBackAction;

  const AppBackButton({
    Key? key,
    this.size = 32.0,
    this.moreBackAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        moreBackAction?.call();
        Get.back();
      },
      child: Icon(
        Icons.keyboard_arrow_left,
        size: ResponsiveUtil.ratio(context, size),
      ),
    );
  }
}
