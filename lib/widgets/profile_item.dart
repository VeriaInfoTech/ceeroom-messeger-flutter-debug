import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:flutter/material.dart';

class ProfileItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? iconImage;
  final String? name;
  final VoidCallback onTap;
  final bool hasDivider;
  final bool hasArrow;

  const ProfileItem({
    Key? key,
    this.icon,
    required this.title,
    this.iconImage,
    required this.onTap,
    this.hasDivider = true,
    this.hasArrow = false, this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtil.ratio(context, 24.0),
              vertical: ResponsiveUtil.ratio(context, 20.0),
            ),
            child: Row(
              children: [
                icon != null
                    ? Icon(
                        icon,
                        size: ResponsiveUtil.ratio(context, 26.0),
                      )
                    : Image.asset(
                        iconImage!,
                        color: Colors.black,
                        width: ResponsiveUtil.ratio(context, 24.0),
                        height: ResponsiveUtil.ratio(context, 24.0),
                      ),
                SizedBox(width: ResponsiveUtil.ratio(context, 26.0)),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Variable.colorVar.darkGrayish,
                          fontSize: ResponsiveUtil.ratio(context, 16.0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtil.ratio(context, 4.0)),
                      name != null ?
                      AppDynamicFontText(
                        text: name!,
                        style: TextStyle(
                          color: Variable.colorVar.darkGrayish,
                          fontSize: ResponsiveUtil.ratio(context, 14.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ): const SizedBox(),
                    ],
                  ),
                ),
                hasArrow
                    ? Icon(
                        Icons.chevron_right,
                        size: ResponsiveUtil.ratio(context, 26.0),
                      )
                    : const SizedBox(),
                // Image.asset(name)
              ],
            ),
          ),
          hasDivider ? const AppDivider() : const SizedBox(),
        ],
      ),
    );
  }
}
