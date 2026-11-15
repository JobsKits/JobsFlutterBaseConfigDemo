import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/demos/旧例·GetX异步界面渲染/源码/GetXAsyncUI.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'GetXAsyncUI');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'GetXAsyncUI',
  onDispose: () {
    if (Get.isRegistered<source.ACtrl>()) Get.delete<source.ACtrl>();
  },
);
