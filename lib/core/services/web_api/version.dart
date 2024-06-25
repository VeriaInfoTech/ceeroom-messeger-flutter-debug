import 'dart:convert';

import 'package:CeeRoom/core/models/app_info_model.dart';
import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:http/http.dart' as http;

class VersionApi {
  ApiHelper apiHelper = ApiHelper();

  Future checkVersion(AppInfo info) async {
    final res = await http.post(
      Uri.parse(apiHelper.apiUri + apiHelper.settingVersionCheck),
      body: {
        'version': info.buildNumber,
        'market_place': info.marketPlace,
        'applicant': info.applicant,
        'platform': info.platform,
      },
    );
    return json.decode(res.body);
  }
}
