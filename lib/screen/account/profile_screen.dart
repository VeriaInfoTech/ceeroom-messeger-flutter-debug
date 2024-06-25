import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/profile/profile_controller.dart';
import 'package:CeeRoom/utils/app_media_picker.dart';
import 'package:CeeRoom/utils/crop_image.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/app_icon.dart';
import 'package:CeeRoom/widgets/attach_container.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:CeeRoom/widgets/profile_item.dart';
import 'package:CeeRoom/widgets/retry_button.dart';
import 'package:CeeRoom/widgets/shimmer_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController _profileCtl = Get.put(ProfileController());
  late BuildContext _context;

  ProfileScreen({Key? key}) : super(key: key) {
    _profileCtl.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Obx(
      () => _profileCtl.serverError.value
          ? Center(
              child: RetryButton(
                onTap: () {
                  _profileCtl.getUserProfile();
                },
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  _profileCtl.profile.value == null
                      ? const ShimmerLoading()
                      : _header(),
                  const AppDivider(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // ProfileItem(
                          //   title: Variable.stringVar.notification.tr,
                          //   iconImage: Variable.imageVar.notifications,
                          //   onTap: () {},
                          //   hasArrow: true,
                          // ),
                          ProfileItem(
                            title: Variable.stringVar.settings.tr,
                            iconImage: Variable.imageVar.settings,
                            onTap: () {
                              Get.toNamed(Routes.setting);
                            },
                            hasArrow: true,
                          ),
                          ProfileItem(
                            title: Variable.stringVar.share.tr,
                            iconImage: Variable.imageVar.share,
                            onTap: () {
                              Share.share(
                                'check out my website https://example.com',
                                sharePositionOrigin: Rect.fromPoints(
                                  Offset(
                                    ResponsiveUtil.ratio(context, 500.0),
                                    ResponsiveUtil.ratio(context, 500.0),
                                  ),
                                  const Offset(0, 0),
                                ),
                              );
                            },
                            hasArrow: true,
                          ),
                          ProfileItem(
                            title: Variable.stringVar.privacy.tr,
                            iconImage: Variable.imageVar.lock,
                            onTap: () async {
                              try {
                                await launchUrl(
                                  mode: LaunchMode.externalApplication,
                                  Uri.parse('https://ceeroom.com'),
                                );
                              } catch (e) {
                                BaseWidget.snackBar(
                                  "could not open ${'https://ceeroom.com'}",
                                );
                              }
                            },
                            hasArrow: true,
                          ),
                          ProfileItem(
                            title: Variable.stringVar.faq.tr,
                            iconImage: Variable.imageVar.faq,
                            onTap: () async {
                              try {
                                await launchUrl(
                                  mode: LaunchMode.externalApplication,
                                  Uri.parse('https://ceeroom.com'),
                                );
                              } catch (e) {
                                BaseWidget.snackBar(
                                  "could not open ${'https://ceeroom.com'}",
                                );
                              }
                            },
                            hasArrow: true,
                          ),
                          ProfileItem(
                            title: Variable.stringVar.help.tr,
                            iconImage: Variable.imageVar.help,
                            onTap: () async {
                              try {
                                await launchUrl(
                                  mode: LaunchMode.externalApplication,
                                  Uri.parse('https://ceeroom.com'),
                                );
                              } catch (e) {
                                BaseWidget.snackBar(
                                  "could not open ${'https://ceeroom.com'}",
                                );
                              }
                            },
                            hasArrow: true,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveUtil.ratio(_context, 20.0),
        right: ResponsiveUtil.ratio(_context, 24.0),
        top: ResponsiveUtil.ratio(_context, 34.0),
        bottom: ResponsiveUtil.ratio(_context, 18.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.viewProfile);
            },
            child: CacheImage(
              _profileCtl.profile.value?.avatar,
              size: 72.0,
            ),
          ),
          SizedBox(width: ResponsiveUtil.ratio(_context, 30.0)),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.toNamed(Routes.viewProfile);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDynamicFontText(
                    text: _profileCtl.profile.value!.name == null ||
                            _profileCtl.profile.value!.name == ''
                        ? 'no name'
                        : _profileCtl.profile.value!.name!,
                    style: TextStyle(
                      color: Variable.colorVar.darkGray,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.ratio(_context, 16.0),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
                  Text(
                    Variable.stringVar.viewProfile.tr,
                    style: TextStyle(
                      color: Variable.colorVar.gray,
                      fontSize: ResponsiveUtil.ratio(_context, 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppIcon(
            icon: Variable.imageVar.exit,
            onTap: () => logout(_context),
          )
        ],
      ),
    );
  }
}
