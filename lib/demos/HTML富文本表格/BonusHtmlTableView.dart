// 独立运行：flutter run -t "lib/demos/HTML富文本表格/BonusHtmlTableView.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/富文本/Json表格/没有合并/BonusTablePage.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'HTML富文本表格');

void legacyOriginalMain() => legacyCaptureApp(
  JobsMaterialRunner(const BonusTablePage(), title: '富文本表格渲染'),
);

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'BonusHtmlTableView');
