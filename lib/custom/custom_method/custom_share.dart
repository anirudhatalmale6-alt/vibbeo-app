import 'dart:async';
import 'dart:developer';
import 'package:vibbeo/utils/branch_io_services.dart';
import 'package:share_plus/share_plus.dart';

class CustomShare {
  static Future share({required String videoId, required String channelId, required String name, required String image, required String url, required String pageRoutes}) async {
    log("Share Method Called Success");
    try {
      await BranchIoServices.onCreateBranchIoLink(
        userId: "",
        channelId: channelId,
        videoId: videoId,
        name: name,
        image: image,
        url: url,
        pageRoutes: pageRoutes,
        referralCode: "",
      );

      final link = await BranchIoServices.onGenerateLink() ?? "";

      log("Branch Io Share Link => $link");

      Share.shareUri(Uri.parse(link));
    } catch (e) {
      log("Share Method Called Failed => $e");
    }

    // await FlutterShare.share(title: title, linkUrl: "https://play.google.com/store/apps/details?id=AppPackageName");
  }
}
