// 独立运行：flutter run -t "lib/demos/GetX双向数值绑定/💥GetX的值双向绑定.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.3rd🌹/GetX/💥GetX的值双向绑定/Counter/jobs_binding.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.3rd🌹/GetX/💥GetX的值双向绑定/Counter/jobs_page.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX双向数值绑定');

void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: GetMaterialApp(
        title: '💥GetX的值双向绑定',
        initialRoute: '/jobs',
        getPages: [
          GetPage(
            name: '/jobs',
            page: () => const JobsPage(),
            binding: JobsBinding(),
          ),
        ],
      ),
    ),
  );
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'GetX的值双向绑定');
