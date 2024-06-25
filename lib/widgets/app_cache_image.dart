import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class CacheImage extends StatelessWidget {
  final String? url;
  final Color? color;
  final BoxFit? boxFit;
  final double size;

  const CacheImage(
    this.url, {
    Key? key,
    this.boxFit,
    this.color,
    this.size = 54.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return url == null
        ? errorWidget()
        : ClipRRect(
            borderRadius:
                BorderRadius.circular(ResponsiveUtil.ratio(context, size)),
            child: CachedNetworkImage(
              imageUrl: url!,
              color: color,
              width: ResponsiveUtil.ratio(context, size),
              height: ResponsiveUtil.ratio(context, size),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  const AppLoading(),
              fit: boxFit ?? BoxFit.fill,
              errorWidget: (context, url, error) => errorWidget(),
            ),
          );
  }

  Widget errorWidget() => Avatar(size: size);
}
