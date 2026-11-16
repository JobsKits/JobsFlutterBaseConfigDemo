// 独立运行：flutter run -t "lib/demos/控制器绑定与计数/控制器绑定与计数.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';

import '../../demo_hub/legacy_support.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetXBindingDemo/CounterController.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetXBindingDemo/CounterPage.dart'
    as old;

void main() =>
    runApp(LegacyGetDemoApp(title: '控制器绑定与计数', builder: buildLegacyDemo));

Widget buildLegacyDemo(BuildContext context) =>
    LegacyControllerScope<CounterController>(
      create: CounterController.new,
      builder: (_) => const old.CounterPage(),
    );
