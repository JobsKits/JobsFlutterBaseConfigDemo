import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·图文混排与样式/源码/Pic_Text.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'Pic_Text');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'Pic_Text');
