import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/Excel/JobsExcel.dart'
    as old;

void main() => runApp(
  JobsDemoApp(
    title: '表格固定首列自适应',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => Scaffold(
  appBar: AppBar(title: const Text('表格固定首列自适应')),
  body: SafeArea(
    child: old.JobsExcelBuildByMode2(
      horizontalTitles: const ['功能', '说明', '状态'],
      verticalTitles: const ['侧滑菜单', '搜索', '独立Demo'],
      rowsData: const [
        ['半开与全开，可拖动关闭', '✓'],
        ['标题与关键词实时匹配', '✓'],
        ['在编辑器选择入口.dart后运行', '✓'],
      ],
      firstColumnFixedWidth: 100,
    ),
  ),
);
