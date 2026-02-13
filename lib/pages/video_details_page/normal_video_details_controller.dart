// import 'dart:developer';
//
// import 'package:chewie/chewie.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:vibbeo/database/database.dart';
// import 'package:vibbeo/database/watch_history_database.dart';
// import 'package:vibbeo/pages/nav_home_page/controller/nav_home_controller.dart';
// import 'package:vibbeo/pages/nav_library_page/history_page/create_watch_history_api.dart';
// import 'package:vibbeo/pages/profile_page/content_engagement_page/video_engagement_reward_api.dart';
// import 'package:vibbeo/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
// import 'package:vibbeo/pages/video_details_page/get_related_video_api.dart';
// import 'package:vibbeo/pages/video_details_page/get_related_video_model.dart';
// import 'package:vibbeo/pages/video_details_page/video_details_api.dart';
// import 'package:vibbeo/pages/video_details_page/video_details_model.dart';
// import 'package:vibbeo/utils/services/convert_to_network.dart';
// import 'package:vibbeo/utils/settings/app_settings.dart';
// import 'package:video_player/video_player.dart';
//
// class NormalVideoDetailsController extends GetxController {
//   final yourChannelController = Get.find<YourChannelController>();
//
//   TextEditingController commentController = TextEditingController();
//
//   ScrollController scrollController = ScrollController();
//
//   GetRelatedVideoModel? _getRelatedVideoModel;
//   VideoDetailsModel? videoDetailsModel;
//
//   VideoPlayerController? videoPlayerController;
//   ChewieController? chewieController;
//
//   List<Data>? mainRelatedVideos;
//
//   int selectedWatchedVideo = 0;
//   List<WatchedVideoModel> mainWatchedVideos = [];
//
//   String videoId = "";
//
//   RxBool isLike = false.obs;
//   RxBool isDisLike = false.obs;
//   RxBool isSubscribe = false.obs;
//   RxBool isSave = false.obs;
//   RxMap customChanges = {"like": 0, "disLike": 0, "comment": 0, "share": 0}.obs;
//
//   RxBool isDisableNext = false.obs;
//   RxBool isDisablePrevious = false.obs;
//
//   bool isVideoLoading = false;
//   bool isShowVideoControls = false;
//   RxBool isVideoDetailsLoading = true.obs;
//
//   RxBool isDownloading = false.obs;
//
//   RxBool isLoop = false.obs;
//   RxBool isSpeaker = true.obs;
//   RxInt currentSpeedIndex = 2.obs;
//   final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
//
//   // Video Engagement Reward...
//
//   bool isVideoSkip = false;
//   bool isGetVideoRewardCoin = false;
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//
//     ///
//     adCompleted = false;
//
//     super.onInit();
//   }
//
//   Future<void> init(String videoId, String videoUrl) async {
//     this.videoId = videoId;
//     onGetRelatedVideos(videoId);
//     onGetVideoDetails(videoId);
//
//     await initializeVideoPlayer(videoId, videoUrl);
//   }
//
//   void onGetPlayListVideos() {
//     if (yourChannelController.selectedPlayList != null) {
//       AppSettings.showLog("Selected PlayList => ${yourChannelController.selectedPlayList}");
//       for (int i = 0; i < yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos!.length; i++) {
//         if (yourChannelController.selectedPlayListVideo < i) {
//           final index = yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos![i];
//           mainWatchedVideos.add(WatchedVideoModel(videoId: index.videoId!, videoUrl: index.videoUrl!));
//         }
//       }
//     }
//   }
//
//   Future<void> onGetRelatedVideos(String videoId) async {
//     mainRelatedVideos = null;
//     _getRelatedVideoModel = await GetRelatedVideoApi.callApi(loginUserId: Database.loginUserId!, videoId: videoId);
//
//     if (_getRelatedVideoModel != null) {
//       mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
//     }
//     AppSettings.showLog("Playing Related Video Length => ${mainRelatedVideos?.length}");
//
//     mainRelatedVideos?.shuffle();
//
//     update(["onGetRelatedVideos"]);
//
//     if (mainRelatedVideos?.isEmpty ?? true && mainWatchedVideos.length == 1) {
//       isDisableNext(true);
//     }
//
//     try {
//       scrollController.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.ease);
//     } catch (e) {
//       log("Scrolling Failed");
//     }
//   }
//
//   Future<void> onGetVideoDetails(String videoId) async {
//     isVideoDetailsLoading.value = true;
//
//     // >>>>>>>>>>>> This is Used to Clear Previous Data <<<<<<<<<<<<
//     videoDetailsModel = null;
//
//     videoDetailsModel = await VideoDetailsApi.callApi(Database.loginUserId!, videoId, 1);
//     if (videoDetailsModel != null) {
//       isLike.value = videoDetailsModel?.detailsOfVideo?.isLike ?? false;
//       isDisLike.value = videoDetailsModel?.detailsOfVideo?.isDislike ?? false;
//       isSubscribe.value = videoDetailsModel?.detailsOfVideo?.isSubscribed ?? false;
//       isSave.value = videoDetailsModel?.detailsOfVideo?.isSaveToWatchLater ?? false;
//
//       customChanges["like"] = videoDetailsModel!.detailsOfVideo!.like!;
//       customChanges["disLike"] = videoDetailsModel!.detailsOfVideo!.dislike!;
//       customChanges["comment"] = videoDetailsModel!.detailsOfVideo!.totalComments!;
//       customChanges["subscribe"] = videoDetailsModel!.detailsOfVideo!.totalSubscribers!;
//
//       isVideoDetailsLoading.value = false;
//
//       createWatchHistory();
//
//       // >>>>>>>>>>>> This is Used to Increase Views <<<<<<<<<<<<
//     }
//   }
//
//   Future<void> onCreateHistory() async {
//     if (Database.channelId != null && videoPlayerController != null && videoDetailsModel?.detailsOfVideo != null) {
//       final watchTime = videoPlayerController!.value.position.inSeconds / 60;
//       AppSettings.showLog("Video Watch Time => $watchTime");
//
//       if (isVideoSkip == false) {
//         await CreateWatchHistoryApi.callApi(
//           loginUserId: Database.loginUserId!,
//           videoId: videoDetailsModel!.detailsOfVideo!.id!,
//           videoChannelId: videoDetailsModel!.detailsOfVideo!.channelId!,
//           videoUserId: videoDetailsModel!.detailsOfVideo!.userId!,
//           watchTimeInMinute: watchTime,
//         );
//       }
//     }
//   }
//
//   void onToggleVolume() {
//     if (isSpeaker.value) {
//       isSpeaker.value = false;
//       videoPlayerController?.setVolume(0);
//     } else {
//       videoPlayerController?.setVolume(100);
//       isSpeaker.value = true;
//     }
//   }
//
//   // Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
//   //   try {
//   //     isVideoSkip = false;
//   //     isGetVideoRewardCoin = false;
//   //
//   //     // String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.normalVideo(videoUrl);
//   //     String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);
//   //
//   //     videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
//   //
//   //     await videoPlayerController?.initialize();
//   //
//   //     if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
//   //       if (Database.onGetVideoUrl(videoId) == null) {
//   //         Database.onSetVideoUrl(videoId, videoPath);
//   //       }
//   //       // chewieController = (orientation == Orientation.portrait)
//   //       //     ? ChewieController(
//   //       //         videoPlayerController: videoPlayerController!,
//   //       //         aspectRatio: Get.width / (Get.height / 3.5),
//   //       //         autoPlay: true,
//   //       //         looping: isLoop.value,
//   //       //         allowedScreenSleep: false,
//   //       //         allowMuting: false,
//   //       //         showControlsOnInitialize: false,
//   //       //         showControls: false,
//   //       //       )
//   //       //     :
//   //       chewieController = ChewieController(
//   //         videoPlayerController: videoPlayerController!,
//   //         // aspectRatio: Get.width / Get.height,
//   //         autoPlay: false,
//   //         looping: isLoop.value,
//   //         allowedScreenSleep: false,
//   //         allowMuting: false,
//   //         showControlsOnInitialize: false,
//   //         showControls: false,
//   //       );
//   //
//   //       videoPlayerController?.addListener(
//   //         () async {
//   //           //  >>>>>>>>>>>>>>>>>>>>>>>> Use To Close Page After Stop Video <<<<<<<<<<<<<<<<<<<<<<<<<
//   //
//   //           if (Get.currentRoute != "/NormalVideoDetailsView") {
//   //             videoPlayerController?.pause();
//   //             AppSettings.showLog("Video Playing Routes Changes...");
//   //           }
//   //
//   //           if ((videoPlayerController?.value.isInitialized ?? false)) {
//   //             if (videoPlayerController!.value.isBuffering) {
//   //               if (isVideoLoading == false) {
//   //                 isVideoLoading = true;
//   //                 update(["onLoading"]);
//   //               }
//   //             } else {
//   //               if (isVideoLoading == true) {
//   //                 isVideoLoading = false;
//   //                 update(["onLoading"]);
//   //               }
//   //             }
//   //             update(["onProgressLine", "onVideoTime", "onVideoPlayPause"]);
//   //
//   //             //  >>>>>>>>>>>>>>>>>>>>>>>> Use To Finish Video After Condition <<<<<<<<<<<<<<<<<<<<<<<<<
//   //
//   //             if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
//   //               AppSettings.showLog("Playing Video Complete...");
//   //
//   //               AppSettings.showLog("Video Engagement Reward Method Calling...");
//   //
//   //               if (isGetVideoRewardCoin == false && isVideoSkip == false) {
//   //                 isGetVideoRewardCoin = true;
//   //                 VideoEngagementRewardApi.callApi(
//   //                     loginUserId: Database.loginUserId ?? "",
//   //                     videoId: videoId,
//   //                     totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
//   //               }
//   //
//   //               onCreateHistory();
//   //               if (AppSettings.isAutoPlayVideo.value) {
//   //                 if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
//   //                   isDisablePrevious(false);
//   //                 }
//   //
//   //                 selectedWatchedVideo++;
//   //
//   //                 if (selectedWatchedVideo < mainWatchedVideos.length) {
//   //                   onDisposeVideoPlayer();
//   //                   init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//   //                 } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//   //                   onCreateHistory();
//   //                   onDisposeVideoPlayer();
//   //                   isDisablePrevious(false);
//   //                   mainWatchedVideos.insert(
//   //                       selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//   //                   init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//   //                   mainRelatedVideos = null;
//   //                   update(["onGetRelatedVideos"]);
//   //                 } else {
//   //                   isDisableNext(true);
//   //                 }
//   //                 // if (selectedWatchedVideo == (mainWatchedVideos.length - 1)) {
//   //                 //   isDisableNext(true);
//   //                 // }
//   //               }
//   //             }
//   //           }
//   //         },
//   //       );
//   //
//   //       if (isSpeaker.value == false) {
//   //         videoPlayerController?.setVolume(0);
//   //       }
//   //     }
//   //
//   //     update(["onVideoInitialize"]);
//   //   } catch (e) {
//   //     AppSettings.showLog("Normal Video Initialization Failed => $e");
//   //     onDisposeVideoPlayer();
//   //   }
//   // }
//
//   ///
//
//   Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
//     try {
//       isVideoSkip = false;
//       isGetVideoRewardCoin = false;
//
//       String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);
//
//       videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
//
//       await videoPlayerController?.initialize();
//
//       if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
//         if (Database.onGetVideoUrl(videoId) == null) {
//           Database.onSetVideoUrl(videoId, videoPath);
//         }
//
//         chewieController = ChewieController(
//           videoPlayerController: videoPlayerController!,
//           autoPlay: true, // Don't auto-play, we'll control this manually
//           looping: isLoop.value,
//           allowedScreenSleep: false,
//           allowMuting: false,
//           showControlsOnInitialize: false,
//           showControls: false,
//         );
//
//         videoPlayerController?.addListener(
//           () async {
//             if (Get.currentRoute != "/NormalVideoDetailsView") {
//               videoPlayerController?.pause();
//               AppSettings.showLog("Video Playing Routes Changes...");
//             }
//
//             if ((videoPlayerController?.value.isInitialized ?? false)) {
//               if (videoPlayerController!.value.isBuffering) {
//                 if (isVideoLoading == false) {
//                   isVideoLoading = true;
//                   update(["onLoading"]);
//                 }
//               } else {
//                 if (isVideoLoading == true) {
//                   isVideoLoading = false;
//                   update(["onLoading"]);
//                 }
//               }
//               update(["onProgressLine", "onVideoTime", "onVideoPlayPause"]);
//
//               if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
//                 AppSettings.showLog("Playing Video Complete...");
//
//                 if (isGetVideoRewardCoin == false && isVideoSkip == false) {
//                   isGetVideoRewardCoin = true;
//                   VideoEngagementRewardApi.callApi(
//                       loginUserId: Database.loginUserId ?? "",
//                       videoId: videoId,
//                       totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
//                 }
//
//                 onCreateHistory();
//                 if (AppSettings.isAutoPlayVideo.value) {
//                   if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
//                     isDisablePrevious(false);
//                   }
//
//                   selectedWatchedVideo++;
//
//                   if (selectedWatchedVideo < mainWatchedVideos.length) {
//                     onDisposeVideoPlayer();
//                     init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//                   } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//                     onCreateHistory();
//                     onDisposeVideoPlayer();
//                     isDisablePrevious(false);
//                     mainWatchedVideos.insert(
//                         selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//                     init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//                     mainRelatedVideos = null;
//                     update(["onGetRelatedVideos"]);
//                   } else {
//                     isDisableNext(true);
//                   }
//                 }
//               }
//             }
//           },
//         );
//
//         if (isSpeaker.value == false) {
//           videoPlayerController?.setVolume(0);
//         }
//       }
//
//       update(["onVideoInitialize"]);
//     } catch (e) {
//       AppSettings.showLog("Normal Video Initialization Failed => $e");
//       onDisposeVideoPlayer();
//     }
//   }
//
//   void onChangeVideoLoading() {
//     isVideoLoading = !isVideoLoading;
//     update(["onChangeVideoLoading"]);
//   }
//
//   void onDisposeVideoPlayer() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     chewieController = null;
//     update(["onVideoInitialize"]);
//   }
//
//   void onNextVideo() {
//     isDisablePrevious(false);
//
//     selectedWatchedVideo++;
//
//     if (selectedWatchedVideo != mainWatchedVideos.length) {
//       onDisposeVideoPlayer();
//       onCreateHistory();
//       init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//     } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//       onCreateHistory();
//       onDisposeVideoPlayer();
//       isDisablePrevious(false);
//       mainWatchedVideos.insert(
//           selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//       init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//       mainRelatedVideos = null;
//       update(["onGetRelatedVideos"]);
//     } else {
//       isDisableNext(true);
//     }
//     // if (selectedWatchedVideo == (mainWatchedVideos.length - 1)) {
//     //   isDisableNext(true);
//     // }
//   }
//
//   void onPreviousVideo() async {
//     isDisableNext(false);
//
//     selectedWatchedVideo--;
//     if (selectedWatchedVideo >= 0) {
//       onDisposeVideoPlayer();
//       init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//     }
//     if (selectedWatchedVideo == 0) {
//       isDisablePrevious(true);
//     }
//   }
//
//   // Future<void> onRotate(double aspectRatio) async {
//   // if (videoPlayerController != null) {
//   //   chewieController = null;
//   //
//   //   chewieController = ChewieController(
//   //     videoPlayerController: videoPlayerController!,
//   //     aspectRatio: aspectRatio,
//   //     looping: isLoop.value,
//   //     allowedScreenSleep: false,
//   //     allowMuting: false,
//   //     showControlsOnInitialize: false,
//   //     showControls: false,
//   //   );
//   //   update(["onVideoInitialize"]);
//   // }
//   // }
//
//   Future<void> onChangeLoop() async {
//     if (videoPlayerController != null) {
//       chewieController = null;
//
//       chewieController = ChewieController(
//         videoPlayerController: videoPlayerController!,
//         looping: isLoop.value,
//         allowedScreenSleep: false,
//         allowMuting: false,
//         showControlsOnInitialize: false,
//         showControls: false,
//       );
//       update(["onVideoInitialize"]);
//     }
//   }
//
//   void createWatchHistory() async {
//     if (AppSettings.isCreateHistory.value) {
//       AppSettings.showLog("Create Watch History Method Called");
//       bool isAvailable = false;
//       for (int index = 0; index < WatchHistory.mainWatchHistory.length; index++) {
//         if (WatchHistory.mainWatchHistory[index]["videoId"] == videoDetailsModel!.detailsOfVideo!.id) {
//           AppSettings.showLog("Replace Watch History");
//           WatchHistory.mainWatchHistory.insert(0, WatchHistory.mainWatchHistory.removeAt(index));
//           isAvailable = true;
//           break;
//         } else {
//           AppSettings.showLog("Not Match");
//         }
//       }
//       if (isAvailable == false) {
//         AppSettings.showLog("Create New Watch History");
//         WatchHistory.mainWatchHistory.insert(
//           0,
//           {
//             "id": DateTime.now().millisecondsSinceEpoch,
//             "videoId": videoDetailsModel!.detailsOfVideo!.id,
//             "videoTitle": videoDetailsModel!.detailsOfVideo!.title,
//             "videoType": videoDetailsModel!.detailsOfVideo!.videoType,
//             "videoTime": videoDetailsModel!.detailsOfVideo!.videoTime,
//             "videoUrl": videoDetailsModel!.detailsOfVideo!.videoUrl,
//             "videoImage": videoDetailsModel!.detailsOfVideo!.videoImage,
//             "views": videoDetailsModel!.detailsOfVideo!.views,
//             "channelName": videoDetailsModel!.detailsOfVideo!.channelName,
//           },
//         );
//       }
//       WatchHistory.onSet();
//     }
//   }
//
//   void showVideoControls() {
//     isShowVideoControls = !isShowVideoControls;
//     update(["onShowControls"]);
//   }
//
//   Future<void> forwardSkipVideo() async {
//     await videoPlayerController?.seekTo((await videoPlayerController?.position)! + const Duration(seconds: 10));
//     isVideoSkip = true;
//   }
//
//   Future<void> backwardSkipVideo() async {
//     await videoPlayerController?.seekTo((await videoPlayerController?.position)! - const Duration(seconds: 10));
//   }
//
//   ///
//
//   bool adCompleted = false;
//   @override
//   void onClose() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     super.onClose();
//   }
//
//   void onAdCompleted() {
//     debugPrint('Ad completed, starting video playback');
//     adCompleted = true;
//
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
//         videoPlayerController?.play();
//       }
//       update(["onVideoInitialize", "onAdCompleted"]);
//     });
//   }
//
//   RxBool isLoadingAds = true.obs;
// }
//
// class WatchedVideoModel {
//   final String videoId;
//   final String videoUrl;
//   WatchedVideoModel({required this.videoId, required this.videoUrl});
// }

import 'dart:async';
import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vibbeo/ads/google_ads/google_video_ad.dart';
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/database/watch_history_database.dart';
import 'package:vibbeo/pages/nav_library_page/history_page/create_watch_history_api.dart';
import 'package:vibbeo/pages/profile_page/content_engagement_page/video_engagement_reward_api.dart';
import 'package:vibbeo/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
import 'package:vibbeo/pages/video_details_page/get_related_video_api.dart';
import 'package:vibbeo/pages/video_details_page/get_related_video_model.dart';
import 'package:vibbeo/pages/video_details_page/video_details_api.dart';
import 'package:vibbeo/pages/video_details_page/video_details_model.dart';
import 'package:vibbeo/utils/services/convert_to_network.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';
import 'package:vibbeo/utils/utils.dart';
import 'package:video_player/video_player.dart';

//
// class NormalVideoDetailsController extends GetxController {
//   final yourChannelController = Get.find<YourChannelController>();
//
//   TextEditingController commentController = TextEditingController();
//
//   ScrollController scrollController = ScrollController();
//
//   GetRelatedVideoModel? _getRelatedVideoModel;
//   VideoDetailsModel? videoDetailsModel;
//
//   VideoPlayerController? videoPlayerController;
//   ChewieController? chewieController;
//
//   List<Data>? mainRelatedVideos;
//
//   int selectedWatchedVideo = 0;
//   List<WatchedVideoModel> mainWatchedVideos = [];
//
//   String videoId = "";
//
//   RxBool isLike = false.obs;
//   RxBool isDisLike = false.obs;
//   RxBool isSubscribe = false.obs;
//   RxBool isSave = false.obs;
//   RxMap customChanges = {"like": 0, "disLike": 0, "comment": 0, "share": 0}.obs;
//
//   RxBool isDisableNext = false.obs;
//   RxBool isDisablePrevious = false.obs;
//
//   bool isVideoLoading = false;
//   bool isShowVideoControls = false;
//   RxBool isVideoDetailsLoading = true.obs;
//
//   RxBool isDownloading = false.obs;
//
//   RxBool isLoop = false.obs;
//   RxBool isSpeaker = true.obs;
//   RxInt currentSpeedIndex = 2.obs;
//   final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
//
//   // Video Engagement Reward...
//
//   bool isVideoSkip = false;
//   bool isGetVideoRewardCoin = false;
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//
//     ///
//     _preloadVideo();
//     adCompleted = false;
//
//     super.onInit();
//   }
//
//   Future<void> init(String videoId, String videoUrl) async {
//     this.videoId = videoId;
//     onGetRelatedVideos(videoId);
//     onGetVideoDetails(videoId);
//
//     await initializeVideoPlayer(videoId, videoUrl);
//   }
//
//   void onGetPlayListVideos() {
//     if (yourChannelController.selectedPlayList != null) {
//       AppSettings.showLog("Selected PlayList => ${yourChannelController.selectedPlayList}");
//       for (int i = 0; i < yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos!.length; i++) {
//         if (yourChannelController.selectedPlayListVideo < i) {
//           final index = yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos![i];
//           mainWatchedVideos.add(WatchedVideoModel(videoId: index.videoId!, videoUrl: index.videoUrl!));
//         }
//       }
//     }
//   }
//
//   Future<void> onGetRelatedVideos(String videoId) async {
//     mainRelatedVideos = null;
//     _getRelatedVideoModel = await GetRelatedVideoApi.callApi(loginUserId: Database.loginUserId!, videoId: videoId);
//
//     if (_getRelatedVideoModel != null) {
//       mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
//     }
//     AppSettings.showLog("Playing Related Video Length => ${mainRelatedVideos?.length}");
//
//     mainRelatedVideos?.shuffle();
//
//     update(["onGetRelatedVideos"]);
//
//     if (mainRelatedVideos?.isEmpty ?? true && mainWatchedVideos.length == 1) {
//       isDisableNext(true);
//     }
//
//     try {
//       scrollController.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.ease);
//     } catch (e) {
//       log("Scrolling Failed");
//     }
//   }
//
//   Future<void> onGetVideoDetails(String videoId) async {
//     isVideoDetailsLoading.value = true;
//
//     // >>>>>>>>>>>> This is Used to Clear Previous Data <<<<<<<<<<<<
//     videoDetailsModel = null;
//
//     videoDetailsModel = await VideoDetailsApi.callApi(Database.loginUserId!, videoId, 1);
//     if (videoDetailsModel != null) {
//       isLike.value = videoDetailsModel?.detailsOfVideo?.isLike ?? false;
//       isDisLike.value = videoDetailsModel?.detailsOfVideo?.isDislike ?? false;
//       isSubscribe.value = videoDetailsModel?.detailsOfVideo?.isSubscribed ?? false;
//       isSave.value = videoDetailsModel?.detailsOfVideo?.isSaveToWatchLater ?? false;
//
//       customChanges["like"] = videoDetailsModel!.detailsOfVideo!.like!;
//       customChanges["disLike"] = videoDetailsModel!.detailsOfVideo!.dislike!;
//       customChanges["comment"] = videoDetailsModel!.detailsOfVideo!.totalComments!;
//       customChanges["subscribe"] = videoDetailsModel!.detailsOfVideo!.totalSubscribers!;
//
//       isVideoDetailsLoading.value = false;
//
//       createWatchHistory();
//
//       // >>>>>>>>>>>> This is Used to Increase Views <<<<<<<<<<<<
//     }
//   }
//
//   Future<void> onCreateHistory() async {
//     if (Database.channelId != null && videoPlayerController != null && videoDetailsModel?.detailsOfVideo != null) {
//       final watchTime = videoPlayerController!.value.position.inSeconds / 60;
//       AppSettings.showLog("Video Watch Time => $watchTime");
//
//       if (isVideoSkip == false) {
//         await CreateWatchHistoryApi.callApi(
//           loginUserId: Database.loginUserId!,
//           videoId: videoDetailsModel!.detailsOfVideo!.id!,
//           videoChannelId: videoDetailsModel!.detailsOfVideo!.channelId!,
//           videoUserId: videoDetailsModel!.detailsOfVideo!.userId!,
//           watchTimeInMinute: watchTime,
//         );
//       }
//     }
//   }
//
//   void onToggleVolume() {
//     if (isSpeaker.value) {
//       isSpeaker.value = false;
//       videoPlayerController?.setVolume(0);
//     } else {
//       videoPlayerController?.setVolume(100);
//       isSpeaker.value = true;
//     }
//   }
//
//   ///
//
//   Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
//     try {
//       isVideoSkip = false;
//       isGetVideoRewardCoin = false;
//
//       String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);
//
//       videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
//
//       await videoPlayerController?.initialize();
//
//       if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
//         if (Database.onGetVideoUrl(videoId) == null) {
//           Database.onSetVideoUrl(videoId, videoPath);
//         }
//
//         chewieController = ChewieController(
//           videoPlayerController: videoPlayerController!,
//           autoPlay: true, // Don't auto-play, we'll control this manually
//           looping: isLoop.value,
//           allowedScreenSleep: false,
//           allowMuting: false,
//           showControlsOnInitialize: false,
//           showControls: false,
//         );
//
//         videoPlayerController?.addListener(
//           () async {
//             if (Get.currentRoute != "/NormalVideoDetailsView") {
//               videoPlayerController?.pause();
//               AppSettings.showLog("Video Playing Routes Changes...");
//             }
//
//             if ((videoPlayerController?.value.isInitialized ?? false)) {
//               if (videoPlayerController!.value.isBuffering) {
//                 if (isVideoLoading == false) {
//                   isVideoLoading = true;
//                   update(["onLoading"]);
//                 }
//               } else {
//                 if (isVideoLoading == true) {
//                   isVideoLoading = false;
//                   update(["onLoading"]);
//                 }
//               }
//               update(["onProgressLine", "onVideoTime", "onVideoPlayPause"]);
//
//               if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
//                 AppSettings.showLog("Playing Video Complete...");
//
//                 if (isGetVideoRewardCoin == false && isVideoSkip == false) {
//                   isGetVideoRewardCoin = true;
//                   VideoEngagementRewardApi.callApi(
//                       loginUserId: Database.loginUserId ?? "",
//                       videoId: videoId,
//                       totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
//                 }
//
//                 onCreateHistory();
//                 if (AppSettings.isAutoPlayVideo.value) {
//                   if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
//                     isDisablePrevious(false);
//                   }
//
//                   selectedWatchedVideo++;
//
//                   if (selectedWatchedVideo < mainWatchedVideos.length) {
//                     onDisposeVideoPlayer();
//                     init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//                   } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//                     onCreateHistory();
//                     onDisposeVideoPlayer();
//                     isDisablePrevious(false);
//                     mainWatchedVideos.insert(
//                         selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//                     init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//                     mainRelatedVideos = null;
//                     update(["onGetRelatedVideos"]);
//                   } else {
//                     isDisableNext(true);
//                   }
//                 }
//               }
//             }
//           },
//         );
//
//         if (isSpeaker.value == false) {
//           videoPlayerController?.setVolume(0);
//         }
//       }
//
//       update(["onVideoInitialize"]);
//     } catch (e) {
//       AppSettings.showLog("Normal Video Initialization Failed => $e");
//       onDisposeVideoPlayer();
//     }
//   }
//
//   void onChangeVideoLoading() {
//     isVideoLoading = !isVideoLoading;
//     update(["onChangeVideoLoading"]);
//   }
//
//   void onDisposeVideoPlayer() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     chewieController = null;
//     update(["onVideoInitialize"]);
//   }
//
//   void onNextVideo() {
//     isDisablePrevious(false);
//
//     selectedWatchedVideo++;
//
//     if (selectedWatchedVideo != mainWatchedVideos.length) {
//       onDisposeVideoPlayer();
//       onCreateHistory();
//       init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//     } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//       onCreateHistory();
//       onDisposeVideoPlayer();
//       isDisablePrevious(false);
//       mainWatchedVideos.insert(
//           selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//       init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//       mainRelatedVideos = null;
//       update(["onGetRelatedVideos"]);
//     } else {
//       isDisableNext(true);
//     }
//     // if (selectedWatchedVideo == (mainWatchedVideos.length - 1)) {
//     //   isDisableNext(true);
//     // }
//   }
//
//   void onPreviousVideo() async {
//     isDisableNext(false);
//
//     selectedWatchedVideo--;
//     if (selectedWatchedVideo >= 0) {
//       onDisposeVideoPlayer();
//       init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//     }
//     if (selectedWatchedVideo == 0) {
//       isDisablePrevious(true);
//     }
//   }
//
//   // Future<void> onRotate(double aspectRatio) async {
//   // if (videoPlayerController != null) {
//   //   chewieController = null;
//   //
//   //   chewieController = ChewieController(
//   //     videoPlayerController: videoPlayerController!,
//   //     aspectRatio: aspectRatio,
//   //     looping: isLoop.value,
//   //     allowedScreenSleep: false,
//   //     allowMuting: false,
//   //     showControlsOnInitialize: false,
//   //     showControls: false,
//   //   );
//   //   update(["onVideoInitialize"]);
//   // }
//   // }
//
//   Future<void> onChangeLoop() async {
//     if (videoPlayerController != null) {
//       chewieController = null;
//
//       chewieController = ChewieController(
//         videoPlayerController: videoPlayerController!,
//         looping: isLoop.value,
//         allowedScreenSleep: false,
//         allowMuting: false,
//         showControlsOnInitialize: false,
//         showControls: false,
//       );
//       update(["onVideoInitialize"]);
//     }
//   }
//
//   void createWatchHistory() async {
//     if (AppSettings.isCreateHistory.value) {
//       AppSettings.showLog("Create Watch History Method Called");
//       bool isAvailable = false;
//       for (int index = 0; index < WatchHistory.mainWatchHistory.length; index++) {
//         if (WatchHistory.mainWatchHistory[index]["videoId"] == videoDetailsModel!.detailsOfVideo!.id) {
//           AppSettings.showLog("Replace Watch History");
//           WatchHistory.mainWatchHistory.insert(0, WatchHistory.mainWatchHistory.removeAt(index));
//           isAvailable = true;
//           break;
//         } else {
//           AppSettings.showLog("Not Match");
//         }
//       }
//       if (isAvailable == false) {
//         AppSettings.showLog("Create New Watch History");
//         WatchHistory.mainWatchHistory.insert(
//           0,
//           {
//             "id": DateTime.now().millisecondsSinceEpoch,
//             "videoId": videoDetailsModel!.detailsOfVideo!.id,
//             "videoTitle": videoDetailsModel!.detailsOfVideo!.title,
//             "videoType": videoDetailsModel!.detailsOfVideo!.videoType,
//             "videoTime": videoDetailsModel!.detailsOfVideo!.videoTime,
//             "videoUrl": videoDetailsModel!.detailsOfVideo!.videoUrl,
//             "videoImage": videoDetailsModel!.detailsOfVideo!.videoImage,
//             "views": videoDetailsModel!.detailsOfVideo!.views,
//             "channelName": videoDetailsModel!.detailsOfVideo!.channelName,
//           },
//         );
//       }
//       WatchHistory.onSet();
//     }
//   }
//
//   void showVideoControls() {
//     isShowVideoControls = !isShowVideoControls;
//     update(["onShowControls"]);
//   }
//
//   Future<void> forwardSkipVideo() async {
//     await videoPlayerController?.seekTo((await videoPlayerController?.position)! + const Duration(seconds: 10));
//     isVideoSkip = true;
//   }
//
//   Future<void> backwardSkipVideo() async {
//     await videoPlayerController?.seekTo((await videoPlayerController?.position)! - const Duration(seconds: 10));
//   }
//
//   ///
//
//   bool adCompleted = false;
//
//   void onAdCompleted() {
//     debugPrint('Ad completed, starting video playback');
//     adCompleted = true;
//
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
//         videoPlayerController?.play();
//       }
//       update(["onVideoInitialize", "onAdCompleted"]);
//     });
//   }
//
//   RxBool isLoadingAds = true.obs;
//
//   ///
//
//   bool showAd = true;
//   bool isVideoReady = false;
//
//   void _preloadVideo() {
//     videoPlayerController = VideoPlayerController.network('${videoPlayerController}');
//
//     videoPlayerController!.initialize().then((_) {
//       // Create chewie controller but with autoPlay: false
//       chewieController = ChewieController(
//         videoPlayerController: videoPlayerController!,
//         autoPlay: true, // Don't auto-play
//         looping: false,
//       );
//
//       isVideoReady = true;
//       update();
//
//       log('Video preloaded but not started');
//     });
//   }
//
//   void onAdCompleted1() {
//     log('Ad completed, starting main video...');
//
//     showAd = false;
//     videoPlayerController!.play();
//     update(['adComplete']);
//
//     // // Start video playback after ad completes
//     // Future.delayed(const Duration(milliseconds: 300), () {
//     //   if (isVideoReady && videoPlayerController != null) {
//     //     videoPlayerController!.play();
//     //     log('Video playback started');
//     //   }
//     // });
//   }
//
//   @override
//   void onClose() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     VideoAdServices.dispose();
//     super.onClose();
//   }
//
//   ///
// }
//
// class WatchedVideoModel {
//   final String videoId;
//   final String videoUrl;
//   WatchedVideoModel({required this.videoId, required this.videoUrl});
// }

///

/*class NormalVideoDetailsController extends GetxController {
  final yourChannelController = Get.find<YourChannelController>();

  TextEditingController commentController = TextEditingController();
  ScrollController scrollController = ScrollController();

  GetRelatedVideoModel? _getRelatedVideoModel;
  VideoDetailsModel? videoDetailsModel;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  List<Data>? mainRelatedVideos;

  int selectedWatchedVideo = 0;
  List<WatchedVideoModel> mainWatchedVideos = [];

  String videoId = "";

  RxBool isLike = false.obs;
  RxBool isDisLike = false.obs;
  RxBool isSubscribe = false.obs;
  RxBool isSave = false.obs;
  RxMap customChanges = {"like": 0, "disLike": 0, "comment": 0, "share": 0}.obs;

  RxBool isDisableNext = false.obs;
  RxBool isDisablePrevious = false.obs;

  bool isVideoLoading = false;
  bool isShowVideoControls = false;
  RxBool isVideoDetailsLoading = true.obs;

  RxBool isDownloading = false.obs;

  RxBool isLoop = false.obs;
  RxBool isSpeaker = true.obs;
  RxInt currentSpeedIndex = 2.obs;
  final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // Video Engagement Reward...
  bool isVideoSkip = false;
  bool isGetVideoRewardCoin = false;

  // Mid-roll ad variables - Updated for 30 second timing
  bool showAd = false;
  bool isAdLoading = false; // Add this for ad loading state
  bool isVideoReady = false;
  bool hasShownMidrollAd = false;
  Duration pausedPosition = Duration.zero;
  bool wasPlayingBeforeAd = false;
  int adShowCount = 0; // Track how many ads have been shown
  List<int> adTimings = [30, 60, 90, 120]; // Show ads at 30s, 60s, 90s, 120s etc.
  List<int> dotTiming = [35, 65, 95, 125]; // Show ads at 30s, 60s, 90s, 120s etc.

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> init(String videoId, String videoUrl) async {
    this.videoId = videoId;
    onGetRelatedVideos(videoId);
    onGetVideoDetails(videoId);

    await initializeVideoPlayer(videoId, videoUrl);
  }

  void onGetPlayListVideos() {
    if (yourChannelController.selectedPlayList != null) {
      AppSettings.showLog("Selected PlayList => ${yourChannelController.selectedPlayList}");
      for (int i = 0; i < yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos!.length; i++) {
        if (yourChannelController.selectedPlayListVideo < i) {
          final index = yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos![i];
          mainWatchedVideos.add(WatchedVideoModel(videoId: index.videoId!, videoUrl: index.videoUrl!));
        }
      }
    }
  }

  Future<void> onGetRelatedVideos(String videoId) async {
    mainRelatedVideos = null;
    _getRelatedVideoModel = await GetRelatedVideoApi.callApi(loginUserId: Database.loginUserId!, videoId: videoId);

    if (_getRelatedVideoModel != null) {
      mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
    }
    AppSettings.showLog("Playing Related Video Length => ${mainRelatedVideos?.length}");

    mainRelatedVideos?.shuffle();

    update(["onGetRelatedVideos"]);

    if (mainRelatedVideos?.isEmpty ?? true && mainWatchedVideos.length == 1) {
      isDisableNext(true);
    }

    try {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.ease);
    } catch (e) {
      log("Scrolling Failed");
    }
  }

  Future<void> onGetVideoDetails(String videoId) async {
    isVideoDetailsLoading.value = true;

    videoDetailsModel = null;

    videoDetailsModel = await VideoDetailsApi.callApi(Database.loginUserId!, videoId, 1);
    if (videoDetailsModel != null) {
      isLike.value = videoDetailsModel?.detailsOfVideo?.isLike ?? false;
      isDisLike.value = videoDetailsModel?.detailsOfVideo?.isDislike ?? false;
      isSubscribe.value = videoDetailsModel?.detailsOfVideo?.isSubscribed ?? false;
      isSave.value = videoDetailsModel?.detailsOfVideo?.isSaveToWatchLater ?? false;

      customChanges["like"] = videoDetailsModel!.detailsOfVideo!.like!;
      customChanges["disLike"] = videoDetailsModel!.detailsOfVideo!.dislike!;
      customChanges["comment"] = videoDetailsModel!.detailsOfVideo!.totalComments!;
      customChanges["subscribe"] = videoDetailsModel!.detailsOfVideo!.totalSubscribers!;

      isVideoDetailsLoading.value = false;

      createWatchHistory();
    }
  }

  Future<void> onCreateHistory() async {
    if (Database.channelId != null && videoPlayerController != null && videoDetailsModel?.detailsOfVideo != null) {
      final watchTime = videoPlayerController!.value.position.inSeconds / 60;
      AppSettings.showLog("Video Watch Time => $watchTime");

      if (isVideoSkip == false) {
        await CreateWatchHistoryApi.callApi(
          loginUserId: Database.loginUserId!,
          videoId: videoDetailsModel!.detailsOfVideo!.id!,
          videoChannelId: videoDetailsModel!.detailsOfVideo!.channelId!,
          videoUserId: videoDetailsModel!.detailsOfVideo!.userId!,
          watchTimeInMinute: watchTime,
        );
      }
    }
  }

  void onToggleVolume() {
    if (isSpeaker.value) {
      isSpeaker.value = false;
      videoPlayerController?.setVolume(0);
    } else {
      videoPlayerController?.setVolume(100);
      isSpeaker.value = true;
    }
  }

  Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
    try {
      isVideoSkip = false;
      isGetVideoRewardCoin = false;
      hasShownMidrollAd = false;
      showAd = false;
      isAdLoading = false; // Reset ad loading state
      wasPlayingBeforeAd = false;
      adShowCount = 0; // Reset ad count for new video

      String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);

      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoPlayerController?.initialize();

      if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
        if (Database.onGetVideoUrl(videoId) == null) {
          Database.onSetVideoUrl(videoId, videoPath);
        }

        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoPlay: true,
          looping: isLoop.value,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
        );

        videoPlayerController?.addListener(() async {
          if (Get.currentRoute != "/NormalVideoDetailsView") {
            videoPlayerController?.pause();
            AppSettings.showLog("Video Playing Routes Changes...");
          }

          if ((videoPlayerController?.value.isInitialized ?? false)) {
            if (videoPlayerController!.value.isBuffering) {
              if (isVideoLoading == false) {
                isVideoLoading = true;
                update(["onLoading"]);
              }
            } else {
              if (isVideoLoading == true) {
                isVideoLoading = false;
                update(["onLoading"]);
              }
            }
            update(["onProgressLine", "onVideoTime", "onVideoPlayPause"]);

            // Check for mid-roll ad timing (30 seconds intervals)
            _checkMidrollAdTiming();

            if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
              AppSettings.showLog("Playing Video Complete...");

              if (isGetVideoRewardCoin == false && isVideoSkip == false) {
                isGetVideoRewardCoin = true;
                VideoEngagementRewardApi.callApi(
                    loginUserId: Database.loginUserId ?? "",
                    videoId: videoId,
                    totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
              }

              onCreateHistory();
              if (AppSettings.isAutoPlayVideo.value) {
                if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
                  isDisablePrevious(false);
                }

                selectedWatchedVideo++;

                if (selectedWatchedVideo < mainWatchedVideos.length) {
                  onDisposeVideoPlayer();
                  init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
                } else if (mainRelatedVideos?.isNotEmpty ?? false) {
                  onCreateHistory();
                  onDisposeVideoPlayer();
                  isDisablePrevious(false);
                  mainWatchedVideos.insert(
                      selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
                  init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
                  mainRelatedVideos = null;
                  update(["onGetRelatedVideos"]);
                } else {
                  isDisableNext(true);
                }
              }
            }
          }
        });

        if (isSpeaker.value == false) {
          videoPlayerController?.setVolume(0);
        }

        isVideoReady = true;
      }

      update(["onVideoInitialize"]);
    } catch (e) {
      AppSettings.showLog("Normal Video Initialization Failed => $e");
      onDisposeVideoPlayer();
    }
  }

  void _checkMidrollAdTiming() {
    // Check if we should show an ad at 30-second intervals
    if (!showAd && videoPlayerController != null && videoPlayerController!.value.isPlaying && adShowCount < adTimings.length) {
      int currentSeconds = videoPlayerController!.value.position.inSeconds;
      int targetTime = adTimings[adShowCount];

      // Show ad when video reaches the target time (30s, 60s, 90s, etc.)
      if (currentSeconds >= targetTime) {
        _showMidrollAd();
      }
    }
  }

// બેહતર approach - ad service ના callbacks વાપરો:

  void _showMidrollAd() {
    if (showAd) return;

    AppSettings.showLog("Showing mid-roll ad at ${videoPlayerController!.value.position.inSeconds} seconds");

    // Store current state
    wasPlayingBeforeAd = videoPlayerController?.value.isPlaying ?? false;
    pausedPosition = videoPlayerController!.value.position;

    // Pause the video
    videoPlayerController?.pause();

    // Show loading state first
    isAdLoading = true;
    showAd = true;
    adShowCount++; // Increment ad count

    update([
      "adComplete",
      "onVideoPlayPause",
      "onShowControls",
      "onProgressLine",
    ]);
  }

// Ad started callback - આ method call કરો જ્યારે ad actually start થાય
  void onAdStarted() {
    isAdLoading = false;
    AppSettings.showLog("Ad started playing, hiding loader");

    update(['adComplete']);
  }

// Ad failed callback - આ method call કરો જ્યારે ad load fail થાય
  void onAdFailed() {
    AppSettings.showLog("Ad failed to load, resuming video");
    showAd = false;
    isAdLoading = false;
    adShowCount--; // Decrement ad count as ad failed

    // Resume video
    if (videoPlayerController != null) {
      videoPlayerController!.seekTo(pausedPosition);
      if (wasPlayingBeforeAd) {
        Future.delayed(const Duration(milliseconds: 300), () {
          videoPlayerController?.play();
        });
      }
    }

    update(['adComplete', 'onVideoPlayPause']);
  }

  void onAdCompleted1() {
    log('Mid-roll ad completed, resuming video...');

    showAd = false;
    isAdLoading = false; // Reset loading state

    // Resume video from where it was paused if it was playing before ad
    if (videoPlayerController != null) {
      videoPlayerController!.seekTo(pausedPosition);

      // Only resume if video was playing before ad
      if (wasPlayingBeforeAd) {
        Future.delayed(const Duration(milliseconds: 300), () {
          videoPlayerController?.play();
        });
      }
    }

    update(['adComplete', 'onVideoPlayPause']);
  }

  void onChangeVideoLoading() {
    isVideoLoading = !isVideoLoading;
    update(["onChangeVideoLoading"]);
  }

  void onDisposeVideoPlayer() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    chewieController = null;
    showAd = false;
    isAdLoading = false; // Reset loading state
    hasShownMidrollAd = false;
    wasPlayingBeforeAd = false;
    adShowCount = 0; // Reset ad count
    update(["onVideoInitialize"]);
  }

  void onNextVideo() {
    isDisablePrevious(false);

    selectedWatchedVideo++;

    if (selectedWatchedVideo != mainWatchedVideos.length) {
      onDisposeVideoPlayer();
      onCreateHistory();
      init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
    } else if (mainRelatedVideos?.isNotEmpty ?? false) {
      onCreateHistory();
      onDisposeVideoPlayer();
      isDisablePrevious(false);
      mainWatchedVideos.insert(
          selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
      init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
      mainRelatedVideos = null;
      update(["onGetRelatedVideos"]);
    } else {
      isDisableNext(true);
    }
  }

  void onPreviousVideo() async {
    isDisableNext(false);

    selectedWatchedVideo--;
    if (selectedWatchedVideo >= 0) {
      onDisposeVideoPlayer();
      init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
    }
    if (selectedWatchedVideo == 0) {
      isDisablePrevious(true);
    }
  }

  Future<void> onChangeLoop() async {
    if (videoPlayerController != null) {
      chewieController = null;

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        looping: isLoop.value,
        allowedScreenSleep: false,
        allowMuting: false,
        showControlsOnInitialize: false,
        showControls: false,
      );
      update(["onVideoInitialize"]);
    }
  }

  void createWatchHistory() async {
    if (AppSettings.isCreateHistory.value) {
      AppSettings.showLog("Create Watch History Method Called");
      bool isAvailable = false;
      for (int index = 0; index < WatchHistory.mainWatchHistory.length; index++) {
        if (WatchHistory.mainWatchHistory[index]["videoId"] == videoDetailsModel!.detailsOfVideo!.id) {
          AppSettings.showLog("Replace Watch History");
          WatchHistory.mainWatchHistory.insert(0, WatchHistory.mainWatchHistory.removeAt(index));
          isAvailable = true;
          break;
        } else {
          AppSettings.showLog("Not Match");
        }
      }
      if (isAvailable == false) {
        AppSettings.showLog("Create New Watch History");
        WatchHistory.mainWatchHistory.insert(
          0,
          {
            "id": DateTime.now().millisecondsSinceEpoch,
            "videoId": videoDetailsModel!.detailsOfVideo!.id,
            "videoTitle": videoDetailsModel!.detailsOfVideo!.title,
            "videoType": videoDetailsModel!.detailsOfVideo!.videoType,
            "videoTime": videoDetailsModel!.detailsOfVideo!.videoTime,
            "videoUrl": videoDetailsModel!.detailsOfVideo!.videoUrl,
            "videoImage": videoDetailsModel!.detailsOfVideo!.videoImage,
            "views": videoDetailsModel!.detailsOfVideo!.views,
            "channelName": videoDetailsModel!.detailsOfVideo!.channelName,
          },
        );
      }
      WatchHistory.onSet();
    }
  }

  void showVideoControls() {
    // Don't show controls during ad
    if (showAd) return;

    isShowVideoControls = !isShowVideoControls;
    update(["onShowControls"]);
  }

  Future<void> forwardSkipVideo() async {
    // Don't allow skip during ad
    if (showAd) return;

    await videoPlayerController?.seekTo((await videoPlayerController?.position)! + const Duration(seconds: 10));
    isVideoSkip = true;
  }

  Future<void> backwardSkipVideo() async {
    // Don't allow skip during ad
    if (showAd) return;

    await videoPlayerController?.seekTo((await videoPlayerController?.position)! - const Duration(seconds: 10));
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    VideoAdServices.dispose();
    super.onClose();
  }
}

class WatchedVideoModel {
  final String videoId;
  final String videoUrl;
  WatchedVideoModel({required this.videoId, required this.videoUrl});
}*/
class NormalVideoDetailsController extends GetxController {
  final yourChannelController = Get.find<YourChannelController>();

  TextEditingController commentController = TextEditingController();
  ScrollController scrollController = ScrollController();

  GetRelatedVideoModel? _getRelatedVideoModel;
  VideoDetailsModel? videoDetailsModel;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  List<Data>? mainRelatedVideos;

  int selectedWatchedVideo = 0;
  List<WatchedVideoModel> mainWatchedVideos = [];

  String videoId = "";

  RxBool isLike = false.obs;
  RxBool isDisLike = false.obs;
  RxBool isSubscribe = false.obs;
  RxBool isSave = false.obs;
  RxMap customChanges = {"like": 0, "disLike": 0, "comment": 0, "share": 0}.obs;

  RxBool isDisableNext = false.obs;
  RxBool isDisablePrevious = false.obs;

  bool isVideoLoading = false;
  bool isShowVideoControls = false;
  RxBool isVideoDetailsLoading = true.obs;

  RxBool isDownloading = false.obs;

  RxBool isLoop = false.obs;
  RxBool isSpeaker = true.obs;
  RxInt currentSpeedIndex = 2.obs;
  final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // Video Engagement Reward...
  bool isVideoSkip = false;
  bool isGetVideoRewardCoin = false;

  // Dynamic Ad Variables - આ બદલાયું છે
  bool showAd = false;
  bool isAdLoading = false;
  bool isVideoReady = false;
  bool hasShownMidrollAd = false;
  Duration pausedPosition = Duration.zero;
  bool wasPlayingBeforeAd = false;
  int adShowCount = 0;

  // Dynamic ad timing - video length base પર calculate થશે
  List<int> adTimings = [];
  int totalAdsToShow = 2;
  int minAdInterval = 30;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> init(String videoId, String videoUrl) async {
    this.videoId = videoId;
    onGetRelatedVideos(videoId);
    onGetVideoDetails(videoId);

    await initializeVideoPlayer(videoId, videoUrl);
  }

  // નવી method - Video length base પર ad timings calculate કરે
  void _calculateAdTimings1() {
    if (videoPlayerController == null || !videoPlayerController!.value.isInitialized) {
      adTimings = [];
      return;
    }

    int totalVideoSeconds = videoPlayerController!.value.duration.inSeconds;
    adTimings.clear();

    AppSettings.showLog("Video total duration: $totalVideoSeconds seconds");

    // Video length according to ad strategy
    if (totalVideoSeconds < 60) {
      // 1 minute થી ઓછું - no ads
      adTimings = [];
      AppSettings.showLog("Video too short - No ads");
    } else if (totalVideoSeconds < 180) {
      // 3 minute થી ઓછું - 1 ad at middle
      adTimings = [totalVideoSeconds ~/ 2];
      AppSettings.showLog("Short video - 1 ad at: $adTimings");
    } else if (totalVideoSeconds < 360) {
      // 6 minute થી ઓછું - 2 ads
      int firstAd = totalVideoSeconds ~/ 3;
      int secondAd = (totalVideoSeconds * 2) ~/ 3;
      adTimings = [firstAd, secondAd];
      AppSettings.showLog("Medium video - 2 ads at: $adTimings");
    } else {
      // 6 minute થી વધુ - 3 ads (equally distributed)
      int firstAd = totalVideoSeconds ~/ 4;
      int secondAd = totalVideoSeconds ~/ 2;
      int thirdAd = (totalVideoSeconds * 3) ~/ 4;

      // Make sure minimum 30 seconds gap
      if (firstAd < minAdInterval) firstAd = minAdInterval;
      if (secondAd - firstAd < minAdInterval) secondAd = firstAd + minAdInterval;
      if (thirdAd - secondAd < minAdInterval) thirdAd = secondAd + minAdInterval;

      adTimings = [firstAd, secondAd, thirdAd];
      AppSettings.showLog("Long video - 3 ads at: $adTimings");
    }

    // Reset ad count for new video
    adShowCount = 0;
  }

  // નવી method - Video length base પર ad timings calculate કરે (Fixed 2 ads માટે)
  void _calculateAdTimings() {
    if (videoPlayerController == null || !videoPlayerController!.value.isInitialized) {
      adTimings = [];
      return;
    }

    int totalVideoSeconds = videoPlayerController!.value.duration.inSeconds;
    adTimings.clear();

    AppSettings.showLog("Video total duration: $totalVideoSeconds seconds");

    // Video length according to ad strategy - બધા videos માં માત્ર 2 ads
    if (totalVideoSeconds < 60) {
      // 1 minute થી ઓછું - no ads (too short)
      adTimings = [];
      AppSettings.showLog("Video too short - No ads");
    } else {
      // બધા videos માં માત્ર 2 ads show કરવા - fixed strategy
      int firstAd = totalVideoSeconds ~/ 3; // Video ના 1/3 પર
      int secondAd = (totalVideoSeconds * 2) ~/ 3; // Video ના 2/3 પર

      // Make sure minimum 30 seconds gap between ads
      if (firstAd < minAdInterval) firstAd = minAdInterval;
      if (secondAd - firstAd < minAdInterval) secondAd = firstAd + minAdInterval;

      // Make sure second ad is at least 30 seconds before video end
      if (totalVideoSeconds - secondAd < 30) {
        secondAd = totalVideoSeconds - 30;
        if (secondAd <= firstAd) {
          // If not enough space for 2 ads, show only 1
          adTimings = [firstAd];
          AppSettings.showLog("Only 1 ad possible at: $adTimings");
        } else {
          adTimings = [firstAd, secondAd];
          AppSettings.showLog("2 ads scheduled at: $adTimings");
        }
      } else {
        adTimings = [firstAd, secondAd];
        AppSettings.showLog("2 ads scheduled at: $adTimings");
      }
    }

    // Reset ad count for new video
    adShowCount = 0;
    totalAdsToShow = adTimings.length; // Update total ads based on calculated timings
  }

// Alternative approach - If you want exactly 2 ads for ALL videos (even very long ones)
  void _calculateAdTimingsAlternative() {
    if (videoPlayerController == null || !videoPlayerController!.value.isInitialized) {
      adTimings = [];
      return;
    }

    int totalVideoSeconds = videoPlayerController!.value.duration.inSeconds;
    adTimings.clear();

    AppSettings.showLog("Video total duration: $totalVideoSeconds seconds");

    if (totalVideoSeconds < 60) {
      // Very short videos - no ads
      adTimings = [];
      AppSettings.showLog("Video too short - No ads");
    } else if (totalVideoSeconds < 120) {
      // Short videos (1-2 minutes) - only 1 ad in middle
      adTimings = [totalVideoSeconds ~/ 2];
      AppSettings.showLog("Short video - 1 ad at: $adTimings");
    } else {
      // All other videos - exactly 2 ads
      int firstAd = totalVideoSeconds ~/ 3; // At 33% of video
      int secondAd = (totalVideoSeconds * 2) ~/ 3; // At 67% of video

      // Ensure minimum gaps
      if (firstAd < minAdInterval) firstAd = minAdInterval;
      if (secondAd - firstAd < minAdInterval) secondAd = firstAd + minAdInterval;
      if (totalVideoSeconds - secondAd < 30) secondAd = totalVideoSeconds - 30;

      adTimings = [firstAd, secondAd];
      AppSettings.showLog("Exactly 2 ads at: $adTimings");
    }

    // Reset ad count for new video
    adShowCount = 0;
    totalAdsToShow = adTimings.length;
  }

  // નવી method - Ad countdown check કરવા માટે
  bool shouldShowAdCountdown() {
    if (showAd || videoPlayerController == null || adShowCount >= adTimings.length) return false;

    int currentSeconds = videoPlayerController!.value.position.inSeconds;
    int nextAdTime = adTimings[adShowCount];

    // Show countdown 10 seconds before ad
    return currentSeconds >= (nextAdTime - 10) && currentSeconds < nextAdTime;
  }

  // નવી method - Next ad સુધીના સેકન્ડ્સ return કરે
  int getSecondsUntilNextAd() {
    if (videoPlayerController == null || adShowCount >= adTimings.length) return 0;

    int currentSeconds = videoPlayerController!.value.position.inSeconds;
    int nextAdTime = adTimings[adShowCount];

    return nextAdTime - currentSeconds;
  }

  void onGetPlayListVideos() {
    if (yourChannelController.selectedPlayList != null) {
      AppSettings.showLog("Selected PlayList => ${yourChannelController.selectedPlayList}");
      for (int i = 0; i < yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos!.length; i++) {
        if (yourChannelController.selectedPlayListVideo < i) {
          final index = yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos![i];
          mainWatchedVideos.add(WatchedVideoModel(videoId: index.videoId!, videoUrl: index.videoUrl!));
        }
      }
    }
  }

  Future<void> onGetRelatedVideos(String videoId) async {
    mainRelatedVideos = null;
    _getRelatedVideoModel = await GetRelatedVideoApi.callApi(loginUserId: Database.loginUserId!, videoId: videoId);

    if (_getRelatedVideoModel != null) {
      mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
    }
    AppSettings.showLog("Playing Related Video Length => ${mainRelatedVideos?.length}");

    mainRelatedVideos?.shuffle();

    update(["onGetRelatedVideos"]);

    if (mainRelatedVideos?.isEmpty ?? true && mainWatchedVideos.length == 1) {
      isDisableNext(true);
    }

    try {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.ease);
    } catch (e) {
      log("Scrolling Failed");
    }
  }

  Future<void> onGetVideoDetails(String videoId) async {
    isVideoDetailsLoading.value = true;

    videoDetailsModel = null;

    videoDetailsModel = await VideoDetailsApi.callApi(Database.loginUserId!, videoId, 1);
    if (videoDetailsModel != null) {
      isLike.value = videoDetailsModel?.detailsOfVideo?.isLike ?? false;
      isDisLike.value = videoDetailsModel?.detailsOfVideo?.isDislike ?? false;
      isSubscribe.value = videoDetailsModel?.detailsOfVideo?.isSubscribed ?? false;
      isSave.value = videoDetailsModel?.detailsOfVideo?.isSaveToWatchLater ?? false;

      customChanges["like"] = videoDetailsModel!.detailsOfVideo!.like!;
      customChanges["disLike"] = videoDetailsModel!.detailsOfVideo!.dislike!;
      customChanges["comment"] = videoDetailsModel!.detailsOfVideo!.totalComments!;
      customChanges["subscribe"] = videoDetailsModel!.detailsOfVideo!.totalSubscribers!;

      isVideoDetailsLoading.value = false;

      createWatchHistory();
    }
  }

  Future<void> onCreateHistory() async {
    if (Database.channelId != null && videoPlayerController != null && videoDetailsModel?.detailsOfVideo != null) {
      final watchTime = videoPlayerController!.value.position.inSeconds / 60;
      AppSettings.showLog("Video Watch Time => $watchTime");

      if (isVideoSkip == false) {
        await CreateWatchHistoryApi.callApi(
          loginUserId: Database.loginUserId!,
          videoId: videoDetailsModel!.detailsOfVideo!.id!,
          videoChannelId: videoDetailsModel!.detailsOfVideo!.channelId!,
          videoUserId: videoDetailsModel!.detailsOfVideo!.userId!,
          watchTimeInMinute: watchTime,
        );
      }
    }
  }

  void onToggleVolume() {
    if (isSpeaker.value) {
      isSpeaker.value = false;
      videoPlayerController?.setVolume(0);
    } else {
      videoPlayerController?.setVolume(100);
      isSpeaker.value = true;
    }
  }

  Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
    try {
      isVideoSkip = false;
      isGetVideoRewardCoin = false;
      hasShownMidrollAd = false;
      showAd = false;
      isAdLoading = false;
      wasPlayingBeforeAd = false;
      adShowCount = 0;

      String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);

      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoPlayerController?.initialize();

      if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
        if (Database.onGetVideoUrl(videoId) == null) {
          Database.onSetVideoUrl(videoId, videoPath);
        }

        // Video initialize થયા પછી ad timings calculate કરો
        _calculateAdTimings();

        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoPlay: true,
          looping: isLoop.value,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
        );

        videoPlayerController?.addListener(() async {
          if (Get.currentRoute != "/NormalVideoDetailsView") {
            videoPlayerController?.pause();
            AppSettings.showLog("Video Playing Routes Changes...");
          }

          if ((videoPlayerController?.value.isInitialized ?? false)) {
            if (videoPlayerController!.value.isBuffering) {
              if (isVideoLoading == false) {
                isVideoLoading = true;
                update(["onLoading"]);
              }
            } else {
              if (isVideoLoading == true) {
                isVideoLoading = false;
                update(["onLoading"]);
              }
            }

            // Update all UI elements including countdown
            update(["onProgressLine", "onVideoTime", "onVideoPlayPause", "adComplete"]);

            // Check for mid-roll ad timing
            _checkMidrollAdTiming();

            if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
              AppSettings.showLog("Playing Video Complete...");

              if (isGetVideoRewardCoin == false && isVideoSkip == false) {
                isGetVideoRewardCoin = true;
                VideoEngagementRewardApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: videoId, totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
              }

              onCreateHistory();
              if (AppSettings.isAutoPlayVideo.value) {
                if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
                  isDisablePrevious(false);
                }

                selectedWatchedVideo++;

                if (selectedWatchedVideo < mainWatchedVideos.length) {
                  onDisposeVideoPlayer();
                  init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
                } else if (mainRelatedVideos?.isNotEmpty ?? false) {
                  onCreateHistory();
                  onDisposeVideoPlayer();
                  isDisablePrevious(false);
                  mainWatchedVideos.insert(selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
                  init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
                  mainRelatedVideos = null;
                  update(["onGetRelatedVideos"]);
                } else {
                  isDisableNext(true);
                }
              }
            }
          }
        });

        if (isSpeaker.value == false) {
          videoPlayerController?.setVolume(0);
        }

        isVideoReady = true;
      }

      update(["onVideoInitialize"]);
    } catch (e) {
      AppSettings.showLog("Normal Video Initialization Failed => $e");
      onDisposeVideoPlayer();
    }
  }

  void _checkMidrollAdTiming() {
    // Enhanced ad timing check
    if (!showAd && videoPlayerController != null && videoPlayerController!.value.isPlaying && adShowCount < adTimings.length) {
      int currentSeconds = videoPlayerController!.value.position.inSeconds;
      int targetTime = adTimings[adShowCount];

      // Show ad when video reaches the exact target time
      if (currentSeconds >= targetTime) {
        _showMidrollAd();
      }
    }
  }

  void _showMidrollAd() async {
    if (showAd) return;

    AppSettings.showLog("Showing mid-roll ad ${adShowCount + 1}/${adTimings.length} at ${videoPlayerController!.value.position.inSeconds} seconds");

    // Store current state
    wasPlayingBeforeAd = videoPlayerController?.value.isPlaying ?? false;
    pausedPosition = videoPlayerController!.value.position;

    // Pause the video
    // videoPlayerController?.pause();
    Future.delayed(const Duration(milliseconds: 200), () async {
      try {
        await videoPlayerController?.pause();
      } catch (e) {
        Utils.showLog("Pause failed: $e");
      }
    });

    // Show loading state first
    isAdLoading = true;
    showAd = true;
    adShowCount++;

    update([
      "adComplete",
      "onVideoPlayPause",
      "onShowControls",
      "onProgressLine",
    ]);
  }

  // Ad started callback
  void onAdStarted() {
    isAdLoading = false;
    AppSettings.showLog("Ad started playing, hiding loader");
    update(['adComplete', 'onVideoPlayPause']);
  }

  // Ad failed callback
  void onAdFailed() {
    AppSettings.showLog("Ad failed to load, resuming video");
    showAd = false;
    isAdLoading = false;
    adShowCount--; // Decrement as ad failed

    // Resume video
    if (videoPlayerController != null) {
      videoPlayerController!.seekTo(pausedPosition);
      if (wasPlayingBeforeAd) {
        Future.delayed(const Duration(milliseconds: 300), () {
          videoPlayerController?.play();
        });
      }
    }

    update(['adComplete', 'onVideoPlayPause']);
  }

  void onAdCompleted1() {
    log('Mid-roll ad completed, resuming video...');

    showAd = false;
    isAdLoading = false;

    // Resume video from paused position
    if (videoPlayerController != null) {
      videoPlayerController!.seekTo(pausedPosition);

      if (wasPlayingBeforeAd) {
        Future.delayed(const Duration(milliseconds: 300), () {
          videoPlayerController?.play();
          update(['adComplete', 'onVideoPlayPause']);
        });
      }
    }
  }

  void onChangeVideoLoading() {
    isVideoLoading = !isVideoLoading;
    update(["onChangeVideoLoading"]);
  }

  void onDisposeVideoPlayer() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    chewieController = null;
    showAd = false;
    isAdLoading = false;
    hasShownMidrollAd = false;
    wasPlayingBeforeAd = false;
    adShowCount = 0;
    adTimings.clear(); // Clear ad timings
    update(["onVideoInitialize", "adComplete"]);
  }

  void onNextVideo() {
    isDisablePrevious(false);

    selectedWatchedVideo++;

    if (selectedWatchedVideo != mainWatchedVideos.length) {
      onDisposeVideoPlayer();
      onCreateHistory();
      init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
    } else if (mainRelatedVideos?.isNotEmpty ?? false) {
      onCreateHistory();
      onDisposeVideoPlayer();
      isDisablePrevious(false);
      mainWatchedVideos.insert(selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
      init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
      mainRelatedVideos = null;
      update(["onGetRelatedVideos"]);
    } else {
      isDisableNext(true);
    }
  }

  void onPreviousVideo() async {
    isDisableNext(false);

    selectedWatchedVideo--;
    if (selectedWatchedVideo >= 0) {
      onDisposeVideoPlayer();
      init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
    }
    if (selectedWatchedVideo == 0) {
      isDisablePrevious(true);
    }
  }

  Future<void> onChangeLoop() async {
    if (videoPlayerController != null) {
      chewieController = null;

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        looping: isLoop.value,
        allowedScreenSleep: false,
        allowMuting: false,
        showControlsOnInitialize: false,
        showControls: false,
      );
      update(["onVideoInitialize"]);
    }
  }

  void createWatchHistory() async {
    if (AppSettings.isCreateHistory.value) {
      AppSettings.showLog("Create Watch History Method Called");
      bool isAvailable = false;
      for (int index = 0; index < WatchHistory.mainWatchHistory.length; index++) {
        if (WatchHistory.mainWatchHistory[index]["videoId"] == videoDetailsModel!.detailsOfVideo!.id) {
          AppSettings.showLog("Replace Watch History");
          WatchHistory.mainWatchHistory.insert(0, WatchHistory.mainWatchHistory.removeAt(index));
          isAvailable = true;
          break;
        } else {
          AppSettings.showLog("Not Match");
        }
      }
      if (isAvailable == false) {
        AppSettings.showLog("Create New Watch History");
        WatchHistory.mainWatchHistory.insert(
          0,
          {
            "id": DateTime.now().millisecondsSinceEpoch,
            "videoId": videoDetailsModel!.detailsOfVideo!.id,
            "videoTitle": videoDetailsModel!.detailsOfVideo!.title,
            "videoType": videoDetailsModel!.detailsOfVideo!.videoType,
            "videoTime": videoDetailsModel!.detailsOfVideo!.videoTime,
            "videoUrl": videoDetailsModel!.detailsOfVideo!.videoUrl,
            "videoImage": videoDetailsModel!.detailsOfVideo!.videoImage,
            "views": videoDetailsModel!.detailsOfVideo!.views,
            "channelName": videoDetailsModel!.detailsOfVideo!.channelName,
          },
        );
      }
      WatchHistory.onSet();
    }
  }

  void showVideoControls() {
    if (showAd) return;

    isShowVideoControls = !isShowVideoControls;
    update(["onShowControls"]);
  }

  Future<void> forwardSkipVideo() async {
    if (showAd) return;

    await videoPlayerController?.seekTo((await videoPlayerController?.position)! + const Duration(seconds: 10));
    isVideoSkip = true;
  }

  Future<void> backwardSkipVideo() async {
    if (showAd) return;

    await videoPlayerController?.seekTo((await videoPlayerController?.position)! - const Duration(seconds: 10));
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    VideoAdServices.dispose();
    super.onClose();
  }
}

class WatchedVideoModel {
  final String videoId;
  final String videoUrl;
  WatchedVideoModel({required this.videoId, required this.videoUrl});
}
