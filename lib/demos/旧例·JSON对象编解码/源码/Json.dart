import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:convert';

void legacyOriginalMain() {
  handling_json_objects();
  handling_json_lists();
}

// 处理 JSON 对象
// ignore: non_constant_identifier_names
void handling_json_objects() {
  String jsonString = '{"month": "January", "num": "1", "isSelected": false}';
  Map<String, dynamic> jsonObject = jsonDecode(jsonString);

  legacyLog(jsonObject['month']); // 输出: January
  legacyLog(jsonObject['num']); // 输出: 1
  legacyLog(jsonObject['isSelected']); // 输出: false
}

// 处理 JSON 列表
// ignore: non_constant_identifier_names
void handling_json_lists() {
  String jsonString =
      '[{"month": "January", "num": "1", "isSelected": false},'
      '{"month": "February", "num": "2", "isSelected": true}]';
  List<dynamic> jsonArray = jsonDecode(jsonString);

  // ignore: avoid_function_literals_in_foreach_calls
  jsonArray.forEach((item) {
    legacyLog(item['month']); // 分别输出: January 和 February
    legacyLog(item['num']); // 分别输出: 1 和 2
    legacyLog(item['isSelected']); // 分别输出: false 和 true
  });
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·JSON对象编解码');
