import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AppCallButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color color;
  final Color iconColor;
  final String? image;
  final IconData? icon;

  const AppCallButton({
    Key? key,
    required this.onTap,
    this.size = 14.0,
    this.iconSize = 20,
    this.color = const Color(0xff99D5FF),
    this.image,
    this.icon,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtil.ratio(context, 40),
        ),
        padding: EdgeInsets.all(
          ResponsiveUtil.ratio(context, size),
        ),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: image == null
            ? Icon(
                icon,
                color: iconColor,
                size: ResponsiveUtil.ratio(context, iconSize),
              )
            : Image.asset(
                image!,
                width: ResponsiveUtil.ratio(context, iconSize),
                height: ResponsiveUtil.ratio(context, iconSize),
                color: iconColor,
              ),
      ),
    );
  }
}
