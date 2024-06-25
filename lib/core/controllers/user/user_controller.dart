import 'dart:async';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/socket/socket_controller.dart';
import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/user_model.dart';
import 'package:CeeRoom/core/services/local_storage/user.dart';
import 'package:CeeRoom/core/services/web_api/user.dart';
import 'package:CeeRoom/main.dart';
import 'package:CeeRoom/utils/app_shared_preferences.dart';
import 'package:CeeRoom/utils/call_navigation.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  Rx<bool> loadingForLogin = false.obs;
  Rx<bool> loadingForOtp = false.obs;
  Rx<bool> splashServerError = false.obs;
  final UserApi _userApi = UserApi();
  Rx<String> selectedCountry = ''.obs;
  late UserModel user;
  String otpCode = "";
  late Timer resendTimer;
  Rx<int> resendSeconds = 0.obs;
  Rx<double> resendContainerWidth = 0.0.obs;
  late GeneralSocketController socketCtl;
  final AppSharedPreferences _pref = AppSharedPreferences();

  List<String> countries = [
    'IR,${Variable.imageVar.iran},+98',
    'US,${Variable.imageVar.unitedStatesOfAmerica},+1',
    'CA,${Variable.imageVar.canada},+1',
    'AE,${Variable.imageVar.unitedArabEmirates},+971',
    'GB,${Variable.imageVar.unitedKingdom},+44',
    'FR,${Variable.imageVar.france},+33',
    'AU,${Variable.imageVar.australia},+61',
    'OM,${Variable.imageVar.oman},+968',
    'QA,${Variable.imageVar.qatar},+974',
    'TR,${Variable.imageVar.turkey},+90',
    'IQ,${Variable.imageVar.iraq},+964',
    'BH,${Variable.imageVar.bahrain},+973',
    'SA,${Variable.imageVar.saudiArabia},+966',
    'RU,${Variable.imageVar.russia},+7',
    'DE,${Variable.imageVar.germany},+49',
    'KZ,${Variable.imageVar.kazakhstan},+7',
    'BE,${Variable.imageVar.belgium},+32',
    'DK,${Variable.imageVar.denmark},+45',
    'GE,${Variable.imageVar.georgia},+955',
    'CH,${Variable.imageVar.china},+86',
  ];
  late List<String> countryFlag;

  @override
  void onInit() {
    super.onInit();
    socketCtl = Get.put(GeneralSocketController());
  }

  void initCounty() {
    countryFlag = [];
    for (String c in countries) {
      countryFlag.add(c.split(',')[1]);
    }
    selectedCountry.value = countries[1];
  }

  void changeCountry(String flagName) {
    final flag = countryFlag.indexOf(flagName);
    selectedCountry.value = countries[flag];
  }

  void loginViaMobile(
    String mobile,
    BuildContext context, {
    bool isResend = false,
  }) async {
    if (isResend) {
      startResendTimer();
      mobile = mobile.substring(selectedCountry.value.split(',')[2].length + 1);
    } else {
      mobile = mobile;
    }
    try {
      if (selectedCountry.value.split(',')[0] == 'IR') {
        if (mobile[0] != '9') {
          BaseWidget.snackBar(
            Variable.stringVar.invalidPhoneNumber.tr,
            context: context,
          );
          return;
        }
      }
      loadingForLogin.value = true;
      final resp = await _userApi.sendOtp(
        mobile: "${selectedCountry.value.split(',')[2]}$mobile",
        country: selectedCountry.value.split(',')[0],
      );
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        if (!isResend) {
          Get.toNamed(
            Routes.verifyOtp,
            arguments: "${selectedCountry.value.split(',')[2]} $mobile",
          );
        }
      } else {
        if (context.mounted) {
          BaseWidget.snackBar(api.error!.message ?? '', context: context);
        }
      }
    } catch (_) {
      if (context.mounted) {
        BaseWidget.snackBar(
          Variable.stringVar.errorHappened.tr,
          context: context,
        );
      }
    } finally {
      loadingForLogin.value = false;
    }
  }

  void loginViaUsername({
    required String userName,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (userName.isEmpty) {
        BaseWidget.snackBar(
          Variable.stringVar.enterUserName.tr,
          context: context,
        );
        return;
      }
      if (password.isEmpty) {
        BaseWidget.snackBar(
          Variable.stringVar.enterPassword.tr,
          context: context,
        );
        return;
      }
      if (password.length < 8) {
        BaseWidget.snackBar(
          Variable.stringVar.incorrectUsernameOrPassword.tr,
          context: context,
        );
        return;
      }
      if (!checkPasswordRegex(password)) {
        BaseWidget.snackBar(
          Variable.stringVar.incorrectUsernameOrPassword.tr,
          context: context,
        );
        return;
      }
      loadingForLogin.value = true;
      final resp = await _userApi.loginWithUsername(
        username: userName,
        password: password,
      );
      if (resp["error"] is String && resp["error"].contains('error')) {
        if (context.mounted) {
          BaseWidget.snackBar(
            Variable.stringVar.incorrectUsernameOrPass.tr,
            context: context,
          );
        }
        return;
      }
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        user = UserModel.fromJson(api.data!);
        _pref.saveToken(user.accessToken!);
        LocalUser.storeUser(UserModel.fromJson(api.data!));
        updateDeviceToken();
        socketCtl.connect(user.accessToken!);
        if (user.name == null || user.name == '') {
          Get.offAllNamed(Routes.register);
        } else {
          Get.offAllNamed(Routes.home);
        }
      } else {
        if (context.mounted) {
          BaseWidget.snackBar(api.error!.message ?? '', context: context);
        }
      }
    } catch (_) {
      if (context.mounted) {
        BaseWidget.snackBar(
          Variable.stringVar.errorHappened.tr,
          context: context,
        );
      }
    } finally {
      loadingForLogin.value = false;
    }
  }

  void verifyOtp(String mobile, BuildContext context) async {
    try {
      loadingForOtp.value = true;
      final resp = await _userApi.verifyOtp(
        mobile: mobile,
        country: selectedCountry.value.split(',')[0],
        otp: otpCode,
      );
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        user = UserModel.fromJson(api.data!);
        LocalUser.storeUser(UserModel.fromJson(api.data!));
        _pref.saveToken(user.accessToken!);
        updateDeviceToken();
        socketCtl.connect(user.accessToken!);
        if (user.name == null || user.name == '') {
          Get.offAllNamed(Routes.register);
        } else {
          Get.offAllNamed(Routes.home);
        }
      } else {
        if (context.mounted) {
          BaseWidget.snackBar(api.error!.message ?? '', context: context);
        }
      }
    } catch (_) {
      if (context.mounted) {
        BaseWidget.snackBar(
          Variable.stringVar.errorHappened.tr,
          context: context,
        );
      }
    } finally {
      loadingForOtp.value = false;
    }
  }

  Future<void> checkUserLogin() async {
    if (LocalUser.hasData()) {
      try {
        user = LocalUser.getUser()!;
        updateDeviceToken();
        final resp = await _userApi.getUserProfileApi();
        Api api = Middleware.resultValidation(resp);
        if (api.result!) {
          socketCtl.connect(user.accessToken!);
          if (appWasClosed && currentCall != null) {
            navigateToCallScreen();
            return;
          }
          if (user.name == null || user.name == '') {
            Get.offAllNamed(Routes.register);
          } else {
            Get.offAllNamed(Routes.home);
          }
        } else {
          finalAction();
        }
      } catch (_) {
        splashServerError.value = true;
      }
    } else {
      Get.offAllNamed(Routes.loginViaMobile);
    }
  }

  void startResendTimer() {
    resendSeconds.value = 60;
    resendContainerWidth.value = 20.0;
    resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (resendSeconds.value == 0) {
          timer.cancel();
        } else {
          resendSeconds.value--;
          resendContainerWidth.value =
              340.0 - (resendSeconds.value / 60.0) * 330.0;
        }
      },
    );
  }

  void cancelTimer() {
    resendTimer.cancel();
    resendContainerWidth.value = 20.0;
  }

  void logout() async {
    try {
      Get.back();
      BaseWidget.snackBar(Variable.stringVar.pleaseWait.tr);
      final resp = await _userApi.logout();
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        LocalUser.eraseUser();
        _pref.clearToken();
        await Get.deleteAll(force: true);
        Get.offAllNamed(Routes.loginViaMobile);
      } else {
        BaseWidget.snackBar(api.error!.message ?? '');
      }
    } catch (e) {
      BaseWidget.snackBar(Variable.stringVar.errorHappened.tr);
    }
  }

  void finalAction() {
    LocalUser.eraseUser();
    Get.offAllNamed(Routes.loginViaMobile);
  }

  void updateDeviceToken() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((deviceToken) {
      _userApi.updateDeviceToken(deviceToken);
    });
  }

  void updateUser(UserModel user) {
    this.user = user;
  }

  // void navigationDirectory() {
  //   if (LocalUser.hasData()) {
  //     try {
  //       user = LocalUser.getUser()!;
  //       socketCtl.connect(user.accessToken!);
  //       if (appWasClosed && currentCall != null) {
  //         navigateToCallScreen();
  //         return;
  //       }
  //     } catch (_) {
  //       checkUserLogin();
  //     }
  //   } else {
  //     Get.offAllNamed(Routes.loginViaMobile);
  //   }
  // }
}
