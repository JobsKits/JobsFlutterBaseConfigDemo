import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·安全图片加载/源码/JobsSafeImage.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'JobsSafeImage');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'JobsSafeImage');
