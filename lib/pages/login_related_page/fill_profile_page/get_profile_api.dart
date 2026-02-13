import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/pages/admin_settings/admin_settings_api.dart';
import 'package:vibbeo/pages/login_related_page/fill_profile_page/get_profile_model.dart';
import 'package:vibbeo/pages/login_related_page/fill_profile_page/get_profile_modell.dart';
import 'package:vibbeo/utils/constant/app_constant.dart';
import 'package:vibbeo/utils/services/convert_to_network.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';

class GetProfileApi {
  static GetProfileModel? profileModel;
  static Future<void> callApi(String loginUserId) async {
    AppSettings.showLog("GetProfile Api Calling... $loginUserId");

    final uri = Uri.parse("${Constant.baseURL + Constant.getProfile}?userId=$loginUserId");

    AppSettings.showLog("GetProfile Api Calling... $uri");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        profileModel = GetProfileModel.fromJson(jsonResponse);

        if (profileModel != null) {
          Database.onSetIsNewUser(false);
          Database.onSetLoginUserId(profileModel!.user!.id!);

          AppSettings.channelName.value = profileModel?.user?.fullName ?? "";

          AppSettings.isShowAds = ((GetProfileApi.profileModel?.user?.isPremiumPlan == false) &&
              (AdminSettingsApi.adminSettingsModel?.setting?.isGoogle ?? false)); // if Premium Plan Not Perches then show ads

          if (profileModel!.user!.channelId != null && profileModel!.user!.isChannel != null) {
            Database.onSetChannelId(profileModel!.user!.channelId!);
            Database.onSetIsChannel(profileModel!.user!.isChannel!);
          }
          if (profileModel?.user?.image != null) {
            String image = await ConvertToNetwork.convert(profileModel!.user!.image!);

            AppSettings.showLog("Profile Image => $image");
            Database.onSetProfileImage(image);
            AppSettings.profileImage.value = image;
          }
        }
        AppSettings.showLog("GetProfile Response => ${response.body}");
      } else {
        AppSettings.showLog("GetProfile StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("GetProfile Api Error => $error");
    }
  }
}
