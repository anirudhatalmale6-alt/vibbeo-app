import 'dart:io';

import 'package:vibbeo/pages/admin_settings/admin_settings_api.dart';

class GoogleAdHelper {
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.native ?? "";
    } else if (Platform.isIOS) {
      return AdminSettingsApi.adminSettingsModel?.setting?.ios?.google?.native ?? "";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get nativeVideoAdUnitId {
    if (Platform.isAndroid) {
      return AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.nativeAdVideo ?? "";
    } else if (Platform.isIOS) {
      return AdminSettingsApi.adminSettingsModel?.setting?.ios?.google?.nativeAdVideo ?? "";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.interstitial ?? "";
    } else if (Platform.isIOS) {
      return AdminSettingsApi.adminSettingsModel?.setting?.ios?.google?.interstitial ?? "";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAd => Platform.isAndroid
      ? (AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.reward ?? "")
      : Platform.isIOS
          ? (AdminSettingsApi.adminSettingsModel?.setting?.ios?.google?.reward ?? "")
          : "Platform Not Support !!";

  static String get googleVideoAd => Platform.isAndroid
      ? (AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.videoAdUrl ?? "")
      : Platform.isIOS
          ? (AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.videoAdUrl ?? "")
          : "Platform Not Support !!";
}
