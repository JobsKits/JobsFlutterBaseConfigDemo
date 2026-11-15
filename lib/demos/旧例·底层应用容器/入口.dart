import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·底层应用容器/源码/WidgetsAppDemo.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'WidgetsAppDemo');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'WidgetsAppDemo',
);
