import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/cupertino.dart';

class AppLoading extends StatelessWidget {
  final Color? color;

  const AppLoading({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      color: color,
      radius: ResponsiveUtil.ratio(context, 10.0),
    );
  }
}
