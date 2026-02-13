import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:vibbeo/custom/custom_method/custom_toast.dart';
import 'package:vibbeo/database/database.dart';
import 'package:vibbeo/main.dart';
import 'package:vibbeo/pages/admin_settings/admin_settings_api.dart';
import 'package:vibbeo/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:vibbeo/pages/login_related_page/lets_you_in_page/lets_you_in_view.dart';
import 'package:vibbeo/pages/login_related_page/login_page/login_view.dart';
import 'package:vibbeo/pages/main_home_page/main_home_view.dart';
import 'package:vibbeo/pages/nav_add_page/live_page/widget/device_orientation.dart';
import 'package:vibbeo/pages/nav_shorts_page/nav_shorts_view.dart';
import 'package:vibbeo/pages/nav_subscription_page/nav_subscription_view.dart';
import 'package:vibbeo/pages/on_boarding_page/on_boarding_view.dart';
import 'package:vibbeo/pages/search_page/search_view.dart';
import 'package:vibbeo/utils/branch_io_services.dart';
import 'package:vibbeo/utils/colors/app_color.dart';
import 'package:vibbeo/utils/config/size_config.dart';
import 'package:vibbeo/utils/icons/app_icons.dart';
import 'package:vibbeo/utils/settings/app_settings.dart';
import 'package:vibbeo/utils/string/app_string.dart';
import 'package:vibbeo/utils/style/app_style.dart';
import 'package:quick_actions/quick_actions.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  final quickAction = const QuickActions();
  @override
  void initState() {
    splashScreen();
    super.initState();

    // quickAction.setShortcutItems([
    //   const ShortcutItem(
    //     type: 'Subscriptions',
    //     localizedTitle: 'Subscriptions',
    //     icon: "subscription",
    //   ),
    //   const ShortcutItem(
    //     type: 'Search',
    //     localizedTitle: 'Search',
    //     icon: "search",
    //   ),
    //   const ShortcutItem(
    //     type: 'Shorts',
    //     localizedTitle: 'Shorts',
    //     icon: "shorts",
    //   ),
    // ]);
    //
    // quickAction.initialize(
    //   (type) {
    //     if (type == 'Subscriptions') {
    //       // Navigator.push(
    //       //     context,
    //       //     MaterialPageRoute(
    //       //       builder: (context) => const NavSubscriptionView(),
    //       //     ));
    //
    //       Get.to(const NavSubscriptionView());
    //     } else if (type == 'Search') {
    //       // Navigator.push(
    //       //     context,
    //       //     MaterialPageRoute(
    //       //       builder: (context) => const SearchView(isSearchShorts: false),
    //       //     ));
    //       Get.to(const SearchView(isSearchShorts: false));
    //     } else if (type == 'Shorts') {
    //       // Navigator.push(
    //       //     context,
    //       //     MaterialPageRoute(
    //       //       builder: (context) => const NavShortsView(),
    //       //     ));
    //       Get.to(const NavShortsView());
    //     }
    //   },
    // );
  }

  void splashScreen() {
    if (AdminSettingsApi.adminSettingsModel?.setting != null) {
      // LoadMultipleAds.init();
      Timer(
        const Duration(seconds: 3),
        () {
          BranchIoServices.onListenBranchIoLinks();
          if (Database.isNewUser) {
            if (Database.isOnBoarding) {
              Get.off(() => const LetsYouInView());
            } else {
              Get.off(() => const OnBoardIngScreen());
            }
          } else {
            if (Database.loginUserId != null && GetProfileApi.profileModel?.user != null) {
              if ((GetProfileApi.profileModel?.user?.isBlock == true)) {
                CustomToast.show("You are blocked by admin !!");
              } else {
                Get.offAll(() => const MainHomePageView());
              }
            } else {
              Database.logOut();
              Get.offAll(() => const LoginView());
              // CustomToast.show(AppStrings.someThingWentWrong.tr);
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 150), () {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDarkMode.value ? Brightness.dark : Brightness.light,
        ),
      );
    });
    AppSettings.showLog("Screen Height => ${Get.height}  Screen Width => ${Get.width}");
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: isDarkMode.value ? AppColor.mainDark : null,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Offstage(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(image: AssetImage(AppIcons.appLogo), height: 40, width: 40, fit: BoxFit.contain),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 4),
                Text(AppStrings.appName.tr, style: titleStyle),
              ],
            ),
            const SpinKitCircle(color: AppColor.lightPink, size: 60),
          ],
        ),
      ),
    );
  }
}
