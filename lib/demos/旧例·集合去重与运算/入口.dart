import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/demos/旧例·集合去重与运算/源码/Set.dart'
    as source;

void main() => launchLegacyStandalone(source.legacyOriginalMain, title: 'Set');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'Set',
  onDispose: () {
    if (Get.isRegistered<source.RotaryController>())
      Get.delete<source.RotaryController>();
  },
);
