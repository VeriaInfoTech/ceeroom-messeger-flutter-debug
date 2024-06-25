import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class GroupAvatar extends StatelessWidget {
  final double size;
  const GroupAvatar({super.key, this.size = 44.0});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.people_rounded,
      color: Colors.white,
      size: ResponsiveUtil.ratio(context, size),
    );
  }
}
