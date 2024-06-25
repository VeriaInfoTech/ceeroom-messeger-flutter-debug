import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AvatarContainer extends StatelessWidget {
  final double size;
  final DecorationImage? avatar;
  final bool isShimmer;
  final Widget? icon;

  const AvatarContainer({
    Key? key,
    this.size = 58.0,
    this.avatar,
    this.isShimmer = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveUtil.ratio(context, size),
      height: ResponsiveUtil.ratio(context, size),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isShimmer ? Colors.white : Colors.grey.withOpacity(0.6),
        image: avatar,
      ),
      child: icon ?? const SizedBox(),
    );
  }
}
