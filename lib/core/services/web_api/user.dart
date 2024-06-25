import 'dart:convert';

import 'package:CeeRoom/core/models/profile_model.dart';
import 'package:CeeRoom/core/services/local_storage/user.dart';
import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:http/http.dart' as http;

class UserApi {
  ApiHelper apiHelper = ApiHelper();

  Future? sendOtp({
    required String mobile,
    required String country,
  }) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.mobile),
      body: {
        "mobile": mobile,
        "country": country,
        "source": "customer",
      },
    );
    return json.decode(res.body);
  }

  Future? loginWithUsername({
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.login),
      body: {
        "identity": username,
        "credential": password,
        "source": "customer",
      },
    );
    return json.decode(res.body);
  }

  Future? verifyOtp({
    required String mobile,
    required String country,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.verifyOtp),
      body: {
        "mobile": mobile,
        "country": country,
        "otp": otp,
        "source": "customer",
      },
    );
    return json.decode(res.body);
  }

  Future? getUserProfileApi() async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.userProfile),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }

  Future? updateDeviceToken(deviceToken) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.updateDeviceToken),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
      body: {
        "device_token": deviceToken,
      },
    );
    return json.decode(res.body);
  }

  Future logout() async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.logout),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
      body: {
        "all_session": '1',
      },
    );
    return json.decode(res.body);
  }

  Future? updateUserProfileApi(ProfileModel profile) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.updateUserProfile),
      body: {
        "first_name": profile.firstName ?? '',
        "last_name": profile.lastName ?? '',
        "phone_number": profile.mobile ?? '',
        "email": profile.email ?? '',
        "gender": profile.gender ?? '',
        "avatar" : profile.avatar ?? '',
      },
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }

  Future? updateMessengerProfileApi() async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.updateMessengerProfile),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }
}
