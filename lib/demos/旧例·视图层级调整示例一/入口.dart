import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·视图层级调整示例一/源码/main2.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: '调整View层级顺序');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: '调整View层级顺序');
