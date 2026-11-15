import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/demos/旧例·GetX命名路由示例四/源码/GetX_RouteDemo4.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'GetX_RouteDemo4');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'GetX_RouteDemo4',
  onDispose: () {
    if (Get.isRegistered<source.HomeController>())
      Get.delete<source.HomeController>();
  },
);
