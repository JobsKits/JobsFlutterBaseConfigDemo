import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/demos/旧例·GetX应用容器/源码/GetMaterialAppDemo.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'GetMaterialAppDemo',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'GetMaterialAppDemo',
  onDispose: () {
    if (Get.isRegistered<source.CounterController>())
      Get.delete<source.CounterController>();
  },
);
