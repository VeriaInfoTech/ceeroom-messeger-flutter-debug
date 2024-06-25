import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/avatar_container.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[100]!,
      enabled: true,
      child: AppPadding(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AvatarContainer(
              isShimmer: true,
            ),
            SizedBox(width: ResponsiveUtil.ratio(context, 10.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: ResponsiveUtil.ratio(context, 10.0)),
                  Container(
                    width: ResponsiveUtil.ratio(context, 150.0),
                    height: ResponsiveUtil.ratio(context, 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtil.ratio(context, 4.0),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtil.ratio(context, 10.0)),
                  Container(
                    width: double.infinity,
                    height: ResponsiveUtil.ratio(context, 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtil.ratio(context, 4.0),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
