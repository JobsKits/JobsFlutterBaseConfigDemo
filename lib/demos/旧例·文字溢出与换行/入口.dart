import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·文字溢出与换行/源码/Text.dart'
    as source;

void main() => launchLegacyStandalone(source.legacyOriginalMain, title: 'Text');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'Text');
