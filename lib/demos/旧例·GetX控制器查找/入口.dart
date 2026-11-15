import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/demos/旧例·GetX控制器查找/源码/GetX_FindDemo.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'GetX_FindDemo');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'GetX_FindDemo',
  onDispose: () {
    if (Get.isRegistered<source.CounterController>())
      Get.delete<source.CounterController>();
  },
);
