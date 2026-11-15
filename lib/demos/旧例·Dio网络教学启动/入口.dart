import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·Dio网络教学启动/源码/dio_demo_main.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'dio_demo_main');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'dio_demo_main');
