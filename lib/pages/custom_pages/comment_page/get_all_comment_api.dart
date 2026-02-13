import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/pages/custom_pages/comment_page/get_all_comment_model.dart';
import 'package:vibbeo/utils/constant/app_constant.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';

class GetAllCommentApi {
  static GetAllCommentModel? getAllCommentModel;
  static const List commentType = ["top", "newest", "mostLiked"];
  static Future<List<VideoComment>?> callApi(String videoId, int commentTypeIndex) async {
    AppSettings.showLog("Get All Comment Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.getAllComment}?userId=${Database.loginUserId}&videoId=$videoId&commentType=${commentType[commentTypeIndex]}");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        getAllCommentModel = GetAllCommentModel.fromJson(jsonResponse);
        AppSettings.showLog("Get All Comment Response => ${getAllCommentModel?.videoComment?.length}");
        return getAllCommentModel?.videoComment!;
      } else {
        AppSettings.showLog("Get All Comment StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get All Comment Error => $error");
    }
    return null;
  }
}
