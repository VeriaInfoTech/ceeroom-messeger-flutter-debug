import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AppPadding extends StatelessWidget {
  final Widget child;

  const AppPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtil.ratio(context, 16.0),
        ResponsiveUtil.ratio(context, 10.0),
        ResponsiveUtil.ratio(context, 16.0),
        ResponsiveUtil.ratio(context, 10.0),
      ),
      child: child,
    );
  }
}
