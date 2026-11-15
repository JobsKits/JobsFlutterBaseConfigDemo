import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·网页容器与资源加载/源码/JobsWebViewWidget.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'JobsWebViewWidget',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  action: source.legacyOriginalMain,
  title: 'JobsWebViewWidget',
);
