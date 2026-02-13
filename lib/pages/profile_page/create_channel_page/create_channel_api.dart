import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/utils/constant/app_constant.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';

class CreateChannelApi {
  static bool? status;
  static String? message;

  static Future<void> callApi() async {
    message = "";
    AppSettings.showLog("Create Channel Api Calling...");

    final uri = Uri.parse('${Constant.baseURL + Constant.createChannel}?userId=${Database.loginUserId}&isChannel=false');

    final headers = {"key": Constant.secretKey, "Content-Type": 'application/json'};

    final body = json.encode({
      "fullName": AppSettings.nameController.text,
      "channelType": AppSettings.channelType.value.toString(),
      "descriptionOfChannel": AppSettings.channelDescriptionController.text,
    });

    print("****** ${body}");

    final response = await http.patch(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      status = jsonResponse["status"];
      message = jsonResponse["message"];

      AppSettings.showLog("Create Channel Api Response => ${response.body}");
    } else {
      AppSettings.showLog("Create Channel Api Error => ${response.reasonPhrase.toString()}");
    }
  }
}
