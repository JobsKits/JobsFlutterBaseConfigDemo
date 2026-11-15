import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

import '../../demo_hub/legacy_support.dart';

import 'package:jobs_flutter_base_config/demos/响应式监听防抖节流/源码/GetX_RxListenerDemo.dart'
    as old;

void main() =>
    runApp(LegacyGetDemoApp(title: '响应式监听防抖节流', builder: buildLegacyDemo));

Widget buildLegacyDemo(BuildContext context) => Scaffold(
  appBar: AppBar(title: const LegacyText('响应式监听防抖节流')),
  body: SafeArea(
    child: LegacyControllerScope<old.MyController>(
      create: old.MyController.new,
      builder: (_) => old.RxListenerDemo(),
    ),
  ),
);
