// 独立运行：flutter run -t "lib/demos/Dio网络教学启动/dio_demo_main.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_runners/jobs_runners.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/dio_demo_page.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'Dio网络教学启动');

void legacyOriginalMain() => legacyCaptureApp(
  JobsMaterialRunner(const DioDemoPage(), title: 'HTTP Methods Demo'),
);

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'dio_demo_main');
