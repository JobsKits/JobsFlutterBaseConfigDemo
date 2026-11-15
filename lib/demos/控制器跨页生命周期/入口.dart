import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

import '../../demo_hub/legacy_support.dart';

import 'package:jobs_flutter_base_config/demos/控制器跨页生命周期/源码/LifecycleDemoPage.dart'
    as old;

void main() =>
    runApp(LegacyGetDemoApp(title: '控制器跨页生命周期', builder: buildLegacyDemo));

Widget buildLegacyDemo(BuildContext context) => Scaffold(
  appBar: AppBar(title: const LegacyText('控制器跨页生命周期')),
  body: SafeArea(child: const old.LifecycleDemoPage()),
);
