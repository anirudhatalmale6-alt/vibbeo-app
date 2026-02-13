import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vibbeo/custom/custom_method/custom_toast.dart';
import 'package:vibbeo/custom/custom_ui/loader_ui.dart';
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:vibbeo/pages/login_related_page/fill_profile_page/get_profile_model.dart';
import 'package:vibbeo/pages/subscription_plan_page/api/edit_subscription_plan_api.dart';
import 'package:vibbeo/utils/utils.dart';

class SubscriptionPlanController extends GetxController {
  TextEditingController videoController = TextEditingController();
  TextEditingController subscribeController = TextEditingController();

  GetProfileModel? getProfileModel;

  @override
  void onInit() {
    subscribeController = TextEditingController(text: (GetProfileApi.profileModel?.user?.subscriptionCost ?? 0).toString());
    videoController = TextEditingController(text: (GetProfileApi.profileModel?.user?.videoUnlockCost ?? 0).toString());
    super.onInit();
  }

  @override
  void onClose() {
    subscribeController.clear();
    videoController.clear();
    super.onClose();
  }

  void onClickSubmit() async {
    if (subscribeController.text.trim().isEmpty || (int.parse(subscribeController.text.trim()) < 1)) {
      CustomToast.show("Please enter subscription plan coin");
    } else if (videoController.text.trim().isEmpty || (int.parse(videoController.text.trim()) < 1)) {
      CustomToast.show("Please enter unlock video coin");
    } else {
      Get.dialog(const LoaderUi(), barrierDismissible: false);
      getProfileModel = await EditSubscriptionPlanApi.callApi(
        loginUserId: Database.loginUserId ?? "",
        subscriptionCost: subscribeController.text.trim(),
        videoUnlockCost: videoController.text.trim(),
      );

      Get.back();
      if (getProfileModel?.status == true) {
        Get.back();
        CustomToast.show(getProfileModel?.message ?? "");
        Utils.showLog("Profile Model Change Success");
        GetProfileApi.profileModel = getProfileModel;
      }
    }
  }
}
