import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/pages/notification_page/notification_model.dart';
import 'package:vibbeo/utils/constant/app_constant.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';

class NotificationApiClass {
  static NotificationModel? _notificationModal;

  static Future<List<Notification>?> callApi() async {
    AppSettings.showLog("Notification Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.notification}?userId=${Database.loginUserId!}");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        _notificationModal = NotificationModel.fromJson(jsonResponse);

        AppSettings.showLog("Notification Api Response => ${response.body}");

        return _notificationModal?.notification;
      } else {
        AppSettings.showLog("Notification Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Notification Api Error => $error");
    }
    return null;
  }
}
