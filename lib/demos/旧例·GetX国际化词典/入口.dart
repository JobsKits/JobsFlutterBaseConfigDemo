import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/demos/旧例·GetX国际化词典/源码/GetX_InternationalDemo.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'GetX_InternationalDemo',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'GetX_InternationalDemo',
  onDispose: () {
    if (Get.isRegistered<source.LanguageController>())
      Get.delete<source.LanguageController>();
  },
);
