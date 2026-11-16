// 独立运行：flutter run -t "lib/demos/表格等宽列/表格等宽列.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/Excel/JobsExcel.dart'
    as old;

void main() => runApp(
  JobsDemoApp(
    title: '表格等宽列',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const Text('表格等宽列')),
    body: SafeArea(
      child: old.JobsExcelBuildByMode1(
        horizontalTitles: const ['项目', 'OC', 'Swift', 'Flutter'],
        verticalTitles: const ['开屏', '列表', '主题', '搜索'],
        rowsData: const [
          ['✓', '✓', '✓'],
          ['✓', '✓', '✓'],
          ['✓', '✓', '✓'],
          ['✓', '✓', '✓'],
        ],
      ),
    ),
  ),
);
