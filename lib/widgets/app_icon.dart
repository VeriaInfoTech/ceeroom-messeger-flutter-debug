import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final double iconSize;
  final VoidCallback? onTap;

  const AppIcon({
    Key? key,
    required this.icon,
    this.iconSize = 28.0,
    this.onTap,
    this.iconColor = const Color(0xff0045F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Image.asset(
        icon,
        color: iconColor,
        width: ResponsiveUtil.ratio(context, iconSize),
        height: ResponsiveUtil.ratio(context, iconSize),
      ),
    );
  }
}
