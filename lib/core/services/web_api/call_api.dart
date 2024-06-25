import 'dart:convert';

import 'package:CeeRoom/core/models/call_model.dart';
import 'package:CeeRoom/core/services/local_storage/user.dart';
import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:CeeRoom/utils/app_shared_preferences.dart';
import 'package:http/http.dart' as http;

class CallApi {
  ApiHelper apiHelper = ApiHelper();
  final AppSharedPreferences _pref = AppSharedPreferences();

  Future? requestCall(CallModel call) async {
    try {
      final res = await http.post(
        Uri.parse(apiHelper.apiUri + apiHelper.requestCall),
        body: json.encode(call.toJson()),
        headers: {
          'token':
          LocalUser
              .getUser()
              ?.accessToken ?? (await _pref.getToken())!,
        },
      );
      return json.decode(res.body);
    }catch(e){
    };
  }

  Future? updateCall(CallModel call) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.updateCall),
      body: json.encode(call.toJson()),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }
}
