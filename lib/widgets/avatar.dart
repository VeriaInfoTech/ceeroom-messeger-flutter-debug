import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/widgets/avatar_container.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double size;

  const Avatar({
    Key? key,
    this.size = 58.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvatarContainer(
      size: size,
      avatar: DecorationImage(
        image: AssetImage(
          Variable.imageVar.avatar,
        ),
      ),
    );
  }
}
