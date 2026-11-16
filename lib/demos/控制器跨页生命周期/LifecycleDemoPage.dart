// 独立运行：flutter run -t "lib/demos/控制器跨页生命周期/LifecycleDemoPage.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetxController的生命周期/LifecycleController.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetxController的生命周期/SecondPage.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '控制器跨页生命周期');

void legacyOriginalMain() => legacyCaptureApp(
  JobsGetRunner(LifecycleDemoPage(), title: 'GetxController的生命周期演示'),
);

class LifecycleDemoPage extends StatelessWidget {
  const LifecycleDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LifecycleController>(
      init: LifecycleController(),
      builder: (_) {
        return Center(
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => SecondPage());
            },
            child: LegacyText('跳转到第二页'),
          ),
        );
      },
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(
      actionHost: true,
      title: const LegacyText('控制器跨页生命周期'),
    ),
    body: SafeArea(child: const LifecycleDemoPage()),
  ),
);
