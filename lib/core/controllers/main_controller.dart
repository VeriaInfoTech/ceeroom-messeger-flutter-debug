import 'dart:async';
import 'dart:io';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/app_info_model.dart';
import 'package:CeeRoom/core/models/version_model.dart';
import 'package:CeeRoom/core/services/web_api/version.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MainController extends GetxController {
  Rx<bool> isSearchable = false.obs;
  Future<bool> versionCheck(
    VoidCallback onErr,
    BuildContext context,
  ) async {
    try {

      final AppInfo appInfo = AppInfo();
      appInfo.buildNumber = buildNumber;
      appInfo.platform = Platform.operatingSystem;
      appInfo.marketPlace = marketPlace;
      appInfo.applicant = applicant;

      final resp = await VersionApi().checkVersion(appInfo);
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        VersionModel version = VersionModel.fromJson(api.data!);
        setCallConfiguration(version.stun ?? '');
        ///TODO:handle this by  navigationDirector method
        if ((version.lastVersion != appInfo.buildNumber)&&false) {
          if (context.mounted) {
            await BaseWidget.generalDialog(
              context: context,
              icon: Variable.imageVar.warning,
              title: version.title!,
              desc: version.message!,
              iconSize: 36.0,
              confirmBtnTxt: version.buttonTitle!,
              cancelBtnDesc: version.isForce!
                  ? Variable.stringVar.exit.tr
                  : Variable.stringVar.cancel.tr,
              confirmBtnOnTap: () {
                _openStore(version.url!);
              },
              cancelBtnOnTap: () {
                if (version.isForce!) {
                  exit(0);
                } else {
                  Get.back();
                }
              },
              isDismissible: !version.isForce!,
            );
          }
        }
      }
      return true;
    } catch (error) {
      onErr();
      return false;
    }
  }

  void _openStore(url) async {
    launch(url);
  }
}
