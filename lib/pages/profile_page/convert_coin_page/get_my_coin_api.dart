import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibbeo/pages/profile_page/convert_coin_page/get_my_coin_model.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';
import 'package:vibbeo/utils/constant/app_constant.dart';

class GetMyCoinApi {
  static GetMyCoinModel? getMyCoinModel;

  static Future<GetMyCoinModel?> callApi({required String loginUserId}) async {
    AppSettings.showLog("Get My Coin Api Calling...");

    final uri = Uri.parse("${Constant.baseURL}${Constant.getMyCoin}?userId=$loginUserId");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Get My Coin Api Response => ${response.body}");
        getMyCoinModel = GetMyCoinModel.fromJson(jsonResponse);
        return getMyCoinModel;
      } else {
        AppSettings.showLog("Get My Coin Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get My Coin Api Error => $error");
    }
    return null;
  }
}
