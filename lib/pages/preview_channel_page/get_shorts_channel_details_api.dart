// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:vibbeo/database/database.dart';
// import 'package:vibbeo/pages/preview_channel_page/get_shorts_channel_details_model.dart';
// import 'package:vibbeo/utils/constant/app_constant.dart';
// import 'package:vibbeo/utils/settings/app_settings.dart';
//
// class GetShortsChannelDetailsApi {
//   static int startPagination = 0;
//   static int limitPagination = 20;
//
//   static Future<GetShortsChannelDetailsModel?> callApi(String channelId) async {
//     AppSettings.showLog("Get Shorts Channel Details Api Calling...");
//
//     startPagination += 1;
//
//     final uri = Uri.parse("${Constant.baseURL + Constant.shortsChannelDetails}?channelId=$channelId&userId=${Database.loginUserId}&start=$startPagination&limit=$limitPagination");
//
//     final headers = {"key": Constant.secretKey};
//
//     try {
//       final response = await http.get(uri, headers: headers);
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         AppSettings.showLog("Get Shorts Channel Details Api Response => ${response.body}");
//
//         return GetShortsChannelDetailsModel.fromJson(jsonResponse);
//       } else {
//         AppSettings.showLog("Get Shorts Channel Details Api StateCode Error");
//       }
//     } catch (error) {
//       AppSettings.showLog("Get Shorts Channel Details Api Error => $error");
//     }
//     return null;
//   }
// }
