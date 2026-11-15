import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·Android内容URI视频/源码/VideoPlayerController.contentUri_demo（Only_In_Android）.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'VideoPlayerController.contentUri_demo（Only_In_Android）',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.android],
  action: source.legacyOriginalMain,
  title: 'VideoPlayerController.contentUri_demo（Only_In_Android）',
);
