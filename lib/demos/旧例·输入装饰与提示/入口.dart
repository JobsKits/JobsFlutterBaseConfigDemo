import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·输入装饰与提示/源码/InputDecoration.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'InputDecoration');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'InputDecoration',
);
