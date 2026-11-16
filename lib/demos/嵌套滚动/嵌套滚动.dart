// 独立运行：flutter run -t "lib/demos/嵌套滚动/嵌套滚动.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/NestedScrollView/NestedScrollView.dart'
    as old;

void main() => runApp(
  JobsDemoApp(
    title: '嵌套滚动',
    home: Builder(builder: buildLegacyDemo),
  ),
);

// 兼容入口保留原 Demo 实现；编辑原文件后可直接运行本文件预览。

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const Text('嵌套滚动')),
    body: const old.SimpleNestedScrollDemo(),
  ),
);
