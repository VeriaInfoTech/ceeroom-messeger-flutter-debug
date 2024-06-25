import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/profile_model.dart';
import 'package:CeeRoom/core/services/local_storage/user.dart';
import 'package:CeeRoom/core/services/web_api/user.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  Rx<bool> updateProfileLoading = false.obs;
  Rx<bool> updateAvatarLoading = false.obs;
  Rx<bool> serverError = false.obs;
  Rxn<ProfileModel> profile = Rxn<ProfileModel>();
  final UserApi _userApi = UserApi();
  List<String> gender = [
    'Male',
    'Female',
  ];

  Rx<String> userGender = ''.obs;

  void updateTextField({
    required Map<String, TextEditingController> controllers,
  }) {
    for (final key in controllers.keys) {
      switch (key) {
        case 'first name':
          controllers[key]!.text = profile.value!.firstName ?? '';
          break;
        case 'last name':
          controllers[key]!.text = profile.value!.lastName ?? '';
          break;
        case 'phone number':
          controllers[key]!.text = profile.value!.mobile ?? '';
          break;
        case 'email':
          controllers[key]!.text = profile.value!.email ?? '';
          break;
      }
    }
    if (profile.value!.gender != null && profile.value!.gender != '') {
      userGender.value = profile.value!.gender!;
    }
  }

  Future<void> getUserProfile({bool isUpdateAvatar = false,}) async {
    try {
      if (isUpdateAvatar) {
        updateAvatarLoading.value = true;
      }
      serverError.value = false;
      final resp = await _userApi.getUserProfileApi();
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        if (isUpdateAvatar) {
          updateAvatarLoading.value = false;
        }
        profile.value = ProfileModel.fromJson(api.data!);
      }
    } catch (_) {
      if (isUpdateAvatar) {
        updateAvatarLoading.value = false;
        BaseWidget.snackBar(Variable.stringVar.errorHappened.tr);
      }
      serverError.value = true;
    }
  }

  Future updateUserProfile(
    Map<String, dynamic> data, {
    required bool isRegister,
    VoidCallback? onSuccessRegister,
    BuildContext? context,
  }) async {
    ProfileModel newProfile;
    try {
      updateProfileLoading.value = true;
        newProfile = ProfileModel(
          firstName: data["first_name"],
          lastName: data["last_name"],
          mobile: data['phone_number'],
          email: data['email'],
          gender: data["gender"],
          avatar: profile.value?.avatar,
        );
      final resp = await _userApi.updateUserProfileApi(newProfile);
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        final profileApi = ProfileModel.fromJson(api.data!);
        final user = LocalUser.getUser();
        LocalUser.storeUser(user!.copyWith(name: profileApi.name));
        profile.value = profileApi;
        if (isRegister) {
            onSuccessRegister?.call();
            Get.offAllNamed(Routes.home);
        } else {
          BaseWidget.snackBar(
            Variable.stringVar.profileUpdateSuccessfully.tr,
          );
        }
        return 'done';
      } else {
        BaseWidget.snackBar(
          api.error!.email ?? api.error!.mobile ?? api.error!.message ?? '',
          context: context,
        );
      }
    } catch (_) {
      BaseWidget.snackBar(
        Variable.stringVar.errorHappened.tr,
        context: context,
      );
    } finally {
        updateProfileLoading.value = false;
    }
  }

  Future<void> updateMessengerProfile() async {
    try {
      await _userApi.updateMessengerProfileApi();
    } catch (_) {
      BaseWidget.snackBar(Variable.stringVar.errorHappened.tr);
    }
  }
}
