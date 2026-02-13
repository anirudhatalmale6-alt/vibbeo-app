import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vibbeo/utils/constant/app_constant.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';

import 'admin_settings_model.dart';

class AdminSettingsApi {
  static AdminSettingsModel? adminSettingsModel;
  static Future<void> callApi() async {
    AppSettings.showLog("Get Admin Settings Api Calling...");

    final uri = Uri.parse(Constant.baseURL + Constant.adminSetting);

    AppSettings.showLog("Get Admin Settings Api Url => $uri");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Get Admin Settings Api Response => ${response.body}");

        adminSettingsModel = AdminSettingsModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Get Admin Settings Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get Admin Settings Api Error => $error");
    }
  }
}
