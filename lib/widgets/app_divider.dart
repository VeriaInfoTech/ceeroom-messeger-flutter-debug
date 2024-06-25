import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: ResponsiveUtil.ratio(context, 1.0),
      height: 0.0,
    );
  }
}
