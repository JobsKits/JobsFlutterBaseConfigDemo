import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·系统剪贴板与邀请码/源码/NativeClipboard.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'NativeClipboard');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'NativeClipboard',
);
