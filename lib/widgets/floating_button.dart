import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final Widget? child;

  const FloatingButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtil.ratio(context, 20.0),
          vertical: ResponsiveUtil.ratio(context, 18.0),
        ),
        decoration: BoxDecoration(
          color: Variable.colorVar.primaryColor,
          borderRadius: BorderRadius.circular(
            ResponsiveUtil.ratio(context, 20.0),
          ),
        ),
        child: child ??
            Image.asset(
              icon,
              width: ResponsiveUtil.ratio(context, 30.0),
              height: ResponsiveUtil.ratio(context, 30.0),
              fit: BoxFit.fill,
              color: Colors.white,
            ),
      ),
    );
  }
}
