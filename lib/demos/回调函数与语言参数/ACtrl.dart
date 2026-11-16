import 'package:get/get.dart';
import 'package:flutter/material.dart';

// 外层设置的回调函数
typedef LocaleCallback = Locale Function();
// 内层设置的回调函数
typedef JobsCallback = Locale Function();

class ACtrl extends GetxController {
  LocaleCallback? localeCallback;
  JobsCallback? jobsCallback;

  void setLocaleCallback(LocaleCallback callback) {
    localeCallback = callback;
  }

  void setJobsCallback() {
    jobsCallback = () {
      return Get.deviceLocale ?? const Locale('en', 'US');
    };
  }

  void useLocaleCallback() {
    if (localeCallback != null) {
      Locale currentLocale = localeCallback!();
      debugPrint("Current device language: ${currentLocale.languageCode}");
      debugPrint("Current device country: ${currentLocale.countryCode}");
    } else {
      debugPrint("No locale callback set.");
    }
  }

  void useJobsCallback() {
    if (jobsCallback != null) {
      Locale currentLocale = jobsCallback!();
      debugPrint("Current device language: ${currentLocale.languageCode}");
      debugPrint("Current device country: ${currentLocale.countryCode}");
    } else {
      debugPrint("No jobs callback set.");
    }
  }

  @override
  void onInit() {
    super.onInit();
    // 初始化时设置回调函数
    setJobsCallback();
  }
}
