import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class CallButtonContainer extends StatelessWidget {
  final Widget child;

  const CallButtonContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: ResponsiveUtil.ratio(context, 8.0),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            ResponsiveUtil.ratio(context, 18.0),
          ),
          topRight: Radius.circular(
            ResponsiveUtil.ratio(context, 18.0),
          ),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: const Color(0x00606060).withOpacity(0.5),
        //     offset: const Offset(0, -1),
        //     blurRadius: 5,
        //     spreadRadius: 1,
        //   )
        // ],
        color: Colors.grey.withOpacity(0.3),
      ),
      child: child,
    );
  }
}
