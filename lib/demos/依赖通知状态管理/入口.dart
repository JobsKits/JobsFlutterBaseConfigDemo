import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:provider/provider.dart';
import 'package:jobs_flutter_base_config/demos/依赖通知状态管理/源码/Provider.dart'
    as old;

// 兼容入口保留原 Demo 实现；编辑原文件后可直接运行本文件预览。
void main() => runApp(
  JobsDemoApp(
    title: '依赖通知状态管理',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => old.CounterModel()),
    ChangeNotifierProvider(create: (_) => old.ThemeModel()),
  ],
  child: const old.HomePage(),
);
