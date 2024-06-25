import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class GradientScreen extends StatelessWidget {
  final Widget child;
  const GradientScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 800,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Variable.colorVar.lightBlue.withOpacity(0.6),
            Variable.colorVar.primaryColor,
          ],
          stops: [
            ResponsiveUtil.ratio(context, 0.1),
            ResponsiveUtil.ratio(context, 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
