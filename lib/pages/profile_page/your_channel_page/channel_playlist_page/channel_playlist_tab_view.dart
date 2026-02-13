import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibbeo/ads/google_ads/google_small_native_ad.dart';
import 'package:vibbeo/custom/custom_ui/data_not_found_ui.dart';
import 'package:vibbeo/custom/shimmer/video_list_shimmer_ui.dart';
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/main.dart';
import 'package:vibbeo/pages/profile_page/your_channel_page/channel_playlist_page/preview_playlist_view.dart';
import 'package:vibbeo/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
import 'package:vibbeo/utils/colors/app_color.dart';
import 'package:vibbeo/utils/config/size_config.dart';
import 'package:vibbeo/utils/icons/app_icons.dart';
import 'package:vibbeo/utils/services/preview_image.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';
import 'package:vibbeo/utils/string/app_string.dart';

class ChannelPlayListTabView extends StatelessWidget {
  const ChannelPlayListTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<YourChannelController>(
      id: "onGetPlayList",
      builder: (controller) {
        return controller.channelPlayList == null
            ? const VideoListShimmerUi()
            : (controller.channelPlayList!.isEmpty)
                ? DataNotFoundUi(title: AppStrings.playlistNotAvailable.tr)

                // : NotificationListener<ScrollNotification>(
                //     onNotification: (notification) {
                //       if (notification is UserScrollNotification) {
                //         if (notification.direction == ScrollDirection.forward) {
                //           controller.mainScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.linear);
                //         } else if (notification.direction == ScrollDirection.reverse) {
                //           controller.mainScrollController.animateTo(250, duration: const Duration(milliseconds: 500), curve: Curves.linear);
                //         }
                //       }
                //       return true;
                //     },
                //     child:
                : (controller.channelPlayList!.where((element) => element.playListType == 2 || element.channelId == Database.channelId).isNotEmpty)
                    ? SingleChildScrollView(
                        // controller: controller.playListScrollController,
                        physics: const BouncingScrollPhysics(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.channelPlayList?.length,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemBuilder: (context, index) {
                            return controller.channelPlayList![index].playListType == 1 && controller.channelPlayList![index].channelId != Database.channelId
                                ? const Offstage()
                                : Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.selectedPlayList = index;
                                            Get.to(
                                              PreviewPlaylistView(
                                                channelName: controller.channelPlayList![index].channelName!,
                                                playListName: controller.channelPlayList![index].playListName!,
                                                videos: controller.channelPlayList![index].videos!,
                                              ),
                                            );

                                            // Get.to(NormalVideoDetailsView(
                                            //   isPlayList: true,
                                            //   videoId: controller.channelPlayList![index].videos![0].videoId!,
                                            //   videoUrl: controller.channelPlayList![index].videos![0].videoUrl!,
                                            // ));
                                          },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Obx(
                                                    () => Container(
                                                      clipBehavior: Clip.hardEdge,
                                                      height: SizeConfig.smallVideoImageHeight,
                                                      width: SizeConfig.smallVideoImageWidth,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20), color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400),
                                                      child: PreviewVideoImage(
                                                        videoId: controller.channelPlayList![index].videos![0].videoId!,
                                                        videoImage: controller.channelPlayList![index].videos![0].videoImage!,
                                                      ),
                                                      // child: ConvertedPathView(
                                                      //     imageVideoPath: controller.channelPlayList![index].videos![0].videoImage!),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: Container(
                                                      height: (Get.height / 4 > 200) ? Get.height / 7.5 : 110,
                                                      width: SizeConfig.screenWidth / 5,
                                                      decoration: BoxDecoration(
                                                        color: AppColor.black.withOpacity(0.4),
                                                        borderRadius: const BorderRadius.only(
                                                          topRight: Radius.circular(20),
                                                          bottomRight: Radius.circular(20),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            controller.channelPlayList![index].totalVideo!.toString(),
                                                            style: GoogleFonts.urbanist(fontSize: 14, color: AppColor.white),
                                                          ),
                                                          SizedBox(height: SizeConfig.blockSizeVertical * 1),
                                                          const ImageIcon(AssetImage(AppIcons.boldPlay), color: AppColor.white, size: 18),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: Get.width * 0.03),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      controller.channelPlayList![index].playListName.toString(),
                                                      maxLines: 3,
                                                      style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(height: SizeConfig.blockSizeVertical * 1),
                                                    Text(
                                                      controller.channelPlayList![index].channelName!,
                                                      style: GoogleFonts.urbanist(
                                                        fontSize: 12,
                                                        color: isDarkMode.value ? AppColor.white.withOpacity(0.7) : AppColor.black.withOpacity(0.7),
                                                      ),
                                                    ),
                                                    SizedBox(height: SizeConfig.blockSizeVertical * 1),
                                                    Text(
                                                      "${controller.channelPlayList![index].totalVideo!} videos",
                                                      style: GoogleFonts.urbanist(
                                                        fontSize: 10,
                                                        color: isDarkMode.value ? AppColor.white.withOpacity(0.7) : AppColor.black.withOpacity(0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Offstage()
                                              // GestureDetector(child: const Icon(Icons.more_vert), onTap: () {}),
                                            ],
                                          ),
                                        ),
                                      ),
                                      index != 0 && index % AppSettings.showAdsIndex == 0 ? const GoogleSmallNativeAd() : const Offstage(),
                                    ],
                                  );
                          },
                        ),
                      )
                    : DataNotFoundUi(title: AppStrings.playlistNotAvailable.tr);
      },
    );
  }
}
