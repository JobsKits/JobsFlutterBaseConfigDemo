import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·模型字典解析教学/源码/main.dart'
    as source;

void main() => launchLegacyStandalone(source.legacyOriginalMain, title: 'Demo');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'Demo');
