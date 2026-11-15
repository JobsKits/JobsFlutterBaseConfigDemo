import 'package:flutter/material.dart';

import '../../demo_hub/legacy_support.dart';

import 'package:jobs_flutter_base_config/demos/控制器生命周期观察/源码/GetView.dart'
    as old;

void main() =>
    runApp(LegacyGetDemoApp(title: '控制器生命周期观察', builder: buildLegacyDemo));

Widget buildLegacyDemo(BuildContext context) =>
    LegacyControllerScope<old.RotaryController>(
      create: old.RotaryController.new,
      builder: (_) => const old.RotaryView(),
    );
