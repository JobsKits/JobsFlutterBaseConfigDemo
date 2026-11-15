import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·相机照片与视频采集/源码/CameraPicAndVideoDemo.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'CameraPicAndVideoDemo',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  action: source.legacyOriginalMain,
  title: 'CameraPicAndVideoDemo',
);
