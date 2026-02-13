import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibbeo/pages/profile_page/my_wallet_page/get_wallet_history_model.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';
import 'package:vibbeo/utils/constant/app_constant.dart';

class GetWalletHistoryApi {
  static Future<GetWalletHistoryModel?> callApi({
    required String loginUserId,
    required String startDate,
    required String endDate,
  }) async {
    AppSettings.showLog("Get Wallet History Api Calling...");

    final uri = Uri.parse("${Constant.baseURL}${Constant.walletHistory}?userId=$loginUserId&startDate=$startDate&endDate=$endDate");

    AppSettings.showLog("Get Wallet History Api Url => ${uri}");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Get Wallet History Api Response => ${response.body}");

        return GetWalletHistoryModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Get Wallet History Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get Wallet History Api Error => $error");
    }
    return null;
  }
}
