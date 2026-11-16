// 独立运行：flutter run -t "lib/demos/GetX依赖绑定启动/GetXBindingDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetXBindingDemo/CounterPage.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetXBindingDemo/CounterBinding.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX依赖绑定启动');

// 启动时注入 binding + view
void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: GetMaterialApp(
        initialBinding: CounterBinding(), // 注册依赖
        home: const CounterPage(), // 页面 UI
      ),
    ),
  );
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'GetXBindingDemo');
