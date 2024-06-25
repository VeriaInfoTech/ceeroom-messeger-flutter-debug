import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:flutter/material.dart';

class AppSelectedContact extends StatelessWidget {
  final String? avatar;
  final String name;
  final VoidCallback onTap;

  const AppSelectedContact({
    Key? key,
    required this.avatar,
    required this.name,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.ratio(context, 8.0),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                CacheImage(
                  avatar,
                  size: 50.0,
                ),
                AppDynamicFontText(
                  text: name,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.ratio(context, 10.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Positioned(
              top: ResponsiveUtil.ratio(context, 2.0),
              right: ResponsiveUtil.ratio(context, -4.0),
              child: Container(
                width: ResponsiveUtil.ratio(context, 18.0),
                height: ResponsiveUtil.ratio(context, 18.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Variable.colorVar.mediumGray,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: ResponsiveUtil.ratio(context, 14.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
