import 'dart:ui';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/screen/bottom_nav.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_button.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseWidget {
  static Future<dynamic> generalDialog({
    required String icon,
    required String title,
    required String desc,
    required BuildContext context,
    String? confirmBtnTxt,
    VoidCallback? confirmBtnOnTap,
    VoidCallback? cancelBtnOnTap,
    String? cancelBtnDesc,
    Color? iconColor,
    double iconSize = 24,
    bool isDismissible = true,
  }) async {
    final res = await Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Dialog(
          backgroundColor: Variable.colorVar.lightGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.ratio(context, 16.0),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtil.ratio(context, 24.0),
              horizontal: ResponsiveUtil.ratio(context, 24.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  icon,
                  width: ResponsiveUtil.ratio(context, iconSize),
                  height: ResponsiveUtil.ratio(context, iconSize),
                  fit: BoxFit.fill,
                  color: iconColor,
                ),
                SizedBox(height: ResponsiveUtil.ratio(context, 24.0)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.ratio(context, 18.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveUtil.ratio(context, 24.0)),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: ResponsiveUtil.ratio(context, 14.0),
                      fontWeight: FontWeight.w400,
                      color: Variable.colorVar.heavyGray),
                ),
                SizedBox(height: ResponsiveUtil.ratio(context, 24.0)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      width: 100.0,
                      title: cancelBtnDesc ?? Variable.stringVar.cancel.tr,
                      bgColor: Colors.transparent,
                      textColor: Colors.black,
                      fontSize: 12.0,
                      onTap: cancelBtnOnTap ??
                          () {
                            Get.back();
                          },
                    ),
                    if (confirmBtnTxt != null) ...[
                      SizedBox(width: ResponsiveUtil.ratio(context, 12.0)),
                      AppButton(
                        width: 100.0,
                        title: confirmBtnTxt,
                        onTap: confirmBtnOnTap,
                        fontSize: 12.0,
                      ),
                    ],
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: isDismissible,
    );
    return res;
  }

  static Future<dynamic> inviteDialog({
    required String name,
    required Widget content,
    required BuildContext context,
    VoidCallback? confirmBtnOnTap,
    bool isDismissible = true,
  }) async {
    final res = await Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Dialog(
          backgroundColor: Variable.colorVar.lightGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.ratio(context, 16.0),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtil.ratio(context, 24.0),
              horizontal: ResponsiveUtil.ratio(context, 24.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${Variable.stringVar.message.tr} $name',
                  style: TextStyle(
                    fontSize: ResponsiveUtil.ratio(context, 18.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveUtil.ratio(context, 24.0)),
                content,
                SizedBox(height: ResponsiveUtil.ratio(context, 24.0)),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(

                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(
                        width: ResponsiveUtil.ratio(context, 100.0),
                        title: Variable.stringVar.cancel.tr,
                        bgColor: Colors.transparent,
                        textColor: Variable.colorVar.primaryColor,
                        fontSize: ResponsiveUtil.ratio(context, 12.0),
                        onTap: () {
                          Get.back();
                        },
                      ),
                      AppButton(
                        width: ResponsiveUtil.ratio(context, 110.0),
                        title: Variable.stringVar.continueForm.tr,
                        bgColor: Colors.transparent,
                        textColor: Variable.colorVar.primaryColor,
                        onTap: confirmBtnOnTap,
                        fontSize: ResponsiveUtil.ratio(context, 12.0),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: isDismissible,
    );
    return res;
  }

  static snackBar(String message, {BuildContext? context}) {
    Get.showSnackbar(
      GetSnackBar(
        mainButton: Padding(
          padding: EdgeInsets.only(
            right: ResponsiveUtil.ratio(context ?? appContext, 8.0),
          ),
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.close,
              color: Colors.black,
              size: ResponsiveUtil.ratio(context ?? appContext, 20.0),
            ),
          ),
        ),
        boxShadows: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 0.5,
            blurRadius: 2.0,
          )
        ],
        messageText: Text(
          message,
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveUtil.ratio(context ?? appContext, 14.0),
          ),
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Variable.colorVar.lightRed,
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtil.ratio(context ?? appContext, 16.0),
          vertical: ResponsiveUtil.ratio(context ?? appContext, 16.0),
        ),
        borderRadius: 8.0,
      ),
    );
  }

  static Future attachBottomSheet({
    required Widget child,
    required BuildContext context,
  }) async {
    final res = await Get.bottomSheet(
      AppPadding(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtil.ratio(context, 16.0),
                ),
                color: Colors.white,
              ),
              child: child,
            ),
            SizedBox(height: ResponsiveUtil.ratio(context, 14.0)),
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtil.ratio(context, 12.0),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtil.ratio(context, 16.0),
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Variable.stringVar.cancel.tr,
                      style: TextStyle(
                        color: Variable.colorVar.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtil.ratio(context, 14.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtil.ratio(context, 32.0)),
          ],
        ),
      ),
    );
    return res;
  }
}
