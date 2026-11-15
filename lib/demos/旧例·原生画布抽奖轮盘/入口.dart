import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·原生画布抽奖轮盘/源码/LuckyWheelPage.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'LuckyWheelPage');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'LuckyWheelPage',
);
