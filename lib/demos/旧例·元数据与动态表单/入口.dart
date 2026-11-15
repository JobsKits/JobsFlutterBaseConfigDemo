import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·元数据与动态表单/源码/DartReflect.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'DartReflect');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'DartReflect');
