import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

import '../../demo_hub/legacy_support.dart';

import 'package:jobs_flutter_base_config/demos/返回拦截与确认/源码/PopScope.dart' as old;

void main() =>
    runApp(LegacyGetDemoApp(title: '返回拦截与确认', builder: buildLegacyDemo));

Widget buildLegacyDemo(BuildContext context) => Scaffold(
  appBar: AppBar(title: const LegacyText('返回拦截与确认')),
  body: SafeArea(child: const old.MyPage()),
);
