import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String title;
  final String? icon;
  final bool primary;
  final double borderRadius;
  final double width;
  final double height;
  final double fontSize;
  final double iconSize;
  final Color? iconColor;
  final Color? bgColor;
  final Color textColor;
  final VoidCallback? onTap;

  const AppButton({
    Key? key,
    required this.title,
    this.onTap,
    this.icon,
    this.primary = true,
    this.borderRadius = 16.0,
    this.width = 360.0,
    this.height = 44.0,
    this.fontSize = 16.0,
    this.iconSize = 32.0,
    this.iconColor,
    this.bgColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveUtil.ratio(context, height),
      width: ResponsiveUtil.ratio(context, width),
      decoration: BoxDecoration(
        color: bgColor ??
            (primary ? Variable.colorVar.primaryColor : Variable.colorVar.darkGray),
        borderRadius: BorderRadius.circular(
          ResponsiveUtil.ratio(context, borderRadius),
        ),
      ),
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.ratio(context, borderRadius),
              ),
            ),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtil.ratio(context, 15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: ResponsiveUtil.ratio(context, fontSize),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // icon != null
              //     ? AppIcon(
              //   icon: icon!,
              //   size: Variable.ratio * iconSize,
              //   color: iconColor,
              // )
              //     : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
