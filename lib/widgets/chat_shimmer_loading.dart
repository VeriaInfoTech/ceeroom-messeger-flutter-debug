import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/avatar_container.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmerLoading extends StatelessWidget {
  final int index;

  const ChatShimmerLoading({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isEven = index % 2 == 0;
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[100]!,
      enabled: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const AvatarContainer(
            isShimmer: true,
            size: 40.0,
          ),
          Container(
            height: isEven
                ? ResponsiveUtil.ratio(context, 100.0)
                : ResponsiveUtil.ratio(context, 70.0),
            width: isEven
                ? ResponsiveUtil.ratio(context, 200.0)
                : ResponsiveUtil.ratio(context, 150.0),
            // width: 200.0,
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUtil.ratio(context, 10.0),
              vertical: ResponsiveUtil.ratio(context, 8.0),
            ),
            padding: EdgeInsets.all(ResponsiveUtil.ratio(context, 8.0)),
            decoration: BoxDecoration(
              borderRadius: messageBorderRadius(true, context),
              color: Variable.colorVar.lightBlue,
            ),
          )
        ],
      ),
    );
  }
}
