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

Widget buildLegacyDemo(BuildContext context) => Scaffold(
  appBar: AppBar(title: const Text('表格固定首列等宽')),
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
);
