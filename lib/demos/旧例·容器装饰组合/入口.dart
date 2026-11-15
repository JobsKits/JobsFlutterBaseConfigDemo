import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·容器装饰组合/源码/BoxDecoration.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'BoxDecoration');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'BoxDecoration');
