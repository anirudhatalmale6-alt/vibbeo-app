import 'package:http/http.dart' as http;
import 'package:vibbeo/utils/constant/app_constant.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';

class CreateWatchHistoryApi {
  static Future<void> callApi(
      {required String loginUserId, required String videoId, required String videoUserId, required String videoChannelId, required double watchTimeInMinute}) async {
    AppSettings.showLog("Create Watch History Api Calling...");

    AppSettings.showLog("Create Watch History Api $watchTimeInMinute");

    final uri = Uri.parse(
        "${Constant.baseURL + Constant.createWatchHistory}?userId=$loginUserId&videoId=$videoId&videoUserId=$videoUserId&videoChannelId=$videoChannelId&currentWatchTime=$watchTimeInMinute");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        AppSettings.showLog("Create Watch History Api Response => ${response.body}");
      } else {
        AppSettings.showLog("Create Watch History Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Create Watch History Api Error => $error");
    }
  }
}
