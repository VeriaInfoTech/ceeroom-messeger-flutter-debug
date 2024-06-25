import 'dart:math';
import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_back_button.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:flutter/material.dart';
import 'avatar_container.dart';
import 'group_avatar.dart';

class SliverHeader extends SliverPersistentHeaderDelegate {
  double screenWidth;
  Tween<double>? profilePicTranslateTween;
  final String name;
  final String description;

  SliverHeader(this.screenWidth, this.name, this.description) {
    profilePicTranslateTween =
        Tween<double>(begin: screenWidth / 2 - 45 - 40 + 15, end: 30.0);
  }

  static final appBarColorTween =
      ColorTween(begin: Colors.white, end: Colors.white);

  static final appbarIconColorTween =
      ColorTween(begin: Colors.grey[800], end: Colors.white);

  static final phoneNumberTranslateTween = Tween<double>(begin: 20.0, end: 0.0);

  static final phoneNumberFontSizeTween = Tween<double>(begin: 20.0, end: 16.0);

  static final profileImageRadiusTween = Tween<double>(begin: 3.5, end: 1.0);

  late BuildContext _context;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    _context = context;
    final relativeScroll = min(shrinkOffset, 45) / 45;
    final relativeScroll70px = min(shrinkOffset, 70) / 85;

    return Container(
      color: appBarColorTween.transform(relativeScroll),
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.ratio(_context, 5.0),
      ),
      child: Stack(
        children: [
          Stack(
            children: [
              Positioned(
                top: ResponsiveUtil.ratio(_context, 10.0),
                left: ResponsiveUtil.ratio(_context, 5.0),
                child: const AppBackButton(),
              ),
              Positioned(
                left: ResponsiveUtil.ratio(_context, 115.0),
                child: displayDescription(
                  relativeScroll70px,
                  name,
                  description
                ),
              ),
              Positioned(
                top: ResponsiveUtil.ratio(_context, 5.0),
                left: profilePicTranslateTween!.transform(relativeScroll70px),
                child: displayProfilePicture(relativeScroll70px),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget displayProfilePicture(double relativeFullScrollOffset) {
    return Transform(
      transform: Matrix4.identity()
        ..scale(
          profileImageRadiusTween.transform(relativeFullScrollOffset),
        ),
      child: Padding(
        padding:  EdgeInsets.only(left: ResponsiveUtil.ratio(_context, 4.0)),
        child: const AvatarContainer(
          icon: GroupAvatar(
            size: 28.0,
          ),
          size: 32.0,
        ),
      ),
    );
  }

  Widget displayDescription(double relativeFullScrollOffset, String name , String description) {
    if (relativeFullScrollOffset >= 0.8) {
      return Transform(
        transform: Matrix4.identity()
          ..translate(
            0.0,
            phoneNumberTranslateTween
                .transform((relativeFullScrollOffset - 0.8) * 32),
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDynamicFontText(
              text: name,
              style: TextStyle(
                color: Variable.colorVar.darkGray,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.ratio(_context, 16.0),
              ),
            ),
            Text(
              description,
              style: TextStyle(
                color: Variable.colorVar.gray,
                fontSize: ResponsiveUtil.ratio(_context, 14.0),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(SliverHeader oldDelegate) {
    return true;
  }
}
