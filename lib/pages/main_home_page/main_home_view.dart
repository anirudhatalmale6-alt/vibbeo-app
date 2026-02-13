import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibbeo/custom/basic_button.dart';
import 'package:vibbeo/custom/custom_method/custom_check_internet.dart';
import 'package:vibbeo/custom/custom_method/custom_toast.dart';
import 'package:vibbeo/custom/custom_method/custom_video_picker.dart';
import 'package:vibbeo/custom/custom_method/custom_video_size.dart';
import 'package:vibbeo/custom/custom_method/custom_video_time.dart';
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/main.dart';
import 'package:vibbeo/pages/admin_settings/admin_settings_api.dart';
import 'package:vibbeo/pages/custom_pages/comment_page/comment_controller.dart';
import 'package:vibbeo/pages/custom_pages/comment_page/reply_controller.dart';
import 'package:vibbeo/pages/nav_add_page/create_short_page/create_short_controller.dart';
import 'package:vibbeo/pages/nav_add_page/create_short_page/create_short_view.dart';
import 'package:vibbeo/pages/nav_add_page/live_page/go_live_page/view/go_live_view.dart';
import 'package:vibbeo/pages/nav_add_page/live_page/widget/socket_manager_controller.dart';
import 'package:vibbeo/pages/nav_add_page/upload_video_page/upload_video_controller.dart';
import 'package:vibbeo/pages/nav_add_page/upload_video_page/upload_video_view.dart';
import 'package:vibbeo/pages/nav_home_page/controller/nav_home_controller.dart';
import 'package:vibbeo/pages/nav_home_page/view/nav_home_page.dart';
import 'package:vibbeo/pages/nav_library_page/download_page/download_view.dart';
import 'package:vibbeo/pages/nav_library_page/main_page/nav_library_controller.dart';
import 'package:vibbeo/pages/nav_library_page/main_page/nav_library_page.dart';
import 'package:vibbeo/pages/nav_shorts_page/nav_shorts_controller.dart';
import 'package:vibbeo/pages/nav_shorts_page/nav_shorts_view.dart';
import 'package:vibbeo/pages/nav_subscription_page/nav_subscription_controller.dart';
import 'package:vibbeo/pages/nav_subscription_page/nav_subscription_view.dart';
import 'package:vibbeo/pages/notification_page/notification_controller.dart';
import 'package:vibbeo/pages/profile_page/convert_coin_page/get_my_coin_api.dart';
import 'package:vibbeo/pages/profile_page/main_page/profile_controller.dart';
import 'package:vibbeo/pages/profile_page/withdraw_page/withdraw_setting_api.dart';
import 'package:vibbeo/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
import 'package:vibbeo/pages/search_page/search_controller.dart';
import 'package:vibbeo/pages/search_page/search_view.dart';
import 'package:vibbeo/pages/video_details_page/normal_video_details_view.dart';
import 'package:vibbeo/pages/video_details_page/shorts_video_details_view.dart';
import 'package:vibbeo/utils/branch_io_services.dart';
import 'package:vibbeo/utils/colors/app_color.dart';
import 'package:vibbeo/utils/config/size_config.dart';
import 'package:vibbeo/utils/icons/app_icons.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';
import 'package:vibbeo/utils/string/app_string.dart';
import 'package:vibbeo/utils/style/app_style.dart';
import 'package:vibbeo/utils/utils.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:video_player/video_player.dart';

final List navigationPages = [
  const NavHomePageView(),
  const NavShortsView(),
  const NavSubscriptionView(),
  const NavLibraryView(),
];

class MainHomePageView extends StatefulWidget {
  const MainHomePageView({super.key});

  @override
  State<MainHomePageView> createState() => _MainHomePageViewState();
}

class _MainHomePageViewState extends State<MainHomePageView> {
  final quickAction = const QuickActions();
  VideoPlayerController? _homeVideoController;
  bool _isVideoInitialized = false;

  @override
  bool _adsPreloaded = false;

  void initState() {
    Timer(const Duration(milliseconds: 300), () {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.black,
          systemNavigationBarColor: Colors.black,
        ),
      );
    });

    if (AdminSettingsApi.adminSettingsModel == null) {
      AdminSettingsApi.callApi();
      AppSettings.showLog("Admin Api Second Time Calling...");
    }
    Get.put(NavHomeController());
    Get.put(ProfileController());
    Get.put(NavShortsController());
    Get.put(NavSubscriptionPageController());
    Get.put(NavLibraryPageController());
    Get.put(UploadVideoController());
    Get.put(CommentController());
    Get.put(RepliesController());
    Get.put(YourChannelController());
    Get.put(SearchingController());

    Get.put(NotificationController());
    Get.put(CreateShortController());

    final socketManagerController = Get.put(SocketManagerController());
    socketManagerController.socketConnect();

    WithdrawSettingApi.callApi(loginUserId: Database.loginUserId ?? "");

    AppSettings.onCreateLink();

    GetMyCoinApi.callApi(loginUserId: Database.loginUserId ?? "");
    Timer(const Duration(milliseconds: 300), () {
      if (BranchIoServices.pageRoutes == "NormalVideo") {
        Get.to(NormalVideoDetailsView(videoId: BranchIoServices.videoId, videoUrl: BranchIoServices.url));
      } else if (BranchIoServices.pageRoutes == "ShortsVideo") {
        Get.to(() => ShortsVideoDetailsView(videoId: BranchIoServices.videoId, videoUrl: BranchIoServices.url));
      }
    });
    Utils.showLog("INTERNET LAGGG");
    Timer(const Duration(milliseconds: 100), () {
      if (!CustomCheckInternet.isConnect.value) {
        AppSettings.navigationIndex.value = 3;
        Get.to(const DownloadView());
      }
    });
    super.initState();

    quickAction.setShortcutItems([
      const ShortcutItem(
        type: 'Subscriptions',
        localizedTitle: 'Subscriptions',
        icon: "subscription",
      ),
      const ShortcutItem(
        type: 'Search',
        localizedTitle: 'Search',
        icon: "search",
      ),
      const ShortcutItem(
        type: 'Shorts',
        localizedTitle: 'Shorts',
        icon: "shorts",
      ),
    ]);

    quickAction.initialize(
      (type) {
        if (type == 'Subscriptions') {
          AppSettings.navigationIndex.value = 2;
        } else if (type == 'Search') {
          Get.to(const SearchView(isSearchShorts: false));
        } else if (type == 'Shorts') {
          AppSettings.navigationIndex.value = 1;
        }
      },
    );
  }
/*
  void _initializeVideo() {
    // Initialize video controller for home page video
    _homeVideoController = VideoPlayerController.networkUrl(Uri.parse('https://storage.googleapis.com/gvabox/media/samples/stock.mp4'));

    _homeVideoController!.addListener(_videoListener);

    _homeVideoController!.initialize().then((_) {
      setState(() {
        _isVideoInitialized = true;
      });

      // Video is loaded, now preload ads
      _preloadAdsAfterVideoLoad(); */ /**/ /*
    }).catchError((error) {
      debugPrint('Error initializing home video: $error');
      // Even if video fails, preload ads after a delay
      Future.delayed(Duration(seconds: 2), () {
        _preloadAdsAfterVideoLoad();
      });
    });
  }

  void _videoListener() {
    // Additional checks can be done here
    if (_homeVideoController!.value.isInitialized && !_adsPreloaded) {
      // Video is ready and buffered
      if (_homeVideoController!.value.buffered.isNotEmpty) {
        _preloadAdsAfterVideoLoad();
      }
    }
  }

  void _preloadAdsAfterVideoLoad() {
    if (_adsPreloaded) return;

    debugPrint('Home video loaded, starting ad preloading...');
    _adsPreloaded = true;

    // Preload ads after video is ready
    AdPreloader().preloadAds().then((_) {
      debugPrint('Ads preloading completed');
    }).catchError((error) {
      debugPrint('Ad preloading failed: $error');
    });
  }

  @override
  void dispose() {
    _homeVideoController?.removeListener(_videoListener);
    _homeVideoController?.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 55),
        child: FloatingActionButton(
          heroTag: null,
          hoverColor: Colors.transparent,
          hoverElevation: 0,
          highlightElevation: 0,
          splashColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          focusColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () async {
            Get.bottomSheet(
              elevation: 0,
              backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              SizedBox(
                height: Platform.isAndroid ? 330 : 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 12,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color: AppColor.grey_300,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.create.tr, style: titalstyle1),
                    const SizedBox(height: 8),
                    Divider(indent: 25, endIndent: 25, color: AppColor.grey_200),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            CreateShortsOption(
                              logo: AppIcons.boldVideo,
                              option: AppStrings.createAShort.tr,
                              onTap: () {
                                Get.back();
                                if (AppSettings.isUploading.value) {
                                  CustomToast.show("Already video upload running !!");
                                } else {
                                  Get.to(() => CreateShortView());
                                }
                              },
                            ),
                            // const SizedBox(height: 16),
                            CreateShortsOption(
                              logo: AppIcons.boldUpload,
                              option: AppStrings.uploadAVideo.tr,
                              onTap: () async {
                                Get.back();
                                // Get.to(
                                //   UploadVideoView(
                                //     videoPath: "/storage/emulated/0/Android/data/com.vibbeo.app/files/video_compress/VID_2024-03-06 02-32-411084789987.mp4",
                                //     loginUserId: Database.loginUserId!,
                                //     loginUserChannelId: Database.channelId!,
                                //     videoType: 1,
                                //   ),
                                // );
                                //
                                if (AppSettings.isUploading.value) {
                                  CustomToast.show("Already video upload running !!");
                                } else {
                                  // if (Database.isChannel && Database.channelId != null) {
                                  AppSettings.showLog("Upload View Bottom Sheet On Click");

                                  final pickedVideo = await CustomVideoPicker.pickVideo();

                                  if (pickedVideo != null) {
                                    AppSettings.showLog("Picked Video Url => $pickedVideo");
                                    final response = await isSupport(pickedVideo);
                                    // final videoSize = await CustomVideoSize.onGet(pickedVideo);
                                    // AppSettings.showLog("Picked Video Size => $videoSize");
                                    // if (videoSize != null && videoSize <= 100) {
                                    if (response) {
                                      // Check max video duration (10 min default)
                                      final maxDuration = AdminSettingsApi.adminSettingsModel?.setting?.maxVideoDuration ?? 600000;
                                      if (maxDuration > 0) {
                                        final videoTimeMs = await CustomVideoTime.onGet(pickedVideo);
                                        if (videoTimeMs != null && videoTimeMs > maxDuration) {
                                          final maxMinutes = (maxDuration / 60000).floor();
                                          CustomToast.show("Video is too long! Maximum duration is $maxMinutes minutes.");
                                          return;
                                        }
                                      }

                                      final videoSize = await CustomVideoSize.onGet(pickedVideo);
                                      AppSettings.showLog("Picked Video Size => $videoSize");

                                      Get.to(
                                        UploadVideoView(
                                          videoPath: pickedVideo,
                                          loginUserId: Database.loginUserId ?? "",
                                          loginUserChannelId: Database.channelId ?? "",
                                          videoType: 1,
                                        ),
                                      );

                                      // final compressPath = await CustomVideoCompress.onCompress(pickedVideo);
                                      //
                                      // if (compressPath != null) {
                                      //   final videoSize = await CustomVideoSize.onGet(compressPath);
                                      //   AppSettings.showLog("Compress * Video Size => $videoSize");
                                      //
                                      //   Get.to(
                                      //     UploadVideoView(
                                      //       videoPath: compressPath,
                                      //       loginUserId: Database.loginUserId!,
                                      //       loginUserChannelId: Database.channelId!,
                                      //       videoType: 1,
                                      //     ),
                                      //   );
                                      // }
                                    } else {
                                      CustomToast.show(AppStrings.videoNotSupport.tr);
                                    }
                                  }
                                  // } else {
                                  //   CustomToast.show(AppStrings.pleaseCreateChannel.tr);
                                  // }
                                }
                              },
                            ),
                            // const SizedBox(height: 16),
                            CreateShortsOption(
                              logo: AppIcons.boldPlay,
                              option: AppStrings.goLive.tr,
                              onTap: () async {
                                Get.back();
                                // if (Database.isChannel && Database.channelId != null) {
                                if (socket?.connected ?? false) {
                                  // goToLiveController.onRequestPermissions();
                                  Get.to(const GoLiveView());
                                  // Get.to(const StreamingView());
                                } else {
                                  CustomToast.show(AppStrings.connectionIssue.tr);
                                }
                                // } else {
                                //   CustomToast.show(AppStrings.pleaseCreateChannel.tr);
                                // }
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Platform.isAndroid ? const Offstage() : const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
          child: Container(
            height: 50,
            width: 50,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primaryColor,
            ),
            child: const Icon(
              Icons.add,
              color: AppColor.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: isDarkMode.value ? AppColor.mainDark : AppColor.white,
      bottomNavigationBar: Obx(
        () => Container(
          height: (Platform.isIOS)
              ? Get.height / 9.5
              : (Platform.isAndroid)
                  ? Get.height / 13.1
                  : 0,
          width: Get.width,
          // color: isDarkMode.value ? AppColors.mainDark : Colors.white,
          decoration: BoxDecoration(
              color: isDarkMode.value ? AppColor.mainDark : Colors.white,
              boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.3), blurRadius: 1.5, offset: const Offset(0.5, 0.5), spreadRadius: 0.3)]),
          child: Row(
            children: [
              BottomBarItemUi(
                activeIcon: AppIcons.boldHome,
                icon: AppIcons.homeLogo,
                title: AppStrings.home.tr,
                index: 0,
              ),
              BottomBarItemUi(
                activeIcon: AppIcons.boldVideo,
                icon: AppIcons.video,
                title: AppStrings.shorts.tr,
                index: 1,
              ),
              const Expanded(child: Offstage()),
              BottomBarItemUi(
                activeIcon: AppIcons.boldPlay,
                icon: AppIcons.videoCircle,
                title: AppStrings.subscription.tr,
                index: 2,
              ),
              BottomBarItemUi(
                activeIcon: AppIcons.boldLibrary,
                icon: AppIcons.libraryLogo,
                title: AppStrings.library.tr,
                index: 3,
              ),
            ],
          ),
        ),
      ),
      body: PageView.builder(
        itemCount: navigationPages.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Obx(() => navigationPages[AppSettings.navigationIndex.value]),
      ),
    );
  }
}

Future<bool> isSupport(String path) async {
  try {
    final VideoPlayerController controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    return controller.value.isInitialized ? true : false;
  } catch (e) {
    return false;
  }
}

class BottomBarItemUi extends StatelessWidget {
  const BottomBarItemUi({super.key, required this.icon, required this.title, required this.index, required this.activeIcon});

  final String activeIcon;
  final String icon;
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () => AppSettings.navigationIndex.value = index,
        child: Obx(
          () => Container(
            height: 60,
            width: 50,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppSettings.navigationIndex.value == index ? activeIcon : icon,
                  height: 22,
                  width: 22,
                  color: AppSettings.navigationIndex.value == index ? AppColor.primaryColor : AppColor.grey,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode.value
                        ? AppSettings.navigationIndex.value == index
                            ? AppColor.primaryColor
                            : AppColor.grey
                        : AppSettings.navigationIndex.value == index
                            ? AppColor.primaryColor
                            : AppColor.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// old bottom bar working mode

// Obx(
//   () => BottomNavigationBar(
//     backgroundColor: isDarkMode.value ? AppColors.secondDarkMode : AppColors.green,
//     type: BottomNavigationBarType.fixed,
//     selectedItemColor: AppColors.primaryColor,
//     unselectedItemColor: AppColors.grey,
//     onTap: (index) => AppSettings.navigationIndex.value = index,
//     currentIndex: AppSettings.navigationIndex.value,
//     selectedLabelStyle: bottomTabsStyle,
//     unselectedLabelStyle: bottomTabsStyle,
//     items: [
//       BottomNavigationBarItem(
//         activeIcon: const Image(
//           image: AssetImage(AppIcons.boldHome),
//           height: 22,
//           width: 22,
//           color: AppColors.primaryColor,
//         ),
//         label: AppStrings.home.tr,
//         icon: const Image(
//           image: AssetImage(AppIcons.homeLogo),
//           height: 22,
//           width: 22,
//           color: AppColors.grey,
//         ),
//       ),
//       BottomNavigationBarItem(
//         activeIcon: const Image(
//           image: AssetImage(AppIcons.boldVideo),
//           height: 22,
//           width: 22,
//           color: AppColors.primaryColor,
//         ),
//         label: AppStrings.shorts.tr,
//         icon: const Image(
//           image: AssetImage(AppIcons.video),
//           height: 22,
//           width: 22,
//           color: AppColors.grey,
//         ),
//       ),
//       const BottomNavigationBarItem(label: "", icon: SizedBox(height: 0)),
//       BottomNavigationBarItem(
//         activeIcon: const Image(
//           image: AssetImage(AppIcons.boldPlay),
//           height: 22,
//           width: 22,
//           color: AppColors.primaryColor,
//         ),
//         label: AppStrings.subscription.tr,
//         icon: const Image(
//           image: AssetImage(AppIcons.videoCircle),
//           height: 22,
//           width: 22,
//           color: AppColors.grey,
//         ),
//       ),
//       BottomNavigationBarItem(
//         activeIcon: const Image(
//           image: AssetImage(AppIcons.boldLibrary),
//           height: 22,
//           width: 22,
//           color: AppColors.primaryColor,
//         ),
//         label: AppStrings.library.tr,
//         icon: const Image(
//           image: AssetImage(AppIcons.libraryLogo),
//           height: 22,
//           width: 22,
//           color: AppColors.grey,
//         ),
//       ),
//     ],
//   ),
// ),
