import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vibbeo/pages/login_related_page/login_page/login_model.dart';
import 'package:vibbeo/utils/constant/app_constant.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';

class LoginApi {
  static Future<LoginModel?> callApi(String email, String password, int loginType) async {
    AppSettings.showLog("Login Api Calling...");

    final uri = Uri.parse(Constant.baseURL + Constant.checkUser);

    final headers = {"key": Constant.secretKey, "Content-Type": "application/json; charset=UTF-8"};

    final body = json.encode({'email': email, 'loginType': loginType, 'password': password});

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        AppSettings.showLog("Login Api Response => ${response.body}");
        final jsonResponse = json.decode(response.body);
        return LoginModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog(">>>>> Login Api StateCode Error <<<<<");
      }
    } catch (error) {
      AppSettings.showLog("Login Api Error => $error");
    }
    return null;
  }
}
