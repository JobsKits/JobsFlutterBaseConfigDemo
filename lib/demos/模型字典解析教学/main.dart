// 独立运行：flutter run -t "lib/demos/模型字典解析教学/main.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:developer' show log;

import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@iOS李明杰解析/Demo/category_model.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@iOS李明杰解析/Demo/game_model.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@iOS李明杰解析/MJModel.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '模型字典解析教学');

void legacyOriginalMain() {
  /// 注册所有模型
  MJModel.register<GameModel>(() => GameModel());
  MJModel.register<CategoryModel>(() => CategoryModel());

  /// 模拟 JSON 数据（含嵌套列表）
  final json = {
    "id": 1,
    "name": "热门游戏",
    "game_list": [
      {"game_id": 101, "game_name": "王者荣耀", "online": true},
      {"game_id": 102, "game_name": "和平精英", "online": false},
      {"game_id": 103, "game_name": "原神"}, // 未给 online，测试默认值
    ],
  };

  /// 自动转换为模型
  final category = MJModel.from<CategoryModel>(json);

  log("分类名: ${category.categoryName}");
  log("包含游戏数量: ${category.games?.length}");
  for (var game in category.games!) {
    log("游戏: ${game.name}，是否在线: ${game.isOnline}");
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Demo');
