import 'dart:convert';

import 'package:CeeRoom/core/models/profile_model.dart';
import 'package:CeeRoom/core/models/user_model.dart';
import 'package:get_storage/get_storage.dart';

class LocalUser {
  static final userBox = GetStorage();

  static bool hasData({String boxName = 'user'}) {
    if (boxName == 'user') {
      return userBox.read('user') != null;
    }
    return userBox.read('profile') != null;
  }

  static storeUser(UserModel user) {
    userBox.write('user', user.toJson());
  }

  static UserModel? getUser() {
    try {
      return hasData()
          ? UserModel.fromJson(jsonDecode(userBox.read('user')))
          : null;
    } catch (_) {
      return null;
    }
  }

  static storeProfile(ProfileModel profile) {
    userBox.write('profile', profile.toJson());
  }

  static ProfileModel? getProfile() {
    try {
      return hasData()
          ? ProfileModel.fromJson(jsonDecode(userBox.read('profile')))
          : null;
    } catch (_) {
      return null;
    }
  }

  static eraseUser() {
    try {
      userBox.erase();
      return true;
    } catch (_) {
      return false;
    }
  }
}
