import 'dart:convert';

import 'package:CeeRoom/core/services/local_storage/user.dart';
import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:http/http.dart' as http;

class MessengerProfileApi{
  ApiHelper apiHelper = ApiHelper();

  Future? getProfile({String? section}) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.getMessengerProfile),
      body: json.encode({"section" : section}),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }

  Future? initialContacts({required String contacts}) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.initContacts),
      body: json.encode({"mobiles" : contacts}),
      headers: {
        'token': LocalUser.getUser()!.accessToken!,
      },
    );
    return json.decode(res.body);
  }
}