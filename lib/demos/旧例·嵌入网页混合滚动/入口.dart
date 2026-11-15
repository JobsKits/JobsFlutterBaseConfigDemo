import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·嵌入网页混合滚动/源码/InappwebviewDemo1.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'InappwebviewDemo1',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  action: source.legacyOriginalMain,
  title: 'InappwebviewDemo1',
);
