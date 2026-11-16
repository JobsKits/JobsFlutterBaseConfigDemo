// 独立运行：flutter run -t "lib/demos/JSON字段转换/JsonConverterDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:convert';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/数据处理/example_model.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'JSON字段转换');

void legacyOriginalMain() {
  final jsonData = {
    'cfg': '{"name":"single","value":1}', // value 是 JSON 字符串
    'cfgList': jsonEncode([
      {'name': 'list1', 'value': 10},
      {'name': 'list2', 'value': 20},
    ]),
    'cfgMap': {
      'a': {'name': 'map-a', 'value': 100},
      'b': {'name': 'map-b', 'value': 200},
    },
  };

  legacyDebugPrint('=== 原始 JSON ===');
  legacyDebugPrint(const JsonEncoder.withIndent('  ').convert(jsonData));

  final model = ExampleModel.fromJson(jsonData);
  legacyDebugPrint('\n=== 解析结果 ===');
  legacyDebugPrint(model.toJson().toString());

  legacyDebugPrint('\n=== 再转回 JSON（验证一致性） ===');
  legacyDebugPrint(const JsonEncoder.withIndent('  ').convert(model.toJson()));
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'JsonConverterDemo');
