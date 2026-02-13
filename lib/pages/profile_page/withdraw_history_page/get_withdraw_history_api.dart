import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibbeo/pages/profile_page/withdraw_history_page/get_withdraw_history_model.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';
import 'package:vibbeo/utils/constant/app_constant.dart';

class GetWithdrawHistoryApi {
  static Future<GetWithdrawHistoryModel?> callApi({
    required String loginUserId,
    required String startDate,
    required String endDate,
  }) async {
    AppSettings.showLog("Get Withdraw History Api Calling...");

    final uri = Uri.parse("${Constant.baseURL}${Constant.withdrawHistory}?userId=$loginUserId&startDate=$startDate&endDate=$endDate");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Get Withdraw History Api Response => ${response.body}");

        return GetWithdrawHistoryModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Get Withdraw History Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get Withdraw History Api Error => $error");
    }
    return null;
  }
}
