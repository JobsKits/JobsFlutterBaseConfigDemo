// 独立运行：flutter run -t "lib/demos/表格固定首列等宽/表格固定首列等宽.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/Excel/JobsExcel.dart'
    as old;

void main() => runApp(
  JobsDemoApp(
    title: '表格固定首列等宽',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const Text('表格固定首列等宽')),
    body: SafeArea(
      child: old.JobsExcelBuildByMode3(
        horizontalTitles: const ['平台', '列表', '搜索', '主题'],
        verticalTitles: const ['OC', 'Swift', 'Flutter'],
        rowsData: const [
          ['✓', '✓', '✓'],
          ['✓', '✓', '✓'],
          ['✓', '✓', '✓'],
        ],
        firstColumnFixedWidth: 80,
      ),
    ),
  ),
);
