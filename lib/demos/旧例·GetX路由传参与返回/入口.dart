import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·GetX路由传参与返回/源码/GetX_RouteDemo5.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'GetX_RouteDemo5');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'GetX_RouteDemo5',
);
