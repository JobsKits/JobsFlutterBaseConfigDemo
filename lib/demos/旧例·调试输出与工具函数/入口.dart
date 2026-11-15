import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·调试输出与工具函数/源码/JobsCommonUtil.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'JobsCommonUtil');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'JobsCommonUtil',
);
