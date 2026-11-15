import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·不可变模型与JSON解析/源码/built_value.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'built_value');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'built_value');
