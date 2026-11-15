import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·SQLite数据库读写/源码/FMDB_Demo.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'FMDB_Demo');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  action: source.legacyOriginalMain,
  title: 'FMDB_Demo',
);
