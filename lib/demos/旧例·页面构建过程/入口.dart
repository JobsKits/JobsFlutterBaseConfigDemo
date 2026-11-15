import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·页面构建过程/源码/MainBuildPage.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'MainBuildPage');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'MainBuildPage');
