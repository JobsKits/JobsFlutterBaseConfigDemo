import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·复制文字气泡提示/源码/JobsCopyTips.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'JobsCopyTips');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'JobsCopyTips');
